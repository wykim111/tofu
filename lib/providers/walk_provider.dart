import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/walk_session.dart';
import '../models/user.dart';
import '../models/dog.dart';
import '../core/utils/walk_calculator.dart';

enum GpsQuality { high, medium, low }

class WalkProvider extends ChangeNotifier {
  WalkSession? _currentSession;
  Position? _currentPosition;
  StreamSubscription<Position>? _positionSubscription;
  Timer? _timer;
  DateTime? _pauseStartTime;

  late AppUser _currentUser;
  final List<WalkSession> _sessions = [];

  // 실시간 계산값
  double _currentSpeedKmh = 0;
  double _currentPace = 0;
  int _currentCalories = 0;
  int _currentSteps = 0;
  GpsQuality _gpsQuality = GpsQuality.high;

  WalkProvider() {
    _currentUser = AppUser(
      id: 'user_1',
      name: '김산책',
      email: 'walker@example.com',
      dog: Dog(
        id: 'dog_1',
        name: '두부',
        breed: '포메라니안',
        ownerId: 'user_1',
      ),
      latitude: 37.5665,
      longitude: 126.9780,
      totalDistanceKm: 42.5,
      totalWalkMinutes: 185,
      totalWalkCount: 12,
    );

    // 샘플 세션 데이터
    _sessions.addAll(_buildSampleSessions());
  }

  // Getters
  WalkSession? get currentSession => _currentSession;
  Position? get currentPosition => _currentPosition;
  AppUser get currentUser => _currentUser;
  List<WalkSession> get sessions => List.unmodifiable(_sessions);
  bool get isWalking => _currentSession?.isActive ?? false;
  bool get isPaused => _currentSession?.isPaused ?? false;
  double get currentSpeedKmh => _currentSpeedKmh;
  double get currentPace => _currentPace;
  int get currentCalories => _currentCalories;
  int get currentSteps => _currentSteps;
  GpsQuality get gpsQuality => _gpsQuality;

  String get formattedElapsed {
    if (_currentSession == null) return '00:00:00';
    return WalkCalculator.formatDuration(_currentSession!.duration);
  }

  String get formattedPace => WalkCalculator.formatPace(_currentPace);

  Future<bool> checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    if (permission == LocationPermission.deniedForever) return false;
    return true;
  }

  Future<void> getCurrentLocation() async {
    final hasPermission = await checkLocationPermission();
    if (!hasPermission) return;

    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      _currentUser = _currentUser.copyWith(
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
      );
      notifyListeners();
    } catch (_) {}
  }

  Future<void> startWalk() async {
    final hasPermission = await checkLocationPermission();
    if (!hasPermission) return;

    _currentSession = WalkSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startTime: DateTime.now(),
    );

    _currentUser = _currentUser.copyWith(isWalking: true);
    _currentSpeedKmh = 0;
    _currentPace = 0;
    _currentCalories = 0;
    _currentSteps = 0;

    _startTimer();
    _startPositionStream();
    notifyListeners();
  }

  void pauseWalk() {
    if (_currentSession == null || _currentSession!.isPaused) return;
    _currentSession!.isPaused = true;
    _pauseStartTime = DateTime.now();
    _positionSubscription?.pause();
    _timer?.cancel();
    notifyListeners();
  }

  void resumeWalk() {
    if (_currentSession == null || !_currentSession!.isPaused) return;
    if (_pauseStartTime != null) {
      _currentSession!.pausedDuration += DateTime.now().difference(_pauseStartTime!);
      _pauseStartTime = null;
    }
    _currentSession!.isPaused = false;
    _positionSubscription?.resume();
    _startTimer();
    notifyListeners();
  }

  void stopWalk() {
    if (_currentSession == null) return;

    if (_currentSession!.isPaused) {
      resumeWalk();
    }

    _currentSession!.endTime = DateTime.now();
    _currentSession!.pace = _currentPace;
    _currentSession!.calories = _currentCalories;
    _currentSession!.steps = _currentSteps;
    _currentSession!.syncStatus = SyncStatus.pending;

    _currentUser = _currentUser.copyWith(
      isWalking: false,
      totalDistanceKm: _currentUser.totalDistanceKm + _currentSession!.distanceKm,
      totalWalkMinutes: _currentUser.totalWalkMinutes + _currentSession!.duration.inMinutes,
      totalWalkCount: _currentUser.totalWalkCount + 1,
    );

    _sessions.insert(0, _currentSession!);
    _timer?.cancel();
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _currentSpeedKmh = 0;
    _currentPace = 0;

    notifyListeners();
  }

  void saveSessionMeta(String sessionId, {
    String? title,
    List<String>? tags,
    bool? isPrivate,
    WeatherInfo? weather,
  }) {
    final idx = _sessions.indexWhere((s) => s.id == sessionId);
    if (idx == -1) return;
    final s = _sessions[idx];
    if (title != null) s.title = title;
    if (tags != null) s.tags = tags;
    if (isPrivate != null) s.isPrivate = isPrivate;
    if (weather != null) s.weather = weather;
    s.syncStatus = SyncStatus.synced;
    notifyListeners();
  }

  void deleteSession(String sessionId) {
    _sessions.removeWhere((s) => s.id == sessionId);
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      notifyListeners();
    });
  }

  void _startPositionStream() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 3,
    );

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      _currentPosition = position;
      _updateGpsQuality(position);

      if (_currentSession != null && _currentSession!.isActive && !_currentSession!.isPaused) {
        final newPoint = WalkPoint(
          latitude: position.latitude,
          longitude: position.longitude,
          altitude: position.altitude,
          timestamp: DateTime.now(),
        );

        if (_currentSession!.path.isNotEmpty) {
          final lastPoint = _currentSession!.path.last;
          final distance = Geolocator.distanceBetween(
            lastPoint.latitude, lastPoint.longitude,
            newPoint.latitude, newPoint.longitude,
          );
          _currentSession!.distanceKm += distance / 1000;
        }

        _currentSession!.path.add(newPoint);

        // 실시간 계산
        final duration = _currentSession!.duration;
        _currentSpeedKmh = WalkCalculator.calculateSpeed(_currentSession!.distanceKm, duration);
        _currentPace = WalkCalculator.calculatePace(_currentSession!.distanceKm, duration);
        _currentCalories = WalkCalculator.calculateCalories(_currentSession!.distanceKm, duration);
        _currentSteps = WalkCalculator.calculateSteps(_currentSession!.distanceKm);

        _currentUser = _currentUser.copyWith(
          latitude: position.latitude,
          longitude: position.longitude,
        );
      }

      notifyListeners();
    });
  }

  void _updateGpsQuality(Position position) {
    final acc = position.accuracy;
    if (acc <= 5) {
      _gpsQuality = GpsQuality.high;
    } else if (acc <= 15) {
      _gpsQuality = GpsQuality.medium;
    } else {
      _gpsQuality = GpsQuality.low;
    }
  }

  List<WalkSession> _buildSampleSessions() {
    final now = DateTime.now();
    return [
      WalkSession(
        id: 'sample_1',
        startTime: DateTime(now.year, now.month, now.day, 18, 30),
        endTime: DateTime(now.year, now.month, now.day, 19, 15),
        distanceKm: 4.2,
        pace: 10.7,
        calories: 198,
        steps: 5600,
        title: '한강 공원 저녁 산책',
        syncStatus: SyncStatus.synced,
        weather: const WeatherInfo(condition: '맑음', temperature: 18),
      ),
      WalkSession(
        id: 'sample_2',
        startTime: DateTime(now.year, now.month, now.day - 1, 7, 15),
        endTime: DateTime(now.year, now.month, now.day - 1, 7, 37),
        distanceKm: 2.1,
        pace: 10.5,
        calories: 95,
        steps: 2800,
        title: '동네 한바퀴',
        syncStatus: SyncStatus.pending,
        weather: const WeatherInfo(condition: '흐림', temperature: 15),
      ),
      WalkSession(
        id: 'sample_3',
        startTime: DateTime(now.year, now.month, 15, 14, 0),
        endTime: DateTime(now.year, now.month, 15, 15, 15),
        distanceKm: 6.8,
        pace: 11.0,
        calories: 312,
        steps: 9067,
        title: '남산 둘레길',
        syncStatus: SyncStatus.retrying,
        weather: const WeatherInfo(condition: '맑음', temperature: 20),
      ),
    ];
  }

  @override
  void dispose() {
    _timer?.cancel();
    _positionSubscription?.cancel();
    super.dispose();
  }
}
