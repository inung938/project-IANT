import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/api_service.dart';

import 'infopribadi_screen.dart';
import 'notifikasi_screen.dart';
import 'login_screen.dart';
import 'tentang_screen.dart';

class ProfileScreen extends StatefulWidget {
  final int penggunaId;
  const ProfileScreen({super.key, required this.penggunaId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  int selectedIndex = 3;

  @override
  Widget build(BuildContext context) {
    final username = ApiService.loggedUsername ?? "Pengguna";

    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              const Text(
                "Saya",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Color(0xFF27323F),
                ),
              ),

              const SizedBox(height: 25),

              // Profil Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade100,
                      border: Border.all(color: Colors.grey.shade300, width: 2),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Color(0xFF27323F),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // username tampil sebagai teks
                  Expanded(
                    child: Text(
                      username.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Color(0xFF27323F),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              menuItem(
                icon: Icons.person_outline,
                title: "Info Pribadi",
                onTap: () => Navigator.push(context, instantRoute(InfoPribadiScreen(penggunaId: widget.penggunaId))),
              ),

              menuItem(
                icon: Icons.notifications_none,
                title: "Notifikasi",
                onTap: () => Navigator.push(context, instantRoute(NotifikasiScreen())),
              ),

              menuItem(
                icon: Icons.info_outline,
                title: "Tentang",
                onTap: () => Navigator.push(context, instantRoute(TentangScreen())),
              ),

              const SizedBox(height: 24),

              menuItem(
                icon: Icons.logout,
                title: "Keluar",
                onTap: _logout,
              ),

            ],
          ),
        ),
      ),

    );
  }

  Widget menuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, width: 2),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF27323F)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Color(0xFF27323F),
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 16, color: Color(0xFF27323F)),
          ],
        ),
      ),
    );
  }

  void _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:  Color(0xFFF5F5F5),
        title: const Text("Keluar", style: TextStyle(color: Color(0xFF1A354B))),
        content: const Text("Apakah Anda yakin ingin keluar?", style: TextStyle(color: Color(0xFF1A354B))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal", style: TextStyle(color: Color(0xFF1A354B))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Keluar",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ApiService.logout();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
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
