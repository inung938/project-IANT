import 'package:flutter/material.dart';
import '../models/berat_badan_stats.dart';
import '../services/api_service.dart';

class BeratBadanScreen extends StatefulWidget {
  final int penggunaId;
  const BeratBadanScreen({super.key, required this.penggunaId});

  @override
  State<BeratBadanScreen> createState() => _BeratBadanScreenState();
}

class _BeratBadanScreenState extends State<BeratBadanScreen> {
  String selectedFilter = "day";
  bool isLoading = true;
  List<BeratBadanStats> data = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => isLoading = true);

    data = await ApiService.fetchBeratBadanHistory(
      widget.penggunaId,
      selectedFilter,
    );

    setState(() => isLoading = false);
  }

  Future<void> _submitBerat() async {
    if (_controller.text.isEmpty) return;

    final berat = double.parse(_controller.text);

    final success = await ApiService.saveBeratBadan(
      userId: widget.penggunaId,
      berat: berat,
      tanggal: DateTime.now(),
    );

    if (success) {
      _controller.clear();
      _fetchData();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      appBar: AppBar(title: const Text("Berat Badan")),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: _showInputDialog,
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _filterBar(),
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

  Widget _item(BeratBadanStats item) => Card(
    color: Colors.grey.shade200,
      child: ListTile(
        leading: const Icon(Icons.monitor_weight, color: Colors.orange),
        title: Text("${item.berat} kg", style: TextStyle(color: Colors.black)),
        subtitle: Text(
          "${item.tanggal.day}-${item.tanggal.month}-${item.tanggal.year}",
          style: TextStyle(color: Colors.black),
        ),
        onTap: () => _showEditDialog(item),
      ),
    );


  Widget _emptyState() => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.monitor_weight_outlined,
                size: 60, color: Colors.grey),
            SizedBox(height: 12),
            Text("Belum ada data berat badan", style: TextStyle(color: Colors.black)),
          ],
        ),
      );

  void _showInputDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey.shade200,
        title: const Text(
          "Input Berat Badan",
          style: TextStyle(color: Colors.black),
        ),
        content: TextField(
          controller: _controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(
            color: Colors.black, // ⬅️ WARNA TEKS
          ),
          cursorColor: Colors.black, // ⬅️ WARNA CURSOR
          decoration: InputDecoration(
            hintText: "Contoh: 65.5",
            hintStyle: TextStyle(
              color: Colors.grey.shade600, // ⬅️ WARNA HINT
            ),
            suffixText: "kg",
            suffixStyle: const TextStyle(
              color: Colors.black, // ⬅️ WARNA KG
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Batal",
              style: TextStyle(color: Colors.black),
            ),
          ),
          ElevatedButton(
            onPressed: _submitBerat,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black, // ⬅️ TOMBOL KONTRAS
            ),
            child: const Text(
              "Simpan",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }


  void _showEditDialog(BeratBadanStats item) {
    final controller =
        TextEditingController(text: item.berat.toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey.shade200,
        title: const Text(
          "Edit Berat Badan",
          style: TextStyle(color: Colors.black),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(
            color: Colors.black, // ⬅️ teks input
          ),
          cursorColor: Colors.black, // ⬅️ cursor
          decoration: InputDecoration(
            suffixText: "kg",
            suffixStyle: const TextStyle(
              color: Colors.black, // ⬅️ kg
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Batal",
              style: TextStyle(color: Colors.black),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isEmpty) return;

              final berat = double.tryParse(controller.text);
              if (berat == null) return;

              await ApiService.updateBeratBadan(
                statsId: item.statsId,
                berat: berat,
              );

              Navigator.pop(context); // ⬅️ tutup dialog
              _fetchData();            // ⬅️ refresh data
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
            ),
            child: const Text(
              "Simpan",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

}
