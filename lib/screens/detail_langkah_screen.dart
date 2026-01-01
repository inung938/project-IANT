import 'package:flutter/material.dart';

import '../models/langkah_stats.dart';
import '../services/api_service.dart';

class LangkahDetailScreen extends StatefulWidget {
  final int penggunaId;
  const LangkahDetailScreen({super.key, required this.penggunaId});

  @override
  State<LangkahDetailScreen> createState() => _LangkahDetailScreenState();
}

class _LangkahDetailScreenState extends State<LangkahDetailScreen> {
  String selectedFilter = "day";
  bool isLoading = true;
  List<LangkahStats> data = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => isLoading = true);

    data = await ApiService.fetchLangkahHistory(
      widget.penggunaId,
      selectedFilter,
    );

    setState(() => isLoading = false);
  }

  int get totalLangkah =>
      data.fold<int>(0, (sum, LangkahStats item) => sum + item.langkah);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      appBar: AppBar(title: const Text("Langkah Harian")),
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
                  const Text("Total Langkah", style: TextStyle(color: Colors.black)),
                  const SizedBox(height: 8),
                  Text(
                    "$totalLangkah langkah",
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

  Widget _item(LangkahStats item) => Card(
        color: Colors.grey.shade200,
        child: ListTile(
          leading:
              const Icon(Icons.directions_walk, color: Colors.orange),
          title: Text(
            "${item.langkah} langkah",
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
            Icon(Icons.directions_walk_outlined,
                size: 60, color: Colors.grey),
            SizedBox(height: 12),
            Text("Belum ada data langkah", style: TextStyle(color: Colors.black)),
          ],
        ),
      );
}
