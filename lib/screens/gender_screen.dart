import 'package:flutter/material.dart';
import 'start_screen.dart';

import '../services/api_service.dart';

class GenderScreen extends StatefulWidget {
  final int penggunaId;      // id_pengguna dari halaman sebelumnya

  const GenderScreen({
    super.key,
    required this.penggunaId,
  });

  @override
  State<GenderScreen> createState() => _GenderScreenState();
}

class _GenderScreenState extends State<GenderScreen> {
  String? selectedGender; // "Pria" atau "Wanita"
  bool isLoading = false;
  String? errorMsg;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              const Text(
                "Apa jenis kelamin Anda?",
                style: TextStyle(
                  color: Color(0xFF1A354B),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Kami menggunakan ini untuk menentukan papan peringkat mana Anda akan muncul.",
                style: TextStyle(
                  color: Color(0xFF1A354B),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 20),

              if (errorMsg != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          errorMsg!,
                          style: TextStyle(
                            color: Colors.red.shade800,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => setState(() => errorMsg = null),
                        child: Icon(Icons.close, size: 18, color: Colors.red.shade800),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 10),

              _genderOption("Pria"),
              const SizedBox(height: 12),
              _genderOption("Wanita"),

              const SizedBox(height: 20),

              const Text(
                "Profil Anda adalah Publik secara default.",
                style: TextStyle(
                  color: Color(0xFF1A354B),
                  fontSize: 13,
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (selectedGender == null || isLoading)
                      ? null
                      : _onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF272D34),
                    disabledBackgroundColor: Colors.grey.shade400,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 4,
                    shadowColor: Colors.black.withOpacity(0.4),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // teks tetap ada, cuma kita “tutupi” saat loading
                      const Text(
                        "Lanjutkan",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isLoading)
                        const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _genderOption(String label) {
    final bool isSelected = selectedGender == label;

    return InkWell(
      onTap: () {
        setState(() {
          selectedGender = label;
          errorMsg = null;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF272D34) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF272D34) : const Color(0xFFD4D4D4),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF1A354B),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _onSubmit() async {
    if (selectedGender == null) {
      setState(() => errorMsg = "Silakan pilih jenis kelamin terlebih dahulu.");
      return;
    }

    setState(() {
      isLoading = true;
      errorMsg = null;
    });

    final res = await ApiService.saveProfile(
      id_pengguna: widget.penggunaId,
      jenisKelamin: selectedGender!,
    );

    if (!mounted) return;

    setState(() => isLoading = false);

    if (res['success'] == true) {
      // TODO: arahkan ke halaman berikutnya
      // misal:
      // Navigator.pushReplacementNamed(context, "/next-step");
      Navigator.push(
        context,
        instantRoute(
          StartScreen(penggunaId: widget.penggunaId),
        ),
      );

    } else {
      setState(() {
        errorMsg = res['message'] ?? "Gagal menyimpan jenis kelamin.";
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
