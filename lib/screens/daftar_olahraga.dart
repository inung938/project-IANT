import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import '../services/api_service.dart';
import 'detail_olahraga.dart';

class DaftarOlahragaScreen extends StatefulWidget {
  final int penggunaId;

  const DaftarOlahragaScreen({
    super.key,
    required this.penggunaId,
  });

  @override
  State<DaftarOlahragaScreen> createState() => _DaftarOlahragaScreenState();
}

class _DaftarOlahragaScreenState extends State<DaftarOlahragaScreen> {
  late Future<List<dynamic>> olahragaFuture;

  @override
  void initState() {
    super.initState();
    olahragaFuture = ApiService().getOlahragaUser(widget.penggunaId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // BACKGROUND PUTIH
      appBar: AppBar(
        backgroundColor: Colors.black, // APPBAR HITAM
        foregroundColor: Colors.white,
        title: const Text(
          "Daftar Olahraga",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: olahragaFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.black),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "Belum ada data olahraga",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }

          final data = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 12),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              return _olahragaCard(item);
            },
          );
        },
      ),
    );
  }

  Widget _olahragaCard(Map<String, dynamic> item) {
    return Card(
      color: Colors.grey.shade200, // CARD GREY
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: const Icon(
          Ionicons.fitness_outline,
          color: Colors.black,
          size: 28,
        ),
        title: Text(
          item['jenis_olahraga'] ?? '-',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          "Tanggal: ${item['tanggal_olahraga'].toString().substring(0, 10)}",
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 13,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.black,
        ),
        onTap: () {
          Navigator.push(
            context,
            instantRoute(
              DetailOlahragaScreen(
                olahragaId: item['olahraga_id'],
              ),
            ),
          );
        },
      ),
    );
  }
}

Route instantRoute(Widget page) {
  return PageRouteBuilder(
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
    pageBuilder: (_, __, ___) => page,
  );
}
