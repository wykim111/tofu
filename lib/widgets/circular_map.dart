import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/user.dart';
import '../models/walk_session.dart';

class CircularMap extends StatefulWidget {
  final AppUser currentUser;
  final List<AppUser> nearbyUsers;
  final WalkSession? walkSession;
  final double size;

  const CircularMap({
    super.key,
    required this.currentUser,
    required this.nearbyUsers,
    this.walkSession,
    this.size = 280,
  });

  @override
  State<CircularMap> createState() => _CircularMapState();
}

class _CircularMapState extends State<CircularMap> {
  GoogleMapController? _mapController;
  BitmapDescriptor? _dogMarkerIcon;

  @override
  void initState() {
    super.initState();
    _createCustomMarker();
  }

  Future<void> _createCustomMarker() async {
    _dogMarkerIcon = BitmapDescriptor.defaultMarkerWithHue(
      BitmapDescriptor.hueOrange,
    );
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(CircularMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 위치가 변경되면 카메라 이동
    if (oldWidget.currentUser.latitude != widget.currentUser.latitude ||
        oldWidget.currentUser.longitude != widget.currentUser.longitude) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(widget.currentUser.latitude, widget.currentUser.longitude),
        ),
      );
    }
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};

    // 내 위치 마커
    markers.add(
      Marker(
        markerId: const MarkerId('my_location'),
        position: LatLng(
          widget.currentUser.latitude,
          widget.currentUser.longitude,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: widget.currentUser.dog?.name ?? '내 강아지',
          snippet: '현재 위치',
        ),
      ),
    );

    // 주변 유저 마커
    for (final user in widget.nearbyUsers) {
      markers.add(
        Marker(
          markerId: MarkerId(user.id),
          position: LatLng(user.latitude, user.longitude),
          icon: _dogMarkerIcon ?? BitmapDescriptor.defaultMarkerWithHue(
            user.isWalking ? BitmapDescriptor.hueAzure : BitmapDescriptor.hueRed,
          ),
          infoWindow: InfoWindow(
            title: user.dog?.name ?? '강아지',
            snippet: '${user.name} ${user.isWalking ? "(산책 중)" : ""}',
          ),
        ),
      );
    }

    return markers;
  }

  Set<Polyline> _buildPolylines() {
    final polylines = <Polyline>{};

    if (widget.walkSession != null && widget.walkSession!.path.isNotEmpty) {
      final points = widget.walkSession!.path
          .map((p) => LatLng(p.latitude, p.longitude))
          .toList();

      polylines.add(
        Polyline(
          polylineId: const PolylineId('walk_path'),
          points: points,
          color: Colors.blue,
          width: 5,
          patterns: [PatternItem.dot, PatternItem.gap(10)],
        ),
      );
    }

    return polylines;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipOval(
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(
              widget.currentUser.latitude,
              widget.currentUser.longitude,
            ),
            zoom: 16,
          ),
          onMapCreated: (controller) {
            _mapController = controller;
          },
          markers: _buildMarkers(),
          polylines: _buildPolylines(),
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          compassEnabled: false,
          rotateGesturesEnabled: false,
          scrollGesturesEnabled: true,
          zoomGesturesEnabled: true,
          tiltGesturesEnabled: false,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
