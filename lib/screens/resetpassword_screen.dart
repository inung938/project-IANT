import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final int userId;   // didapat dari hasil verifikasi OTP
  final String email; // untuk info & verifikasi tambahan kalau perlu

  const ResetPasswordScreen({
    super.key,
    required this.userId,
    required this.email,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController newPassCtrl = TextEditingController();
  final TextEditingController confirmPassCtrl = TextEditingController();

  bool hideNewPass = true;
  bool hideConfirmPass = true;
  bool isLoading = false;
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
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
                "Atur ulang kata sandi",
                style: TextStyle(
                  fontSize: 28,
                  color: Color(0xFF272D34),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Ubah kata sandi untuk akun\n${widget.email}",
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1A354B),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),

              // 🔹 Alert error
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

              _inputField(
                label: "Password baru",
                controller: newPassCtrl,
                obscure: hideNewPass,
                onToggle: () {
                  setState(() => hideNewPass = !hideNewPass);
                },
              ),
              const SizedBox(height: 16),
              _inputField(
                label: "Konfirmasi password baru",
                controller: confirmPassCtrl,
                obscure: hideConfirmPass,
                onToggle: () {
                  setState(() => hideConfirmPass = !hideConfirmPass);
                },
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _onSubmit,
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Simpan password",
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required String label,
    required TextEditingController controller,
    bool obscure = false,
    VoidCallback? onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF1A354B),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          onChanged: (_) => setState(() => errorMessage = null),
          style: const TextStyle(color: Color(0xFF272D34)),
          decoration: InputDecoration(
            hintText: label,
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: const Color(0xFFFFFFFF),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFD4D4D4),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFD4D4D4),
                width: 1.5,
              ),
            ),
            suffixIcon: onToggle == null
                ? null
                : IconButton(
                    icon: Icon(
                      obscure ? Icons.visibility_off : Icons.visibility,
                      color: const Color(0xFF272D34),
                    ),
                    onPressed: onToggle,
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _onSubmit() async {
    final newPass = newPassCtrl.text.trim();
    final confirm = confirmPassCtrl.text.trim();

    if (newPass.isEmpty || confirm.isEmpty) {
      setState(() {
        errorMessage = "Semua field harus diisi.";
      });
      return;
    }

    if (newPass.length < 6) {
      setState(() {
        errorMessage = "Password minimal 6 karakter.";
      });
      return;
    }

    if (newPass != confirm) {
      setState(() {
        errorMessage = "Password baru dan konfirmasi tidak sama.";
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // panggil API reset password (kamu buat di ApiService)
      final res = await ApiService.resetPassword(
        userId: widget.userId,
        email: widget.email,
        newPassword: newPass,
      );

      setState(() => isLoading = false);

      if (res["success"] == true) {
        // Berhasil: tampilkan snackbar + kembali ke Login
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Password berhasil diubah. Silakan login kembali."),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      } else {
        setState(() {
          errorMessage = res["message"] ?? "Gagal mengubah password.";
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Terjadi kesalahan: $e";
      });
    }
  }
}
