import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import 'targetJarak_screen.dart';
import 'pengaturan_screen.dart';
import 'mulai_screen.dart';

class OlahragaScreen extends StatefulWidget {
  final int penggunaId;
  const OlahragaScreen({super.key, required this.penggunaId});

  @override
  State<OlahragaScreen> createState() => _OlahragaScreenState();
}

class _OlahragaScreenState extends State<OlahragaScreen> {
  int selectedTab = 0;

  final List<String> tabs = [
    "Berlari Di Luar Ruangan",
    "Berjalan Kaki",
    "Bersepeda",
  ];

  /// Gambar berbeda untuk tiap olahraga
  final List<String> images = [
    "assets/images/gambar2.jpg",
    "assets/images/gambar1.jpg",
    "assets/images/gambar5.jpg",
  ];

  /// Icon tengah berbeda
  final List<IconData> icons = [
    Ionicons.walk_outline,
    Ionicons.walk_outline,
    Ionicons.bicycle_outline,
  ];

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          "Olahraga",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Color(0xFF1A354B),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// ================= TAB JENIS OLAHRAGA =================
            SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 16),
                itemCount: tabs.length,
                itemBuilder: (context, index) {
                  final isActive = selectedTab == index;
                  return GestureDetector(
                    onTap: () => setState(() => selectedTab = index),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            tabs[index],
                            style: TextStyle(
                              fontWeight:
                                  isActive ? FontWeight.w600 : FontWeight.w500,
                              color: isActive
                                  ? const Color(0xFF1A354B)
                                  : Colors.grey.shade500,
                            ),
                          ),
                          if (isActive)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              height: 3,
                              width: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A354B),
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            /// ================= KONTEN =================
            Expanded(
              child: Column(
                children: [
                  /// JARAK
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: const [
                        Text(
                          "0.00",
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A354B),
                          ),
                        ),
                        SizedBox(width: 6),
                        Text("km", style: TextStyle(color: Colors.black54)),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "Total Jarak ${tabs[selectedTab]}",
                            style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF1A354B)),
                          ),
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// ================= GAMBAR BERUBAH =================
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                      child: ClipRRect(
                        key: ValueKey(selectedTab),
                        borderRadius: BorderRadius.circular(14),
                        child: Image.asset(
                          images[selectedTab],
                          width: size.width,
                          height: size.height * 0.34,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  /// ================= TOMBOL =================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _roundIcon(
                        Ionicons.map_outline,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                TargetJarakScreen(penggunaId: widget.penggunaId),
                          ),
                        ),
                      ),

                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MulaiScreen(
                                penggunaId: widget.penggunaId,
                                jenisOlahraga: tabs[selectedTab],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: 78,
                          height: 78,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF1A354B),
                          ),
                          child: Icon(
                            icons[selectedTab],
                            color: Colors.white,
                            size: 35,
                          ),
                        ),
                      ),

                      _roundIcon(
                        Ionicons.settings_outline,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PengaturanScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ================= ICON BULAT =================
  Widget _roundIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, color: const Color(0xFF1A354B)),
      ),
    );
  }
}
