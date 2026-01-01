import 'package:flutter/material.dart';

import '../models/kalori_stats.dart';
import '../services/api_service.dart';

class KaloriDetailScreen extends StatefulWidget {
  final int penggunaId;
  const KaloriDetailScreen({super.key, required this.penggunaId});

  @override
  State<KaloriDetailScreen> createState() => _KaloriDetailScreenState();
}

class _KaloriDetailScreenState extends State<KaloriDetailScreen> {
  String selectedFilter = "day";
  bool isLoading = true;
  List<KaloriStats> data = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => isLoading = true);

    data = await ApiService.fetchKaloriHistory(
      widget.penggunaId,
      selectedFilter,
    );

    setState(() => isLoading = false);
  }

  double get totalKalori =>
    data.fold<double>(0.0, (sum, KaloriStats item) => sum + item.kalori);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      appBar: AppBar(
        title: const Text("Kalori Terbakar"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _filterBar(),
            const SizedBox(height: 16),

            // TOTAL
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:  Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text("Total Kalori",
                      style: TextStyle(fontSize: 14, color: Colors.black)),
                  const SizedBox(height: 8),
                  Text(
                    "${totalKalori.toStringAsFixed(0)} kcal",
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
                          itemBuilder: (_, i) {
                            final item = data[i];
                            return _item(item);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= UI PART =================

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

  Widget _item(KaloriStats item) => Card(
        color: Colors.grey.shade200,
        child: ListTile(
          leading: const Icon(Icons.local_fire_department,
              color: Colors.orange),
          title: Text(
            "${item.kalori.toStringAsFixed(0)} kcal",
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          subtitle: Text(
            "${item.tanggal.day}-${item.tanggal.month}-${item.tanggal.year}",
            style: const TextStyle(color: Colors.black),
          ),
        ),
      );

  Widget _emptyState() => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_fire_department_outlined,
                size: 60, color: Colors.grey),
            SizedBox(height: 12),
            Text("Belum ada data kalori", style: TextStyle(color: Colors.black)),
          ],
        ),
      );
}
