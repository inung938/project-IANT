import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'verifyotp_screen.dart';

class SendOtpScreen extends StatefulWidget {
  const SendOtpScreen({super.key});

  @override
  State<SendOtpScreen> createState() => _SendOtpScreenState();
}

class _SendOtpScreenState extends State<SendOtpScreen> {
  final emailCtrl = TextEditingController();
  bool isLoading = false;
  String? errorMsg;

  bool get isEmailValid =>
      emailCtrl.text.trim().isNotEmpty &&
      emailCtrl.text.trim().endsWith("@gmail.com");

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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Verifikasi Email",
                style: TextStyle(
                  fontSize: 28,
                  color: Color(0xFF272D34),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Kami akan mengirimkan kode OTP ke email Anda untuk verifikasi.",
                style: TextStyle(
                  color: Color(0xFF1A354B),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              if (errorMsg != null)
                _alertBox(
                  message: errorMsg!,
                  color: Colors.red.shade100,
                  textColor: Colors.red.shade800,
                ),

              _inputField(
                controller: emailCtrl,
                hint: "Email (gunakan @gmail.com)",
                onChanged: (_) => setState(() {
                  errorMsg = null;
                }),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _sendOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF272D34),
                    disabledBackgroundColor: const Color(0xFF272D34),
                    foregroundColor: Colors.white,
                    elevation: 6,
                    shadowColor: Colors.black.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Kirim Kode",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFFFFFFF),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    void Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.grey),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFFFFFFFF),
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
      ),
    );
  }

  Widget _alertBox({
    required String message,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12, top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: textColor, fontSize: 13),
            ),
          ),
          InkWell(
            onTap: () => setState(() => errorMsg = null),
            child: Icon(Icons.close, size: 18, color: textColor),
          ),
        ],
      ),
    );
  }

  Future<void> _sendOtp() async {
    final email = emailCtrl.text.trim();

    if (!isEmailValid) {
      setState(() {
        errorMsg = "Masukkan email @gmail.com yang valid.";
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMsg = null;
    });

    final res = await ApiService.sendOtp(email: email);

    if (!mounted) return;

    setState(() => isLoading = false);

    if (res["success"] == true) {
      final userId = res["userId"];
      // Setelah berhasil kirim, arahkan ke halaman verifikasi
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VerifyOtpScreen(
            email: email,
            userId: int.parse(userId.toString()),
          ),
        ),
      );
    } else {
      setState(() {
        errorMsg = res["message"] ?? "Gagal mengirim OTP.";
      });
    }
  }
}
