import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/walk_provider.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/map_style.dart';
import '../core/utils/walk_calculator.dart';
import '../widgets/map_control_button.dart';
import '../widgets/stat_card.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WalkProvider>().getCurrentLocation();
    });
  }

  Set<Polyline> _buildPolylines(WalkProvider wp) {
    final polylines = <Polyline>{};
    if (wp.currentSession == null || wp.currentSession!.path.isEmpty) return polylines;

    final points = wp.currentSession!.path
        .map((p) => LatLng(p.latitude, p.longitude))
        .toList();

    polylines.add(Polyline(
      polylineId: const PolylineId('walk_path'),
      points: points,
      color: kAccentViolet,
      width: 4,
      patterns: [PatternItem.dash(20), PatternItem.gap(10)],
    ));
    return polylines;
  }

  Set<Marker> _buildMarkers(WalkProvider wp) {
    final markers = <Marker>{};
    if (wp.currentSession != null && wp.currentSession!.path.isNotEmpty) {
      final start = wp.currentSession!.path.first;
      markers.add(Marker(
        markerId: const MarkerId('start'),
        position: LatLng(start.latitude, start.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
        infoWindow: const InfoWindow(title: '시작'),
      ));
    }
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WalkProvider>(
      builder: (context, wp, _) {
        final target = LatLng(wp.currentUser.latitude, wp.currentUser.longitude);

        return Scaffold(
          backgroundColor: kBgPrimary,
          body: Stack(
            children: [
              // 지도
              GoogleMap(
                initialCameraPosition: CameraPosition(target: target, zoom: 16),
                onMapCreated: (controller) async {
                  _mapController = controller;
                  await controller.setMapStyle(kMapStyleDark);
                },
                polylines: _buildPolylines(wp),
                markers: _buildMarkers(wp),
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                compassEnabled: false,
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
                    MapControlButton(
                      icon: Icons.add,
                      onPressed: () => _mapController?.animateCamera(CameraUpdate.zoomIn()),
                    ),
                    const SizedBox(height: 8),
                    MapControlButton(
                      icon: Icons.remove,
                      onPressed: () => _mapController?.animateCamera(CameraUpdate.zoomOut()),
                    ),
                    const SizedBox(height: 8),
                    MapControlButton(
                      icon: Icons.my_location,
                      onPressed: () {
                        _mapController?.animateCamera(
                          CameraUpdate.newLatLng(target),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    MapControlButton(
                      icon: Icons.layers_outlined,
                      onPressed: () {},
                    ),
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
                            // 실시간 통계
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
                            // 컨트롤 버튼
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: Row(
                                children: [
                                  // 정지
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
                                  // 일시정지/재시작
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
                                              wp.isPaused
                                                  ? Icons.play_arrow_rounded
                                                  : Icons.pause_rounded,
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
                                  // 마커
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
                            // 산책 시작 전
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                              child: Column(
                                children: [
                                  Text(
                                    wp.currentUser.dog?.name != null
                                        ? '${wp.currentUser.dog!.name}와 산책을 시작해볼까요?'
                                        : '산책을 시작해볼까요?',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: kTextSecondary,
                                    ),
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

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
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
        color: kBgSurface.withOpacity(0.95),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorderColor),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10),
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
          _Badge('Saved', kSuccess, Icons.cloud_done_rounded),
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
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4)),
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
