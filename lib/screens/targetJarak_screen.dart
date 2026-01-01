import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class TargetJarakScreen extends StatefulWidget {
  final int penggunaId;
  const TargetJarakScreen({super.key, required this.penggunaId});

  @override
  State<TargetJarakScreen> createState() => _TargetJarakScreenState();
}

class _TargetJarakScreenState extends State<TargetJarakScreen> {
  int targetKm = 1;

  void _increment() {
    setState(() {
      targetKm++;
    });
  }

  void _decrement() {
    if (targetKm > 1) {
      setState(() {
        targetKm--;
      });
    }
  }

  void _setPreset(int km) {
    setState(() {
      targetKm = km;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Ionicons.chevron_back_outline,
            color: Color(0xFF1A354B),
          ),
        ),
        titleSpacing: -10,
        title: const Text(
          "Tetapkan target",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A354B),
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 10),

            /// Title
            const Text(
              "Target Jarak",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A354B),
              ),
            ),

            const SizedBox(height: 20),

            /// Counter
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _circleButton(Ionicons.remove_outline, _decrement),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    "$targetKm",
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A354B),
                    ),
                  ),
                ),

                _circleButton(Ionicons.add_outline, _increment),
              ],
            ),

            const SizedBox(height: 25),

            /// Preset
            Wrap(
              spacing: 15,
              runSpacing: 15,
              alignment: WrapAlignment.center,
              children: [
                _presetButton("3 Km", () => _setPreset(3)),
                _presetButton("5 Km", () => _setPreset(5)),
                _presetButton("10 Km", () => _setPreset(10)),
                _presetButton("15 Km", () => _setPreset(15)),
                _presetButton("Setengah\nMaraton", () => _setPreset(21)),
                _presetButton("Maraton\nPenuh", () => _setPreset(42)),
              ],
            ),

            const Spacer(),

            /// Mulai button
            GestureDetector(
              onTap: () {
                /*
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StartActivityPage(targetKm: targetKm),
                  ),
                );
                */
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A354B),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Center(
                  child: Text(
                    "Mulai",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  // Widget button bulat +/-
  Widget _circleButton(IconData icon, Function() onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFF1A354B),
            width: 2,
          ),
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF1A354B)),
      ),
    );
  }

  // Widget preset tombol jarak
  Widget _presetButton(String label, Function() onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color(0xFFF5F5F5),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF1A354B),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
