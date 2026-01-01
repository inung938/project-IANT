import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import 'olahraga_screen.dart';
import 'targetJarak_screen.dart';
import 'pengaturan_screen.dart';
import 'cycling_screen.dart';
import 'mulai_screen.dart';

class WalkScreen extends StatefulWidget {
  final int penggunaId;
  const WalkScreen({super.key, required this.penggunaId});

  @override
  State<WalkScreen> createState() => _WalkScreenState();
}

class _WalkScreenState extends State<WalkScreen> {
  int selectedTab = 1;
  int selectedIndex = 2;

  final List<String> tabs = [
    "Berlari Di Luar Ruangan",
    "Berjalan Kaki",
    "Bersepeda",
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // 🔹 Hilangkan tombol back
        centerTitle: false,
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

            /// Tab menu navigasi
            SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 16),
                itemCount: tabs.length,
                itemBuilder: (context, index) {
                  final isActive = selectedTab == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() => selectedTab = index);

                      /// Navigasi halaman sesuai tab
                      if (index == 0) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => OlahragaScreen(penggunaId: widget.penggunaId)));
                      if (index == 1) return;
                      if (index == 2) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => CyclingScreen(penggunaId: widget.penggunaId)));
                      
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            tabs[index],
                            style: TextStyle(
                              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                              color: isActive ? const Color(0xFF1A354B) : Colors.grey.shade500,
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

            const SizedBox(height: 10),

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
                  Text(
                    "km",
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Expanded(
                    child: Text(
                      "Total Jarak Berjalan Kaki",
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Colors.black54),
                ],
              ),
            ),

            const SizedBox(height: 15),

            /// Banner Gambar diperbesar & dirapatkan
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                width: size.width,
                child: Image.asset(
                  "assets/images/gambar1.jpg",
                  height: size.height * 0.34,
                  fit: BoxFit.cover,
                ),
              ),
            ),

           /// Tombol start olahraga lebih besar + responsif
            const SizedBox(height: 18),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Tombol kiri kecil (navigasi contoh: ke halaman map / tracking)
                  GestureDetector(
                    onTap: () {
                      // ➤ Navigasi halaman target
                      
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => TargetJarakScreen(penggunaId: widget.penggunaId)),
                      );
                      
                    },
                    child: _roundIcon(
                      Ionicons.map_outline,
                    ),
                  ),

                  // Tombol tengah besar (Start olahraga)
                  GestureDetector(
                    onTap: () {
                      // ➤ Navigasi mulai workout
                      
                     Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MulaiScreen(penggunaId: widget.penggunaId, jenisOlahraga: tabs[selectedTab])
                        ),
                      );
                      
                    },
                    child: Container(
                      width: 78,
                      height: 78,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A354B), // warna utama
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1A354B).withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Ionicons.walk_outline,
                        color: Colors.white,
                        size: 35,
                      ),
                    ),
                  ),

                  // Tombol kanan kecil (Setting)
                  GestureDetector(
                    onTap: () {
                      // ➤ Navigasi halaman setting
                      
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => PengaturanScreen()),
                      );
                      
                    },
                    child: _roundIcon(
                      Ionicons.settings_outline,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),

    );
  }

  /// Icon bulat kecil
  Widget _roundIcon(IconData icon) {
    return Container(
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
      child: Icon(icon, size: 22, color: const Color(0xFF1A354B)),
    );
  }

}
