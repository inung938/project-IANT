import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../services/api_service.dart';

class MulaiScreen extends StatefulWidget {
  final int penggunaId;
  final String jenisOlahraga; // 🔹 BERLARI / BERJALAN / BERSEPEDA

  const MulaiScreen({
    super.key,
    required this.penggunaId,
    required this.jenisOlahraga,
  });

  @override
  State<MulaiScreen> createState() => _MulaiScreenState();
}

class _MulaiScreenState extends State<MulaiScreen> {
  LatLng? currentPosition;
  LatLng? startPoint;
  final List<LatLng> route = [];

  bool isPaused = false;

  DateTime? startTime;
  DateTime? pauseTime;
  Duration pausedDuration = Duration.zero;
  Duration elapsedTime = Duration.zero;

  double totalDistance = 0; // meter
  double avgSpeed = 0; // km/h
  double calories = 0;

  final double beratBadan = 65;
  final Distance _distance = const Distance();

  final List<Map<String, dynamic>> gpsLog = [];

  StreamSubscription<Position>? positionStream;
  Timer? timer;
  Timer? syncTimer;

  int? olahragaId;

  // ================= INIT =================
  @override
  void initState() {
    super.initState();
    _initTracking();
  }

  @override
  void dispose() {
    positionStream?.cancel();
    timer?.cancel();
    syncTimer?.cancel();
    super.dispose();
  }

  // ================= BLOCK BACK =================
  Future<bool> _onWillPop() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Tidak bisa keluar, akhiri olahraga terlebih dahulu", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
        duration: Duration(seconds: 3),
        backgroundColor: Colors.white,
      ),
    );
    return false;
  }

  // ================= INIT TRACK =================
  Future<void> _initTracking() async {
    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
    );

    currentPosition = LatLng(pos.latitude, pos.longitude);
    startPoint = currentPosition;

    final now = DateTime.now();
    startTime = now;

    route.add(currentPosition!);
    gpsLog.add({
      "lat": pos.latitude,
      "lng": pos.longitude,
      "t": now.millisecondsSinceEpoch ~/ 1000,
    });

    olahragaId = await ApiService().startOlahraga({
      "id_pengguna": widget.penggunaId,
      "jenis_olahraga": widget.jenisOlahraga,
      "status_olahraga": "Berlangsung",
      "waktu_mulai": now.millisecondsSinceEpoch ~/ 1000,
      "koordinat_gps": jsonEncode(gpsLog),
    });

    // ⏱ TIMER
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!isPaused) {
        setState(() {
          elapsedTime =
              DateTime.now().difference(startTime!) - pausedDuration;
        });
      }
    });

    // 📡 GPS STREAM
    positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 1,
      ),
    ).listen(_onLocationUpdate);

    // 🔁 SYNC DB
    syncTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (olahragaId != null && gpsLog.isNotEmpty) {
        await ApiService().updateOlahraga(olahragaId!, _payload());
      }
    });

    setState(() {});
  }

  // ================= GPS UPDATE =================
  void _onLocationUpdate(Position pos) {
    if (isPaused) return;

    final newPoint = LatLng(pos.latitude, pos.longitude);
    final moved = _distance(route.last, newPoint);

    if (moved >= 1 && moved <= 20) {
      totalDistance += moved;
      route.add(newPoint);

      final hours = elapsedTime.inSeconds / 3600;
      if (hours > 0) {
        avgSpeed = (totalDistance / 1000) / hours;
      }

      calories = beratBadan * (totalDistance / 1000) * 1.036;
    }

    gpsLog.add({
      "lat": pos.latitude,
      "lng": pos.longitude,
      "t": DateTime.now().millisecondsSinceEpoch ~/ 1000,
    });

    setState(() {
      currentPosition = newPoint;
    });
  }

  // ================= PAUSE =================
  void _togglePause() {
    setState(() {
      if (!isPaused) {
        pauseTime = DateTime.now();
        isPaused = true;
      } else {
        pausedDuration += DateTime.now().difference(pauseTime!);
        isPaused = false;
      }
    });
  }

  // ================= STOP =================
  Future<void> _confirmStop() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor:  Color(0xFFF5F5F5),
        title: const Text("Akhiri Olahraga", style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold)),
        content: const Text(
          "Apakah kamu yakin ingin mengakhiri olahraga ini?\n"
          "Aktivitas akan disimpan dan tidak bisa dilanjutkan.",
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Lanjutkan", style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Akhiri", style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ApiService().updateOlahraga(
        olahragaId!,
        _payload(isStop: true),
      );
      
      await ApiService.updateHomeStats(
        userId: widget.penggunaId,
        tanggal: DateTime.now().toString().substring(0, 10), // yyyy-mm-dd
        kmTempuh: double.parse((totalDistance / 1000).toStringAsFixed(2)),
        kaloriTerbakar: double.parse(calories.toStringAsFixed(0)),
        durasiOlahraga: elapsedTime.inMinutes,
        langkahHarian: gpsLog.length, // estimasi langkah
        beratBadan: 65, // optional
      );
      
      Navigator.pop(context);
    }
  }

  Map<String, dynamic> _payload({bool isStop = false}) {
  return {
    "jarak": double.parse((totalDistance / 1000).toStringAsFixed(2)),
    "kalori_terbakar": double.parse(calories.toStringAsFixed(2)),
    "kecepatan_rata_rata": double.parse(avgSpeed.toStringAsFixed(2)),
    "koordinat_gps": jsonEncode(gpsLog),
    if (isStop)
      "total_jarak": double.parse((totalDistance / 1000).toStringAsFixed(2)),
      "status": "Selesai",
      "waktu_selesai":
          DateTime.now().millisecondsSinceEpoch ~/ 1000,
  };
}


  String _format(Duration d) =>
      "${d.inMinutes.toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}";

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    if (currentPosition == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Stack(
          children: [
            _map(),
            _header(),
            _infoCard(),
          ],
        ),
      ),
    );
  }

  Widget _map() => FlutterMap(
        options: MapOptions(
          center: currentPosition!,
          zoom: 16,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          ),
          PolylineLayer(
            polylines: [
              Polyline(points: route, color: Colors.grey, strokeWidth: 4),
            ],
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: currentPosition!,
                width: 40,
                height: 40,
                child: const Icon(Icons.navigation, color: Colors.red),
              ),
            ],
          ),
        ],
      );

  Widget _header() => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const CircleAvatar(
                child: Icon(Icons.lock),
              ),
              const Spacer(),
              Text(
                widget.jenisOlahraga,
                style: const TextStyle(color: Colors.black,fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              const Chip(label: Text("GPS")),
            ],
          ),
        ),
      );

  Widget _infoCard() => Positioned(
        bottom: 30,
        left: 16,
        right: 16,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Text(
                _format(elapsedTime),
                style:
                    const TextStyle(color: Colors.black,fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _stat("KM", (totalDistance / 1000).toStringAsFixed(2)),
                  _stat("KCAL", calories.toStringAsFixed(0)),
                  _stat("KM/J", avgSpeed.toStringAsFixed(1)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _btn(Icons.pause, Colors.orange, _togglePause),
                  _btn(Icons.stop, Colors.red, _confirmStop),
                ],
              ),
            ],
          ),
        ),
      );

  Widget _btn(IconData i, Color c, VoidCallback f) => CircleAvatar(
        backgroundColor: c,
        child: IconButton(
          icon: Icon(i, color: Colors.white),
          onPressed: f,
        ),
      );

  Widget _stat(String l, String v) => Column(
        children: [
          Text(v, style: const TextStyle(color: Colors.black,fontWeight: FontWeight.bold)),
          Text(l, style: const TextStyle(color: Colors.black,fontSize: 12)),
        ],
      );
}
