import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  final int penggunaId;
  const MapScreen({super.key, required this.penggunaId});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? currentPosition;
  LatLng? startPoint;
  final List<LatLng> route = [];

  final List<Map<String, dynamic>> gpsLog = [];
  late StreamSubscription<ServiceStatus> _gpsSubscription;
  int selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _gpsSubscription =
        Geolocator.getServiceStatusStream().listen((status) {
        if (status == ServiceStatus.enabled) {
          _getCurrentLocation(); // 🔥 panggil ulang
        }
    });
  }

  @override
  void dispose() {
    _gpsSubscription.cancel();
    super.dispose();
  }

  // ================= LOCATION =================
  Future<void> _getCurrentLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Aktifkan GPS terlebih dahulu"), 
        backgroundColor: Colors.red),
      );
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) return;

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      currentPosition = LatLng(pos.latitude, pos.longitude);
    });
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    if (currentPosition == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          _buildMap(),
          _buildHeader(),
        ],
      ),
      backgroundColor: Colors.white,

    );
  }

  // ================= MAP =================
  Widget _buildMap() {
    return FlutterMap(
      options: MapOptions(
        center: route.isNotEmpty ? route.last : currentPosition!,
        zoom: 16,
      ),
      children: [
        TileLayer(
          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
        ),
        if (route.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(points: route, color: Colors.grey, strokeWidth: 4),
            ],
          ),
        MarkerLayer(
          markers: [
            if (startPoint != null)
              _marker(startPoint!, Icons.location_on, Colors.green),
            _marker(currentPosition!, Icons.navigation, Colors.red),
          ],
        ),
      ],
    );
  }

  Marker _marker(LatLng p, IconData i, Color c) =>
      Marker(point: p, width: 40, height: 40, child: Icon(i, color: c));

  // ================= HEADER =================
  Widget _buildHeader() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _circleIcon(Icons.arrow_back, () => Navigator.pop(context)),
            const Spacer(),
            const Text("Posisi Anda Saat Ini",
                style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold)),
            const Spacer(),
            _gpsBadge(),
          ],
        ),
      ),
    );
  }

  Widget _circleIcon(IconData icon, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: const CircleAvatar(
          backgroundColor: Colors.white,
          child: Icon(Icons.arrow_back, color: Colors.black),
        ),
      );

  Widget _gpsBadge() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: const [
            Text("GPS", style: TextStyle(color: Colors.black, fontSize: 12)),
            SizedBox(width: 6),
            Icon(Icons.signal_cellular_alt,
                size: 14, color: Colors.green),
          ],
        ),
      );
}
