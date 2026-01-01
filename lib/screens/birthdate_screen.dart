import 'package:flutter/material.dart';

import 'gender_screen.dart';
import '../services/api_service.dart';

class BirthDateScreen extends StatefulWidget {
  final String namaLengkap; // dikirim dari halaman sebelumnya
  final int penggunaId;     // ✅ tambahkan id pengguna

  const BirthDateScreen({
    super.key,
    required this.namaLengkap,
    required this.penggunaId,
  });

  @override
  State<BirthDateScreen> createState() => _BirthDateScreenState();
}

class _BirthDateScreenState extends State<BirthDateScreen> {
  DateTime? selectedDate;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Judul
              Text(
                "Selamat datang, ${widget.namaLengkap.split(' ')[0]}! Kapan ulang tahun Anda?",
                style: const TextStyle(
                  color: Color(0xFF1A354B),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Kami menggunakan untuk analisa performa, menyaring papan peringkat, dan membuat pengguna berusia muda aman.",
                style: TextStyle(
                  color: Color(0xFF1A354B),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "Ulang Tahun",
                style: TextStyle(color: Color(0xFF1A354B), fontSize: 13),
              ),
              const SizedBox(height: 6),

              InkWell(
                onTap: _pickDate,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Color(0xFFD4D4D4), width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedDate == null
                            ? "Pilih tanggal lahir"
                            : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                        style: TextStyle(
                          color: selectedDate == null
                              ? Colors.grey.shade600
                              : const Color(0xFF1A354B),
                          fontSize: 15,
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down, color: Colors.black54),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),
              const Text(
                "Ulang tahun atau usia Anda tidak akan terlihat di profil Anda.",
                style: TextStyle(color: Color(0xFF1A354B), fontSize: 13),
              ),

              const Spacer(),

              // Tombol Lanjutkan
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (selectedDate == null || isLoading)
                      ? null
                      : _simpanDataProfil,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF272D34),
                    disabledBackgroundColor: Colors.grey.shade400,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Lanjutkan",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: "Pilih tanggal lahir Anda",
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _simpanDataProfil() async {
    setState(() {
      isLoading = true;
    });

    try {
      final api = ApiService();

      // ✅ Kirim data ke backend (tanggal dikirim dalam format ISO)
      final result = await api.simpanProfil({
        'id_pengguna': widget.penggunaId,
        'tanggal_lahir': selectedDate!.toIso8601String(), // ✅ kirim datetime asli
      });

      if (result['success'] == true) {
        Navigator.push(
          context,
          instantRoute(
            GenderScreen(
              penggunaId: widget.penggunaId,
            ),
          ),
        );
        
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? "Gagal menyimpan data."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Terjadi kesalahan: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}

Route instantRoute(Widget page) {
  return PageRouteBuilder(
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
    pageBuilder: (_, __, ___) => page,
  );
}
