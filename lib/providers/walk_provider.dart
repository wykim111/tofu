import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/walk_session.dart';
import '../models/user.dart';
import '../models/dog.dart';

class WalkProvider extends ChangeNotifier {
  WalkSession? _currentSession;
  Position? _currentPosition;
  StreamSubscription<Position>? _positionSubscription;
  
  late AppUser _currentUser;
  final List<AppUser> _nearbyUsers = [];

  WalkProvider() {
    _currentUser = AppUser(
      id: 'user_1',
      name: '김민수',
      dog: Dog(
        id: 'dog_1',
        name: '주구',
        breed: '골든리트리버',
        ownerId: 'user_1',
      ),
      latitude: 37.5665,
      longitude: 126.9780,
      totalDistanceKm: 523.5,
      totalWalkMinutes: 185,
    );
    
    _nearbyUsers.addAll([
      AppUser(
        id: 'user_2',
        name: '김민수',
        dog: Dog(
          id: 'dog_2',
          name: '바둑이',
          breed: '퍼그',
          ownerId: 'user_2',
        ),
        latitude: 37.5670,
        longitude: 126.9785,
        isWalking: true,
      ),
      AppUser(
        id: 'user_3',
        name: '이영희',
        dog: Dog(
          id: 'dog_3',
          name: '초코',
          breed: '푸들',
          ownerId: 'user_3',
        ),
        latitude: 37.5660,
        longitude: 126.9775,
        isWalking: true,
      ),
      AppUser(
        id: 'user_4',
        name: '박철수',
        dog: Dog(
          id: 'dog_4',
          name: '뽀삐',
          breed: '시바견',
          ownerId: 'user_4',
        ),
        latitude: 37.5668,
        longitude: 126.9770,
        isWalking: false,
      ),
    ]);
  }

  WalkSession? get currentSession => _currentSession;
  Position? get currentPosition => _currentPosition;
  AppUser get currentUser => _currentUser;
  List<AppUser> get nearbyUsers => _nearbyUsers;
  bool get isWalking => _currentSession?.isActive ?? false;

  Future<bool> checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  Future<void> getCurrentLocation() async {
    final hasPermission = await checkLocationPermission();
    if (!hasPermission) return;

    _currentPosition = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
    
    _currentUser = _currentUser.copyWith(
      latitude: _currentPosition!.latitude,
      longitude: _currentPosition!.longitude,
    );
    
    notifyListeners();
  }

  Future<void> startWalk() async {
    final hasPermission = await checkLocationPermission();
    if (!hasPermission) return;

    _currentSession = WalkSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startTime: DateTime.now(),
    );

    _currentUser = _currentUser.copyWith(isWalking: true);

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      _currentPosition = position;
      
      if (_currentSession != null && _currentSession!.isActive) {
        final newPoint = WalkPoint(
          latitude: position.latitude,
          longitude: position.longitude,
          timestamp: DateTime.now(),
        );
        
        if (_currentSession!.path.isNotEmpty) {
          final lastPoint = _currentSession!.path.last;
          final distance = Geolocator.distanceBetween(
            lastPoint.latitude,
            lastPoint.longitude,
            newPoint.latitude,
            newPoint.longitude,
          );
          _currentSession!.distanceKm += distance / 1000;
        }
        
        _currentSession!.path.add(newPoint);
        
        _currentUser = _currentUser.copyWith(
          latitude: position.latitude,
          longitude: position.longitude,
        );
      }
      
      notifyListeners();
    });

    notifyListeners();
  }

  void stopWalk() {
    if (_currentSession != null) {
      _currentSession!.endTime = DateTime.now();
      
      _currentUser = _currentUser.copyWith(
        isWalking: false,
        totalDistanceKm: _currentUser.totalDistanceKm + _currentSession!.distanceKm,
        totalWalkMinutes: _currentUser.totalWalkMinutes + _currentSession!.duration.inMinutes,
      );
    }
    
    _positionSubscription?.cancel();
    _positionSubscription = null;
    
    notifyListeners();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }
}
