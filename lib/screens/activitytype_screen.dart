import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'finis_screen.dart';

class ActivityTypeScreen extends StatefulWidget {
  final int penggunaId; // kirim dari FitnessLevelScreen

  const ActivityTypeScreen({
    super.key,
    required this.penggunaId,
  });

  @override
  State<ActivityTypeScreen> createState() => _ActivityTypeScreenState();
}

class _ActivityTypeScreenState extends State<ActivityTypeScreen> {
  bool isLoading = false;
  String? errorMsg;

  // list aktivitas
  final List<Map<String, dynamic>> activities = [
    {
      "key": "berlari",
      "label": "Berlari",
      "icon": Icons.directions_run,
    },
    {
      "key": "berjalan",
      "label": "Berjalan",
      "icon": Icons.directions_walk,
    },
    {
      "key": "bersepeda",
      "label": "Bersepeda",
      "icon": Icons.directions_bike,
    },
  ];

  // yg dipilih (multi select)
  final Set<String> selectedKeys = {};

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
                "Tipe aktivitas apa yang suka\nAnda lakukan?",
                style: TextStyle(
                  color: Color(0xFF1A354B),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),

              const Text(
                "Sekilas tentang apa yang ditawarkan IANT. Ketika ingin merekam aktivitas, Anda dapat memilih lebih dari 1 jenis olahraga.",
                style: TextStyle(
                  color: Color(0xFF1A354B),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 24),

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
                        child: Icon(
                          Icons.close,
                          size: 18,
                          color: Colors.red.shade800,
                        ),
                      ),
                    ],
                  ),
                ),

              // Grid aktivitas
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1, // biar kotak
                  children: activities.map((item) {
                    final key = item["key"] as String;
                    final isSelected = selectedKeys.contains(key);

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedKeys.remove(key);
                          } else {
                            selectedKeys.add(key);
                          }
                          errorMsg = null;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF272D34)
                              : const Color(0xFFF3F3F3),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(
                              item["icon"] as IconData,
                              size: 32,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF272D34),
                            ),
                            Text(
                              item["label"] as String,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF272D34),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Button lanjutkan
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
    if (selectedKeys.isEmpty) {
      setState(() {
        errorMsg = "Silakan pilih minimal satu tipe aktivitas.";
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMsg = null;
    });

    // contoh: simpan ke kolom info_tentang / aktivitas_di_sukai dsb
    final selectedString = selectedKeys.join(", "); // "berlari, berjalan"

    final res = await ApiService.saveProfile(
      id_pengguna: widget.penggunaId,
      aktivitasFavorit: selectedString,
    );

    if (!mounted) return;
    setState(() => isLoading = false);

    if (res["success"] == true) {
      // TODO: arahkan ke halaman berikutnya
      Navigator.push(
        context,
        instantRoute(
          FinisScreen(
            penggunaId: widget.penggunaId,
          ),
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
