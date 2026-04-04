class WalkCalculator {
  /// 칼로리 계산 (MET 방법, 보행 MET=3.5)
  static int calculateCalories(double distanceKm, Duration duration, {double weightKg = 65}) {
    if (duration.inSeconds == 0) return 0;
    final hours = duration.inSeconds / 3600;
    const met = 3.5;
    return (met * weightKg * hours).round();
  }

  /// 걸음수 계산 (평균 보폭 0.75m)
  static int calculateSteps(double distanceKm, {double strideLengthM = 0.75}) {
    return ((distanceKm * 1000) / strideLengthM).round();
  }

  /// 페이스 계산 (분/km)
  static double calculatePace(double distanceKm, Duration duration) {
    if (distanceKm <= 0) return 0;
    final minutes = duration.inSeconds / 60;
    return minutes / distanceKm;
  }

  /// 속도 계산 (km/h)
  static double calculateSpeed(double distanceKm, Duration duration) {
    if (duration.inSeconds == 0) return 0;
    final hours = duration.inSeconds / 3600;
    return distanceKm / hours;
  }

  /// Duration → "HH:MM:SS"
  static String formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  /// 페이스 → "8'30\""
  static String formatPace(double paceMinPerKm) {
    if (paceMinPerKm <= 0 || paceMinPerKm.isInfinite || paceMinPerKm.isNaN) return "--'--\"";
    final min = paceMinPerKm.floor();
    final sec = ((paceMinPerKm - min) * 60).round();
    return "$min'${sec.toString().padLeft(2, '0')}\"";
  }

  /// 거리 → "2.4 km" or "350 m"
  static String formatDistance(double km) {
    if (km < 1) return '${(km * 1000).round()} m';
    return '${km.toStringAsFixed(2)} km';
  }
}
