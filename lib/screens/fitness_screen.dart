import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'activitytype_screen.dart';

class FitnessLevelScreen extends StatefulWidget {
  final int penggunaId; // kirim dari StartScreen / sebelumnya

  const FitnessLevelScreen({
    super.key,
    required this.penggunaId,
  });

  @override
  State<FitnessLevelScreen> createState() => _FitnessLevelScreenState();
}

class _FitnessLevelScreenState extends State<FitnessLevelScreen> {
  int? selectedIndex;
  bool isLoading = false;
  String? errorMsg;

  final List<Map<String, String>> levels = [
    {
      "title": "Pemula",
      "subtitle": "Saya baru membangun kebugaran atau kembali olahraga.",
      "value": "Pemula",
    },
    {
      "title": "Menengah",
      "subtitle": "Saya bisa melakukan aktivitas mudah-sedang.",
      "value": "Menengah",
    },
    {
      "title": "Lanjutan",
      "subtitle": "Saya suka mendorong diri dengan aktivitas menantang.",
      "value": "Lanjutan",
    },
    {
      "title": "Pro",
      "subtitle": "Saya Atlet profesional.",
      "value": "Pro",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // Judul
              const Text(
                "Sampai tahap manakah\nperjalanan kebugaran Anda?",
                style: TextStyle(
                  color: Color(0xFF1A354B),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),

              const Text(
                "Orang dengan semua tingkat pengalaman memakai IANT, dari pemula hingga atlet profesional.",
                style: TextStyle(
                  color: Color(0xFF1A354B),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 20),

              if (errorMsg != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          errorMsg!,
                          style: TextStyle(
                            color: Colors.red.shade800,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => setState(() => errorMsg = null),
                        child: Icon(Icons.close,
                            size: 18, color: Colors.red.shade800),
                      ),
                    ],
                  ),
                ),

              // List pilihan level
            ...List.generate(levels.length, (index) {
              final isSelected = selectedIndex == index;
              final item = levels[index];

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                      errorMsg = null;
                    });
                  },
                  child: SizedBox(                 // ✅ bikin semua item selebar parent
                    width: double.infinity,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF272D34)
                            : const Color(0xFFF3F3F3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item["title"]!,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF272D34),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item["subtitle"]!,
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.3,
                              color: isSelected
                                  ? Colors.white.withOpacity(0.85)
                                  : const Color(0xFF272D34),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF272D34),
                    disabledBackgroundColor: const Color(0xFF272D34),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 5,
                    shadowColor: Colors.black.withOpacity(0.4),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Lanjutkan",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onContinue() async {
    if (selectedIndex == null) {
      setState(() {
        errorMsg = "Silakan pilih tahap perjalanan kebugaran Anda.";
      });
      return;
    }

    final selected = levels[selectedIndex!]["value"]!; // "Pemula", "Menengah", ...

    setState(() {
      isLoading = true;
      errorMsg = null;
    });

    final res = await ApiService.saveProfile(
      id_pengguna: widget.penggunaId,
      infoTentang: selected, // akan disimpan ke kolom info_tentang
    );

    if (!mounted) return;

    setState(() => isLoading = false);

    if (res["success"] == true) {
      // lanjut ke halaman berikutnya, misalnya Home
      Navigator.push(
        context,
        instantRoute(
          ActivityTypeScreen(penggunaId: widget.penggunaId),
        ),
      );
    } else {
      setState(() {
        errorMsg = res["message"] ?? "Gagal menyimpan data.";
      });
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
