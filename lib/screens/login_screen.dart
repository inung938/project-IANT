import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'sendotp_screen.dart';
import 'onboarding_screen.dart';
import 'nav_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();

  bool hidePass = true;
  bool isLoading = false;
  String? errorMessage;

  bool get isValidEmail =>
      emailCtrl.text.trim().endsWith('@gmail.com') &&
      emailCtrl.text.trim().contains('@');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A354B)),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const OnboardingScreen())),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Masuk ke IANT",
                style: TextStyle(
                  fontSize: 28,
                  color: Color(0xFF272D34),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // 🔹 Alert error
              if (errorMessage != null)
                AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
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
                ),

              // Email
              _inputField(
                controller: emailCtrl,
                label: "Email",
              ),
              const SizedBox(height: 16),

              // Password
              _inputField(
                controller: passwordCtrl,
                label: "Password",
                obscure: hidePass,
                onToggle: () => setState(() => hidePass = !hidePass),
              ),

              const SizedBox(height: 8),

              // 🔹 Lupa password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // arahkan ke halaman kirim OTP / lupa password
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SendOtpScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "Lupa password?",
                    style: TextStyle(
                      color: Color(0xFF272D34),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 🔹 Tombol Masuk
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          setState(() => errorMessage = null);

                          if (emailCtrl.text.isEmpty ||
                              passwordCtrl.text.isEmpty) {
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

                          setState(() => isLoading = true);

                          try {
                            final res = await ApiService.loginUser(
                              emailCtrl.text.trim(),
                              passwordCtrl.text.trim(),
                            );

                            setState(() => isLoading = false);

                            if (res['success'] == true) {
                              final userId = res["userId"];
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Login berhasil!"),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              // TODO: Navigasi ke halaman berikut
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => NavigationScreen(penggunaId: int.parse(userId.toString()))),
                              );
                            } else {
                              setState(() {
                                errorMessage =
                                    res['message'] ?? "Login gagal.";
                              });
                            }
                          } catch (e) {
                            setState(() {
                              isLoading = false;
                              errorMessage = "Terjadi kesalahan: $e";
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF272D34),
                    foregroundColor: Colors.white,
                    shadowColor: Colors.black.withOpacity(0.4),
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Visibility(
                        visible: !isLoading,
                        maintainSize: true,
                        maintainAnimation: true,
                        maintainState: true,
                        child: const Text(
                          "Masuk",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),

                    if (isLoading)
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ],
                  )
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

  // 🔹 Input field konsisten dengan register
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
