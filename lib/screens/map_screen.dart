import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/walk_provider.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/walk_calculator.dart';
import '../widgets/map_control_button.dart';
import '../widgets/stat_card.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WalkProvider>().getCurrentLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WalkProvider>(
      builder: (context, wp, _) {
        return Scaffold(
          backgroundColor: kBgPrimary,
          body: Stack(
            children: [
              // 지도 플레이스홀더
              _MapPlaceholder(
                isWalking: wp.isWalking,
                path: wp.currentSession?.path ?? [],
              ),

              // 상단 상태 바 (산책 중일 때)
              if (wp.isWalking)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 12,
                  left: 16,
                  right: 16,
                  child: _TopStatusBar(wp: wp),
                ),

              // 우측 컨트롤
              Positioned(
                right: 12,
                top: MediaQuery.of(context).padding.top + (wp.isWalking ? 80 : 20),
                child: Column(
                  children: [
                    MapControlButton(icon: Icons.add, onPressed: () {}),
                    const SizedBox(height: 8),
                    MapControlButton(icon: Icons.remove, onPressed: () {}),
                    const SizedBox(height: 8),
                    MapControlButton(icon: Icons.my_location, onPressed: () {}),
                    const SizedBox(height: 8),
                    MapControlButton(icon: Icons.layers_outlined, onPressed: () {}),
                  ],
                ),
              ),

              // 하단 패널
              DraggableScrollableSheet(
                initialChildSize: wp.isWalking ? 0.28 : 0.18,
                minChildSize: 0.12,
                maxChildSize: 0.45,
                builder: (context, scrollController) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: kBgSurface,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      border: Border(
                        top: BorderSide(color: kBorderColor),
                        left: BorderSide(color: kBorderColor),
                        right: BorderSide(color: kBorderColor),
                      ),
                    ),
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        children: [
                          // 드래그 핸들
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Container(
                              width: 36,
                              height: 4,
                              decoration: BoxDecoration(
                                color: kTextMuted,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),

                          if (wp.isWalking) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: GridView.count(
                                crossAxisCount: 2,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10,
                                childAspectRatio: 1.8,
                                children: [
                                  StatCard(
                                    label: '거리',
                                    value: wp.currentSession!.distanceKm.toStringAsFixed(2),
                                    unit: 'km',
                                    icon: Icons.route,
                                  ),
                                  StatCard(
                                    label: '속도',
                                    value: wp.currentSpeedKmh.toStringAsFixed(1),
                                    unit: 'km/h',
                                    icon: Icons.speed,
                                    iconColor: kSuccess,
                                  ),
                                  StatCard(
                                    label: '걸음수',
                                    value: wp.currentSteps.toString(),
                                    unit: '걸음',
                                    icon: Icons.directions_walk,
                                    iconColor: kPending,
                                  ),
                                  StatCard(
                                    label: '칼로리',
                                    value: wp.currentCalories.toString(),
                                    unit: 'kcal',
                                    icon: Icons.local_fire_department,
                                    iconColor: kWarning,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: wp.stopWalk,
                                    child: Container(
                                      width: 52,
                                      height: 52,
                                      decoration: BoxDecoration(
                                        color: kBgElevated,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(color: kBorderColor),
                                      ),
                                      child: const Icon(Icons.stop_rounded, color: kError, size: 26),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: wp.isPaused ? wp.resumeWalk : wp.pauseWalk,
                                      child: Container(
                                        height: 52,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [kAccentPurple, kAccentViolet],
                                          ),
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              wp.isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                                              color: Colors.white,
                                              size: 22,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              wp.isPaused ? '재시작' : '일시정지',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: kBgElevated,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: kBorderColor),
                                    ),
                                    child: const Icon(Icons.place_rounded, color: kAccentViolet, size: 24),
                                  ),
                                ],
                              ),
                            ),
                          ] else ...[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                              child: Column(
                                children: [
                                  Text(
                                    wp.currentUser.dog?.name != null
                                        ? '${wp.currentUser.dog!.name}와 산책을 시작해볼까요?'
                                        : '산책을 시작해볼까요?',
                                    style: const TextStyle(fontSize: 15, color: kTextSecondary),
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: wp.startWalk,
                                      icon: const Icon(Icons.directions_walk, size: 20),
                                      label: const Text('산책 시작'),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Google Maps 대신 사용하는 커스텀 지도 플레이스홀더
class _MapPlaceholder extends StatelessWidget {
  final bool isWalking;
  final List<dynamic> path;

  const _MapPlaceholder({required this.isWalking, required this.path});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFF1a2035),
      child: CustomPaint(
        painter: _PathPainter(path: path, isWalking: isWalking),
        child: Center(
          child: !isWalking
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map_outlined, size: 64, color: kTextMuted.withValues(alpha: 0.4)),
                    const SizedBox(height: 12),
                    Text(
                      '산책을 시작하면\n경로가 표시됩니다',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: kTextMuted.withValues(alpha: 0.6),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: kAccentPurple.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: kAccentPurple.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.info_outline, size: 13, color: kAccentViolet),
                          SizedBox(width: 6),
                          Text(
                            'Google Maps API 키 설정 후 지도 활성화',
                            style: TextStyle(fontSize: 11, color: kAccentViolet),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : const SizedBox(),
        ),
      ),
    );
  }
}

/// 산책 경로를 직접 그리는 페인터
class _PathPainter extends CustomPainter {
  final List<dynamic> path;
  final bool isWalking;

  _PathPainter({required this.path, required this.isWalking});

  @override
  void paint(Canvas canvas, Size size) {
    if (path.length < 2) return;

    final paint = Paint()
      ..color = kAccentViolet
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // 위도/경도 범위 계산
    double minLat = path.first.latitude;
    double maxLat = path.first.latitude;
    double minLng = path.first.longitude;
    double maxLng = path.first.longitude;

    for (final p in path) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    final latRange = (maxLat - minLat).abs();
    final lngRange = (maxLng - minLng).abs();
    final range = latRange > lngRange ? latRange : lngRange;
    if (range == 0) return;

    final padding = size.width * 0.15;
    final drawWidth = size.width - padding * 2;
    final drawHeight = size.height * 0.5;
    final offsetY = size.height * 0.2;

    final pathObj = Path();
    for (int i = 0; i < path.length; i++) {
      final x = padding + ((path[i].longitude - minLng) / range) * drawWidth;
      final y = offsetY + drawHeight - ((path[i].latitude - minLat) / range) * drawHeight;
      if (i == 0) {
        pathObj.moveTo(x, y);
      } else {
        pathObj.lineTo(x, y);
      }
    }
    canvas.drawPath(pathObj, paint);

    // 시작점
    final startX = padding + ((path.first.longitude - minLng) / range) * drawWidth;
    final startY = offsetY + drawHeight - ((path.first.latitude - minLat) / range) * drawHeight;
    canvas.drawCircle(Offset(startX, startY), 6, Paint()..color = kSuccess);

    // 현재 위치 (마지막 점)
    final endX = padding + ((path.last.longitude - minLng) / range) * drawWidth;
    final endY = offsetY + drawHeight - ((path.last.latitude - minLat) / range) * drawHeight;
    canvas.drawCircle(Offset(endX, endY), 8, Paint()..color = kAccentViolet);
    canvas.drawCircle(Offset(endX, endY), 14,
        Paint()
          ..color = kAccentViolet.withValues(alpha: 0.3)
          ..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(_PathPainter old) => old.path.length != path.length;
}

class _TopStatusBar extends StatelessWidget {
  final WalkProvider wp;

  const _TopStatusBar({required this.wp});

  String _gpsLabel(GpsQuality q) => switch (q) {
        GpsQuality.high => 'High',
        GpsQuality.medium => 'Medium',
        GpsQuality.low => 'Low',
      };

  Color _gpsColor(GpsQuality q) => switch (q) {
        GpsQuality.high => kSuccess,
        GpsQuality.medium => kWarning,
        GpsQuality.low => kError,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: kBgSurface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorderColor),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(right: 8),
            decoration: const BoxDecoration(shape: BoxShape.circle, color: kError),
          ),
          const Text('RECORDING', style: TextStyle(fontSize: 10, color: kTextMuted, letterSpacing: 1)),
          const SizedBox(width: 8),
          Text(
            wp.formattedElapsed,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kTextPrimary,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const Spacer(),
          _Badge(_gpsLabel(wp.gpsQuality), _gpsColor(wp.gpsQuality), Icons.gps_fixed),
          const SizedBox(width: 8),
          const _Badge('Saved', kSuccess, Icons.cloud_done_rounded),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _Badge(this.label, this.color, this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
