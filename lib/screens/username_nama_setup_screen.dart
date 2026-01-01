import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'birthdate_screen.dart';

class UsernameNamaSetupScreen extends StatefulWidget {
  final int penggunaId; // ID user yang didapat dari proses register

  const UsernameNamaSetupScreen({super.key, required this.penggunaId});

  @override
  State<UsernameNamaSetupScreen> createState() => _UsernameNamaSetupScreenState();
}

class _UsernameNamaSetupScreenState extends State<UsernameNamaSetupScreen> {
  final usernameCtrl = TextEditingController();
  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();

  bool showConsent = false;
  bool showError = false;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Stack(
        children: [
          _mainContent(),
          if (showConsent) _consentPopup(),
        ],
      ),
    );
  }

  Widget _mainContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Siapa nama Anda?",
            style: TextStyle(
              color: Color(0xFF1A354B),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Ini bagaimana cara teman Anda temukan Anda di IANT.",
            style: TextStyle(
              color: Color(0xFF1A354B),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 30),
          _inputBox("User name", usernameCtrl),
          const SizedBox(height: 15),
          _inputBox("Nama depan", firstNameCtrl),
          const SizedBox(height: 15),
          _inputBox("Nama belakang", lastNameCtrl),
          const SizedBox(height: 20),
          const Text(
            "Profil Anda adalah Publik secara default.",
            style: TextStyle(
              color: Color(0xFF1A354B),
              fontSize: 14,
            ),
          ),
          const Spacer(),
          if (showError) _errorBanner(),
          _buttonContinue(),
        ],
      ),
    );
  }

  Widget _inputBox(String title, TextEditingController c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: Color(0xFF1A354B), fontSize: 13),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            border: Border.all(color: const Color(0xFFD4D4D4), width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: c,
            style: const TextStyle(color: Colors.black87),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buttonContinue() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading
            ? null
            : () {
                if (usernameCtrl.text.isEmpty ||
                    firstNameCtrl.text.isEmpty ||
                    lastNameCtrl.text.isEmpty) {
                  setState(() => showError = true);
                  return;
                }
                setState(() {
                  showError = false;
                  showConsent = true;
                });
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF272D34),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 6,
          shadowColor: Colors.black.withOpacity(0.3),
        ),
        child: isLoading
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Menyimpan...",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                  SizedBox(width: 12),
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                ],
              )
            : const Text(
                "Lanjutkan",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFFFFFF),
                ),
              ),
      ),
    );
  }

  Widget _errorBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "Semua field harus diisi.",
              style: TextStyle(color: Colors.red.shade800),
            ),
          ),
          InkWell(
            onTap: () => setState(() => showError = false),
            child: Icon(Icons.close, color: Colors.red.shade800),
          ),
        ],
      ),
    );
  }

  Widget _consentPopup() {
    return Container(
      color: Colors.black.withOpacity(.4),
      child: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Izinkan penggunaan data untuk mempersonalisasikan IANT Anda?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF1A354B),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Data Anda akan digunakan untuk analitik IANT yang dipersonalisasi. Anda dapat mengubah preferensi ini kapan saja.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Color(0xFF1A354B)),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _popupBtn("Tolak", false),
                  _popupBtn("Terima", true),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _popupBtn(String text, bool accepted) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: OutlinedButton(
          onPressed: () async {
            setState(() => showConsent = false);

            if (accepted) {
              // 🔹 Simpan data ke database
              final success = await _save();

              if (success && mounted) {
                // 🔹 Lanjut ke BirthDateScreen setelah sukses
                Navigator.push(
                  context,
                  instantRoute(
                    BirthDateScreen(
                      namaLengkap: "${firstNameCtrl.text} ${lastNameCtrl.text}",
                      penggunaId: widget.penggunaId, 
                    ),
                  ),
                );
              }
            }
          },
          style: OutlinedButton.styleFrom(
            backgroundColor: accepted ? const Color(0xFF272D34) : Colors.white,
            side: const BorderSide(color: Color(0xFF272D34)),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: accepted ? Colors.white : const Color(0xFF272D34),
            ),
          ),
        ),
      ),
    );
  }

  // 🔹 _save() sekarang mengembalikan boolean sukses/tidak
  Future<bool> _save() async {
    setState(() => isLoading = true);

    final res = await ApiService.saveProfile(
      id_pengguna: widget.penggunaId,
      username: usernameCtrl.text.trim(),
      firstName: firstNameCtrl.text.trim(),
      lastName: lastNameCtrl.text.trim(),
    );

    if (!mounted) return false;
    setState(() => isLoading = false);

    if (res["success"] == true) {
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFF44336),
          content: Text(res["message"] ?? "Gagal menyimpan profil",
              style: const TextStyle(color: Colors.white)),
        ),
      );
      return false;
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
