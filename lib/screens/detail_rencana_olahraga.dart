import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/rencanaOlahraga.dart';
import 'nav_screen.dart';

class DetailRencanaScreen extends StatelessWidget {
  final int penggunaId;
  final RencanaOlahraga rencana;

  const DetailRencanaScreen({super.key, required this.penggunaId, required this.rencana});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat("yyyy.MM.dd");

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔙 Header
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color:  Color(0xFF1A354B)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Detail Rencana",
                    style: TextStyle(color:  Color(0xFF1A354B), fontSize: 18),
                  )
                ],
              ),

              const SizedBox(height: 24),

              // 🏋️ Judul
              const Text(
                "Dibuat untuk Anda",
                style: TextStyle(color: Color(0xFF1A354B)),
              ),
              const SizedBox(height: 8),
              Text(
                "Berencana untuk\n${rencana.targetOlahraga}",
                style: const TextStyle(
                    color: Color(0xFF1A354B),
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),
              Text(
                "${dateFormat.format(rencana.tanggalMulai)} - ${dateFormat.format(rencana.tanggalBerakhir)}",
                style: const TextStyle(color:  Color(0xFF1A354B)),
              ),

              const SizedBox(height: 24),

              // 📦 Card info
              _infoCard("Target Olahraga", rencana.targetOlahraga),
              const SizedBox(height: 12),
              _infoCard("Durasi Harian", "${rencana.durasiHarian} menit"),

              const SizedBox(height: 24),

              // 📊 Statistik
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _stat("${rencana.hariMingguan}", "Hari", "Mingguan"),
                  _stat("${rencana.totalHari}", "Hari", "Total"),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _stat("${rencana.durasiHarian}", "menit", "Durasi Harian"),
                  _stat("${rencana.targetKalori.toInt()}", "kcal", "Konsumsi"),
                ],
              ),

              const SizedBox(height: 24),

              // 🔔 Pengingat
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Pengingat Hari Olahraga",
                      style: TextStyle(color:  Color(0xFF1A354B))),
                  Switch(
                    value: rencana.pengingatAktif,
                    onChanged: (_) {},
                    activeColor: Color(0xFF272D34),
                  )
                ],
              ),

              const SizedBox(height: 32),

              // ✅ Button selesai
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF272D34),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NavigationScreen(penggunaId: penggunaId),
                      ),
                    );
                  },
                  child: const Text("Selesai",
                      style:
                          TextStyle(color: Colors.white,fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(14)),
      child: Text("$title: $value",
          style: const TextStyle(color: Color(0xFF1A354B))),
    );
  }

  Widget _stat(String value, String unit, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$value $unit",
            style: const TextStyle(
                color: Color(0xFF1A354B),
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Color(0xFF1A354B))),
      ],
    );
  }
}
