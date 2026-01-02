class WalkPoint {
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  WalkPoint({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });
}

class WalkSession {
  final String id;
  final DateTime startTime;
  DateTime? endTime;
  final List<WalkPoint> path;
  double distanceKm;

  WalkSession({
    required this.id,
    required this.startTime,
    this.endTime,
    List<WalkPoint>? path,
    this.distanceKm = 0,
  }) : path = path ?? [];

  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  bool get isActive => endTime == null;
}
