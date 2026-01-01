import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import 'home_screen.dart';
import 'maps_screen.dart';
import 'olahraga_screen.dart';
import 'profil_screen.dart';

class NavigationScreen extends StatefulWidget {
  final int penggunaId;
  const NavigationScreen({super.key, required this.penggunaId});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int selectedIndex = 0;
late List<Widget> _pages;

@override
void initState() {
  super.initState();

  _pages = [
    HomeScreen(penggunaId: widget.penggunaId),
    MapScreen(penggunaId: widget.penggunaId),
    OlahragaScreen(penggunaId: widget.penggunaId),
    ProfileScreen(penggunaId: widget.penggunaId),
  ];
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    body: IndexedStack(
      index: selectedIndex,
      children: _pages,
    ),

    bottomNavigationBar: Container(
        height: 55,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
    child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildNavItem(Ionicons.home_outline, "Home", 0),
        _buildNavItem(Ionicons.map_outline, "Peta", 1),
        _buildNavItem(Ionicons.fitness_outline, "Olahraga", 2),
        _buildNavItem(Ionicons.person_outline, "Saya", 3),
      ],
    ),
  ),
  );
}

Widget _buildNavItem(IconData icon, String label, int index) {
  final isSelected = selectedIndex == index;

  return GestureDetector(
    onTap: () {
      setState(() {
        selectedIndex = index;
      });
    },
    child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFF1A354B) : Colors.grey,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF1A354B) : Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
