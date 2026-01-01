import 'package:flutter/material.dart';

class TentangScreen extends StatelessWidget {
  const TentangScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF5F5F5),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Tentang",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 24),

            /// LOGO
            Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Image.asset(
                    "assets/images/logo.PNG", // ⬅️ ALAMAT GAMBAR SAJA
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            /// MENU
            _item(
              title: "Perjanjian Pengguna",
              onTap: () {
                // TODO: Navigator ke halaman Perjanjian Pengguna
              },
            ),
            _item(
              title: "Kebijakan Privasi",
              onTap: () {
                // TODO: Navigator ke halaman Kebijakan Privasi
              },
            ),
            _item(
              title: "Umpan Balik Pengguna",
              onTap: () {
                // TODO: Navigator ke halaman Umpan Balik
              },
            ),
            _item(
              title: "Pembaruan Versi",
              onTap: () {
                // TODO: Navigator ke halaman Pembaruan Versi
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _item({
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Colors.black,
        ),
        onTap: onTap,
      ),
    );
  }
}
