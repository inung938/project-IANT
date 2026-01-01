import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'resetpassword_screen.dart';

class VerifyOtpScreen extends StatefulWidget {
  final int userId;
  final String email;

  const VerifyOtpScreen({
    super.key,
    required this.userId,
    required this.email,
  });

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final otpCtrl = TextEditingController();
  bool isLoading = false;
  String? errorMsg;

  @override
  Widget build(BuildContext context) {
    final isFilled = otpCtrl.text.trim().length == 6;

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
                "Masukkan Kode OTP",
                style: TextStyle(
                  fontSize: 28,
                  color: Color(0xFF272D34),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Kami telah mengirimkan kode verifikasi ke email:\n${widget.email}",
                style: const TextStyle(
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

              _otpField(),

              const SizedBox(height: 8),
              const Text(
                "Kode berlaku selama 5 menit.",
                style: TextStyle(
                  color: Color(0xFF1A354B),
                  fontSize: 12,
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading || !isFilled ? null : _verifyOtp,
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
                          "Verifikasi",
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

  Widget _otpField() {
    return TextField(
      controller: otpCtrl,
      keyboardType: TextInputType.number,
      maxLength: 6,
      onChanged: (_) => setState(() {
        errorMsg = null;
      }),
      style: const TextStyle(
        color: Colors.grey,
        letterSpacing: 4,
        fontSize: 20,
      ),
      decoration: InputDecoration(
        counterText: "",
        hintText: "••••••",
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
      textAlign: TextAlign.center,
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

  Future<void> _verifyOtp() async {
    final kode = otpCtrl.text.trim();

    if (kode.length != 6) {
      setState(() {
        errorMsg = "Kode OTP harus 6 digit.";
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMsg = null;
    });

    final res = await ApiService.verifyOtp(
      userId: widget.userId,
      email: widget.email,
      kode: kode,
    );

    if (!mounted) return;
    setState(() => isLoading = false);

    if (res["success"] == true) {
       Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(
            email: widget.email,
            userId: widget.userId,
          ),
        ),
      );
    } else {
      setState(() {
        errorMsg = res["message"] ?? "Verifikasi OTP gagal.";
      });
    }
  }
}
