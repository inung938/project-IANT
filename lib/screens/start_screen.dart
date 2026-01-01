import 'package:flutter/material.dart';

import 'fitness_screen.dart';

class StartScreen extends StatelessWidget {
  final int penggunaId;
  const StartScreen({super.key, required this.penggunaId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // biar gambar benar-benar full, appBar tidak dipakai
      body: Stack(
        children: [
          // 🔹 Gambar full screen
          Positioned.fill(
            child: Image.asset(
              'assets/images/iconic.jpg', // ganti sesuai nama file kamu
              fit: BoxFit.cover,
            ),
          ),

          // 🔹 Gradient halus di bagian bawah (optional, biar text & tombol jelas)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.center,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.5),
                  ],
                ),
              ),
            ),
          ),

          // 🔹 Tombol "Ayo mulai" di bawah
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: arahkan ke halaman berikutnya (misal Home)
                      // Navigator.pushReplacementNamed(context, '/home');

                      Navigator.push(
                        context,
                        instantRoute(
                          FitnessLevelScreen(
                            penggunaId: penggunaId,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF272D34),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 4,
                      shadowColor: Colors.black.withOpacity(0.4),
                    ),
                    child: const Text(
                      "Ayo mulai",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Route instantRoute(Widget page) {
  return PageRouteBuilder(
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
    pageBuilder: (_, __, ___) => page,
  );
}
