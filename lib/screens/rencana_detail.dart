import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/home_screen.dart';
import 'package:intl/intl.dart';

import '../models/rencanaOlahraga.dart';
import '../services/api_service.dart';
import 'nav_screen.dart';

class RencanaDetailScreen extends StatelessWidget {
  final int penggunaId;
  final RencanaOlahraga rencana;

  const RencanaDetailScreen({
    super.key,
    required this.penggunaId,
    required this.rencana,
  });

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
              // 🔙 HEADER
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF1A354B)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Detai Rencana",
                    style: TextStyle(color: Color(0xFF1A354B), fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 🏋️ JUDUL
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
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),
              Text(
                "${dateFormat.format(rencana.tanggalMulai)} - ${dateFormat.format(rencana.tanggalBerakhir)}",
                style: const TextStyle(color: Color(0xFF1A354B)),
              ),

              const SizedBox(height: 24),

              // 📦 INFO CARD
              _infoCard("Target Olahraga", rencana.targetOlahraga),
              const SizedBox(height: 12),
              _infoCard(
                "Durasi Harian",
                "${rencana.durasiHarian} menit",
              ),

              const SizedBox(height: 24),

              // 📊 STATISTIK
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
                  _stat("${rencana.targetKalori}", "kcal", "Target Kalori"),
                ],
              ),

              const SizedBox(height: 24),

              // 🔔 PENGINGAT
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Pengingat Hari Olahraga",
                    style: TextStyle(color: Color(0xFF1A354B)),
                  ),
                  Switch(
                    value: rencana.pengingatAktif,
                    onChanged: (_) {
                      // TODO: update status pengingat ke API
                    },
                    activeColor: Color(0xFF272D34),
                  ),
                ],
              ),

              const SizedBox(height: 36),

              // ❌ BATALKAN RENCANA
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        backgroundColor: Color(0XFFF5F5F5),
                        title: const Text("Batalkan Rencana", style: TextStyle(color: Color(0xFF1A354B))),
                        content: const Text(
                          "Apakah Anda yakin ingin membatalkan rencana olahraga ini?", style: TextStyle(color: Color(0xFF1A354B)),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Tidak", style: TextStyle(color: Color(0xFF1A354B))),
                          ),
                          TextButton(
                            onPressed: () async {
                              await ApiService.deleteRencana(rencana.rencanaId);

                              Navigator.pushAndRemoveUntil(
                                context,
                                instantRoute(
                                  NavigationScreen(penggunaId: penggunaId),
                                ),
                                (route) => false,
                              );
                            },

                            child: const Text(
                              "Ya, Batalkan",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text(
                    "Batalkan Rencana",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

            ],
          ),
        ),
      ),
    );
  }

  // ================= HELPER =================

  Widget _infoCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        "$title: $value",
        style: const TextStyle(color: Color(0xFF1A354B)),
      ),
    );
  }

  Widget _stat(String value, String unit, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$value $unit",
          style: const TextStyle(
            color: Color(0xFF1A354B),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Color(0xFF1A354B)),
        ),
      ],
    );
  }
}
