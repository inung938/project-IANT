import 'dart:async';
import 'package:flutter/material.dart';

import 'login_screen.dart';
import 'register_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<String> _images = [
    'assets/images/run.jpg',
    'assets/images/img1.jpeg',
    'assets/images/img2.jpeg',
  ];

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_currentPage < _images.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Bagian atas: gambar-gambar slide
          Expanded(
            flex: 6,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _images.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return Image.asset(
                  _images[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                );
              },
            ),
          ),

          // Bagian bawah: teks + tombol + indikator
          Expanded(
            flex: 4,
            child: Container(
              color: const Color(0xFFFFFFFF), // Warna background putih
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Indikator halaman (bulatan kecil)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _images.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: index == _currentPage ? 12 : 8,
                        height: index == _currentPage ? 12 : 8,
                        decoration: BoxDecoration(
                          color: index == _currentPage
                              ? const Color(0xFFEA4325) // aktif
                              : const Color(0xFFD4D4D4), // tidak aktif
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Teks judul
                  const Text(
                    "Selamat datang di Aplikasi IANT\n(Intelligent Activity & Navigation Track)",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF1A354B), // warna teks judul
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Teks deskripsi
                  const Text(
                    "Aplikasi ini digunakan untuk melatih kebugaran Anda.\nAyo Bergabung dengan kami.",
                    style: TextStyle(
                      color: Color(0xFF1A354B), // warna teks deskripsi
                      fontSize: 14,
                    ),
                  ),

                  const Spacer(),

                  // Tombol "Bergabung"
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const RegisterScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF272D34), // warna tombol
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        "Bergabung",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Tombol "Masuk"
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()),
                        );
                      },
                      child: const Text(
                        "Masuk",
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF272D36), // warna teks masuk
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
