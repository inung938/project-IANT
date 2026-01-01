import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'username_nama_setup_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();
  final TextEditingController confirmCtrl = TextEditingController();

  bool hidePass = true;
  bool hideConfirm = true;
  bool isLoading = false;
  String? errorMessage; // 🔹 pesan kesalahan tampil di atas

  bool get isValidEmail =>
      emailCtrl.text.trim().endsWith('@gmail.com') &&
      emailCtrl.text.trim().contains('@');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF), // 🔹 Putih bersih
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A354B)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Buat Akun",
                style: TextStyle(
                  fontSize: 28,
                  color: Color(0xFF272D34),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // 🔹 Alert error di atas form
              if (errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Email
              _inputField(
                controller: emailCtrl,
                label: "Email",
              ),
              const SizedBox(height: 16),

              // Password
              _inputField(
                controller: passCtrl,
                label: "Buat password baru",
                obscure: hidePass,
                onToggle: () => setState(() => hidePass = !hidePass),
              ),
              const SizedBox(height: 16),

              // Confirm Password
              _inputField(
                controller: confirmCtrl,
                label: "Ulangi password anda",
                obscure: hideConfirm,
                onToggle: () => setState(() => hideConfirm = !hideConfirm),
              ),
              const SizedBox(height: 32),

              // 🔹 Tombol Daftar (tidak disable)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          setState(() => errorMessage = null);


                          if (passCtrl.text.isEmpty ||
                              confirmCtrl.text.isEmpty ||
                              emailCtrl.text.isEmpty) {
                            setState(() {
                              errorMessage = "Semua field harus diisi!";
                            });
                            return;
                          }

                          if (!isValidEmail) {
                            setState(() {
                              errorMessage =
                                  "Email tidak valid. Gunakan alamat @gmail.com";
                            });
                            return;
                          }

                          if (passCtrl.text != confirmCtrl.text) {
                            setState(() {
                              errorMessage =
                                  "Password dan konfirmasi password tidak sama!";
                            });
                            return;
                          }

                          setState(() => isLoading = true);

                          final result = await ApiService.registerUser(
                            email: emailCtrl.text.trim(),
                            password: passCtrl.text.trim(),
                          );

                          setState(() => isLoading = false);

                          if (result['success'] == true) {
                             final userId = result["userId"]; // ✅ ambil dari kunci "userId"

                              if (userId != null) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UsernameNamaSetupScreen(
                                      penggunaId: int.parse(userId.toString()), // ✅ parse ke int
                                    ),
                                  ),
                                );
                              }
                          } else {
                            setState(() {
                              errorMessage =
                                  result['message'] ?? "Gagal mendaftar.";
                            });
                          }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF272D34), // 🔹 Warna utama
                    foregroundColor: Colors.white,
                    shadowColor: Colors.black.withOpacity(0.4),
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Daftar",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
                      if (isLoading) ...[
                        const SizedBox(width: 12),
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            backgroundColor: Color(0xFF272D34),
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    text: "Dengan melanjutkan, Anda setuju pada ",
                    style: TextStyle(color: Colors.black54),
                    children: [
                      TextSpan(
                        text: "Syarat Layanan",
                        style: TextStyle(
                          color: Color(0xFF272D34),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      TextSpan(text: " dan "),
                      TextSpan(
                        text: "Kebijakan Privasi",
                        style: TextStyle(
                          color: Color(0xFF272D34),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      TextSpan(text: " kami"),
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

  // 🔹 Komponen Input Field
  Widget _inputField({
    required String label,
    required TextEditingController controller,
    bool obscure = false,
    VoidCallback? onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      onChanged: (_) => setState(() => errorMessage = null),
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        floatingLabelStyle: const TextStyle(
          color: Color(0xFF272D34),
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        filled: true,
        fillColor: const Color(0xFFFFFFFF),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFD4D4D4),
            width: 1,
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(
            color: Color(0xFF272D34),
            width: 1.5,
          ),
        ),
        suffixIcon: onToggle == null
            ? null
            : IconButton(
                icon: Icon(
                  obscure ? Icons.visibility_off : Icons.visibility,
                  color: const Color(0xFFD4D4D4),
                ),
                onPressed: onToggle,
              ),
      ),
    );
  }
}
