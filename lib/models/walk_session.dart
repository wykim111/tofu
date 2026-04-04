enum SyncStatus { synced, pending, retrying }

class WeatherInfo {
  final String condition;
  final double temperature;

  const WeatherInfo({required this.condition, required this.temperature});
}

class WalkPoint {
  final double latitude;
  final double longitude;
  final double altitude;
  final DateTime timestamp;

  WalkPoint({
    required this.latitude,
    required this.longitude,
    this.altitude = 0,
    required this.timestamp,
  });
}

class WalkSession {
  final String id;
  final DateTime startTime;
  DateTime? endTime;
  final List<WalkPoint> path;
  double distanceKm;

  // 추가 통계
  double pace;         // 분/km
  int calories;
  int steps;

  // 메타데이터
  String? title;
  List<String> tags;
  WeatherInfo? weather;
  List<String> photoPaths;
  SyncStatus syncStatus;
  bool isPrivate;

  // 일시정지 관련
  bool isPaused;
  Duration pausedDuration;

  WalkSession({
    required this.id,
    required this.startTime,
    this.endTime,
    List<WalkPoint>? path,
    this.distanceKm = 0,
    this.pace = 0,
    this.calories = 0,
    this.steps = 0,
    this.title,
    List<String>? tags,
    this.weather,
    List<String>? photoPaths,
    this.syncStatus = SyncStatus.pending,
    this.isPrivate = false,
    this.isPaused = false,
    this.pausedDuration = Duration.zero,
  })  : path = path ?? [],
        tags = tags ?? [],
        photoPaths = photoPaths ?? [];

  /// 순수 활동 시간 (일시정지 제외)
  Duration get duration {
    final end = endTime ?? DateTime.now();
    final total = end.difference(startTime);
    return total - pausedDuration;
  }

  bool get isActive => endTime == null;
}
