import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../services/api_service.dart';

class DetailOlahragaScreen extends StatefulWidget {
  final int olahragaId;

  const DetailOlahragaScreen({
    super.key,
    required this.olahragaId,
  });

  @override
  State<DetailOlahragaScreen> createState() => _DetailOlahragaScreenState();
}

class _DetailOlahragaScreenState extends State<DetailOlahragaScreen> {
  Map<String, dynamic>? data;
  List<LatLng> route = [];

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    final res = await ApiService().getDetailOlahraga(widget.olahragaId);

    if (res != null) {
      final gps =
          jsonDecode(res['petaRute']['koordinat_gps']) as List<dynamic>;

      route = gps.map((e) => LatLng(e['lat'], e['lng'])).toList();

      setState(() {
        data = res;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: Colors.black),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          data!['jenis_olahraga'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          _map(),
          _info(),
        ],
      ),
    );
  }

  // ================= MAP =================
  Widget _map() => SizedBox(
        height: 300,
        child: FlutterMap(
          options: MapOptions(
            center: route.first,
            zoom: 16,
          ),
          children: [
            TileLayer(
              urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            ),
            PolylineLayer(
              polylines: [
                Polyline(
                  points: route,
                  color: Colors.grey.shade800, // SENADA
                  strokeWidth: 4,
                ),
              ],
            ),
          ],
        ),
      );

  // ================= INFO =================
  Widget _info() => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _infoCard("Jarak", "${data!['petaRute']['jarak']} km"),
            _infoCard(
                "Kalori", "${data!['petaRute']['kalori_terbakar']} kcal"),
            _infoCard("Kecepatan",
                "${data!['petaRute']['kecepatan_rata_rata']} km/j"),
          ],
        ),
      );

  Widget _infoCard(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.grey.shade200, // CARD GREY
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}