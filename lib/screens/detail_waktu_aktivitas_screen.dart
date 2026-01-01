import 'package:flutter/material.dart';

import '../models/durasi_stats.dart';
import '../services/api_service.dart';

class WaktuAktivitasDetailScreen extends StatefulWidget {
  final int penggunaId;
  const WaktuAktivitasDetailScreen({super.key, required this.penggunaId});

  @override
  State<WaktuAktivitasDetailScreen> createState() =>
      _WaktuAktivitasDetailScreenState();
}

class _WaktuAktivitasDetailScreenState
    extends State<WaktuAktivitasDetailScreen> {
  String selectedFilter = "day";
  bool isLoading = true;
  List<WaktuAktivitasStats> data = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => isLoading = true);

    data = await ApiService.fetchWaktuAktivitasHistory(
      widget.penggunaId,
      selectedFilter,
    );

    setState(() => isLoading = false);
  }

  int get totalDurasi =>
      data.fold(0, (sum, item) => sum + item.durasiMenit);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      appBar: AppBar(title: const Text("Waktu Aktivitas")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _filterBar(),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text("Total Waktu Aktivitas", style: TextStyle(color: Colors.black)),
                  const SizedBox(height: 8),
                  Text(
                    "$totalDurasi menit",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : data.isEmpty
                      ? _emptyState()
                      : ListView.builder(
                          itemCount: data.length,
                          itemBuilder: (_, i) => _item(data[i]),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= UI =================

  Widget _filterBar() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _filterButton("Harian", "day"),
          _filterButton("Mingguan", "week"),
          _filterButton("Bulanan", "month"),
        ],
      );

  Widget _filterButton(String label, String value) {
    final active = selectedFilter == value;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: active ? Colors.orange : Colors.grey.shade200,
        foregroundColor: active ? Colors.white : Colors.black,
      ),
      onPressed: () {
        selectedFilter = value;
        _fetchData();
      },
      child: Text(label),
    );
  }

  Widget _item(WaktuAktivitasStats item) => Card(
        color: Colors.grey.shade200,
        child: ListTile(
          leading: const Icon(Icons.timer, color: Colors.orange),
          title: Text("${item.durasiMenit} menit", style: TextStyle(color: Colors.black)),
          subtitle: Text(
            "${item.tanggal.day}-${item.tanggal.month}-${item.tanggal.year}",
            style: TextStyle(color: Colors.black),
          ),
        ),
      );

  Widget _emptyState() => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.timer_off, size: 60, color: Colors.grey),
            SizedBox(height: 12),
            Text("Belum ada data waktu aktivitas", style: TextStyle(color: Colors.black)),
          ],
        ),
      );
}
