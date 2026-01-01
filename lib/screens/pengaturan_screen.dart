import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PengaturanScreen extends StatefulWidget {
  const PengaturanScreen({super.key});

  @override
  State<PengaturanScreen> createState() => _PengaturanScreenState();
}

class _PengaturanScreenState extends State<PengaturanScreen> {
  bool suaraAktif = false;
  bool getarAktif = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  /// 🔹 Ambil data tersimpan
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      suaraAktif = prefs.getBool("siaran_suara") ?? false;
      getarAktif = prefs.getBool("peringatan_getar") ?? false;
    });
  }

  /// 🔹 Simpan ketika switch berubah
  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
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
        title: const Text(
          "Pengaturan",
          style: TextStyle(
            color: Color(0xFF1A354B),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            /// SETTING SIARAN SUARA
            _itemPengaturan(
              judul: "Siaran Suara",
              deskripsi: "Siaran suara informasi jarak dan waktu selama olahraga",
              value: suaraAktif,
              onChanged: (val) {
                setState(() => suaraAktif = val);
                _saveSetting("siaran_suara", val);
              },
            ),

            const SizedBox(height: 20),

            /// SETTING GETAR
            _itemPengaturan(
              judul: "Peringatan Getar",
              deskripsi: "Peringatan getar untuk informasi jarak dan waktu selama olahraga",
              value: getarAktif,
              onChanged: (val) {
                setState(() => getarAktif = val);
                _saveSetting("peringatan_getar", val);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemPengaturan({
    required String judul,
    required String deskripsi,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          /// Text kiri
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  judul,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A354B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  deskripsi,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF77808A),
                  ),
                ),
              ],
            ),
          ),

          /// Switch
          Switch(
            value: value,
            activeThumbColor: Colors.white,
            activeTrackColor: const Color(0xFF1A354B),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFBFC6CD),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
