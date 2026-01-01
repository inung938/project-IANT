import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';

import '../services/api_service.dart';
import 'rencana_olahraga.dart';
import 'rencana_detail.dart';
import 'daftar_olahraga.dart';
import 'detail_kalori_screen.dart';
import 'detail_langkah_screen.dart';
import 'detail_jarak_screen.dart';
import 'detail_waktu_aktivitas_screen.dart';
import 'berat_badan_screen.dart';
import '../models/rencanaOlahraga.dart';

class HomeScreen extends StatefulWidget {
  final int penggunaId;
  const HomeScreen({super.key, required this.penggunaId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {

  late final AnimationController _ctrl;
  double kmTarget = 0;
  double kaloriTarget = 0;
  double durasiTarget = 0;
  double targetKm = 0;
  double targetKalori = 0;
  double targetDurasi = 0;
  double kmHarian = 0;
  double kaloriHarian = 0;
  double durasiHarian = 0;

  int langkahHarian = 0;
  double beratBadan = 0;
  RencanaOlahraga? rencanaAktif;
  bool isLoading = true;
  bool riwayatOlahraga = false;
  // 🔥 TANGGAL AKTIF (SATU-SATUNYA)
  DateTime activeDate = DateTime.now();
  String _hariSingkat(int weekday) {
    const map = {
      DateTime.monday: 'Sen',
      DateTime.tuesday: 'Sel',
      DateTime.wednesday: 'Rab',
      DateTime.thursday: 'Kam',
      DateTime.friday: 'Jum',
      DateTime.saturday: 'Sab',
      DateTime.sunday: 'Min',
    };
    return map[weekday]!;
  }

  @override
  bool get wantKeepAlive => true;
  
  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _initData();
    fetchOlahragaUser();
  }

  Future<void> _initData() async {
    await _prepareHomeStats();           // 1️⃣ create/get HomeStats hari ini
    await fetchRencanaTerbaru();         // 2️⃣ ambil rencana aktif

    if (rencanaAktif != null) {
      await fetchProgressHarian(activeDate); // 3️⃣ ambil progress → update chart
    }

 }


  Future<void> _prepareHomeStats() async {
    final result = await ApiService.createHomeStatsIfNotExist(
      widget.penggunaId,
      activeDate,
    );
    debugPrint("🧪 createHomeStats: $result");


    await fetchProgressHarian(activeDate);
  }

  Future<void> fetchProgressHarian(DateTime date) async {
    try {
      setState(() {
        kmTarget = 0;
        kaloriTarget = 0;
        durasiTarget = 0;
      });

      _ctrl.reset();

      if (rencanaAktif == null) return;

      final tanggal = DateFormat('yyyy-MM-dd').format(date);
      final int userId = widget.penggunaId;

      final result = await ApiService.fetchHomeStats(
        userId,
        tanggal,
      );

      if (result != null) {
        final kmProgress = rencanaAktif!.targetKm > 0
            ? (result.kmTempuh / rencanaAktif!.targetKm)
            : 0.0;

        final kaloriProgress = rencanaAktif!.targetKalori > 0
            ? (result.kaloriTerbakar / rencanaAktif!.targetKalori)
            : 0.0;

        final durasiProgress = rencanaAktif!.durasiHarian > 0
            ? (result.durasiOlahraga / rencanaAktif!.durasiHarian)
            : 0.0;

        setState(() {
          kmHarian = result.kmTempuh.toDouble();
          kaloriHarian = result.kaloriTerbakar.toDouble();
          durasiHarian = result.durasiOlahraga.toDouble();
    
          beratBadan = result.beratBadan;
          kmTarget = kmProgress.clamp(0.0, 1.0);
          kaloriTarget = kaloriProgress.clamp(0.0, 1.0);
          durasiTarget = durasiProgress.clamp(0.0, 1.0);

          targetKm = rencanaAktif!.targetKm;
          targetKalori = rencanaAktif!.targetKalori;
          targetDurasi = rencanaAktif!.durasiHarian.toDouble();
          
          debugPrint("📅 tanggal: $tanggal");
          debugPrint("📊 kmTempuh: ${result.kmTempuh}");
          debugPrint("📊 kalori: ${result.kaloriTerbakar}");
          debugPrint("📊 durasi: ${result.durasiOlahraga}");
        });

        _ctrl.forward(from: 0);
      }
    } catch (e) {
      debugPrint("❌ fetchProgressHarian error: $e");
      
    }
  }

  // Future<void> fetchHomeStatsData() async {
  //   final int userId = widget.penggunaId;
  //   final homeStats = await ApiService.fetchHomeStats(userId);

  //   if (homeStats != null) {
  //     setState(() {
  //       kmTarget = homeStats.kmTempuh / 100.0;
  //       kaloriTarget = homeStats.kaloriTerbakar / 1000.0;
  //       durasiTarget = homeStats.durasiOlahraga / 30.0;
  //       langkahHarian = homeStats.langkahHarian;
  //       beratBadan = homeStats.beratBadan;
  //     });
  //   }
  // }

  Future<void> fetchRencanaTerbaru() async {
    try {
      final result = await ApiService.getLatestRencana(widget.penggunaId);

      setState(() {
        rencanaAktif = result; // bisa null
        isLoading = false;
      });

       // 🔥 PASTIKAN dipanggil SETELAH rencana ada
      if (rencanaAktif != null) {
        await fetchProgressHarian(activeDate);
      }
    } catch (e) {
      setState(() {
        rencanaAktif = null;
        isLoading = false;
      });
    }
  }

  Future<void> fetchOlahragaUser() async {
    try {
      final list = await ApiService().getOlahragaUser(widget.penggunaId);

      if (list.isNotEmpty) {
        riwayatOlahraga = true;
      } else {
        setState(() {
          riwayatOlahraga = false;
        });
      }
    } catch (e) {
      debugPrint("❌ getOlahragaUser error: $e");
      setState(() {
        riwayatOlahraga = false;
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // ================= UI Cards =================
  Widget buildCardBuatRencana() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300, width: 2),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Buat rencana olahraga pertama Anda!",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A354B)),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        instantRoute(
                            RencanaOlahragaScreen(
                                penggunaId: widget.penggunaId)));
                  },
                  child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      "Buat",
                      style: TextStyle(
                        color: Color(0xFF1A354B),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      width: 32, // panjang garis
                      child: Divider(
                        thickness: 1,
                        color: Color(0xFF1A354B),
                        height: 0,
                      ),
                    ),
                  ],
                ),
                ),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/images/gambar4.jpg',
              width: 100,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCardRencanaAktif() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300, width: 2),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                instantRoute(
                  RencanaDetailScreen(
                    penggunaId: widget.penggunaId,  
                    rencana: rencanaAktif!,
                ),
                ),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "Rencana Olahraga",
                  style: TextStyle(
                    color: Color(0xFF1A354B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Color(0xFF1A354B),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          // Kalender Mingguan
          buildKalenderMingguan(),
          const SizedBox(height: 16),
          const Text("Olahraga yang Disarankan",
              style: TextStyle(color: Color(0xFF1A354B))),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              buildIconOlahraga(icon: Icons.directions_run, label: "Berlari"),
              buildIconOlahraga(icon: Icons.directions_bike, label: "Bersepeda"),
              buildIconOlahraga(icon: Icons.directions_walk, label: "Berjalan"),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget buildIconOlahraga({required IconData icon, required String label}) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent,
            border: Border.all(color: const Color(0xFFFF9800), width: 2),
          ),
          child: Icon(icon, color: const Color(0xFFFF9800), size: 28),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: Color(0xFF1A354B), fontSize: 12)),
      ],
    );
  }

  Widget buildKalenderMingguan() {
    final today = DateTime.now();
    final startWeek = today.subtract(Duration(days: today.weekday - 1));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final date = startWeek.add(Duration(days: i));
        final hari = _hariSingkat(date.weekday);

        final isToday =
            date.day == today.day && date.month == today.month && date.year == today.year;

        final isHariOlahraga =
            rencanaAktif?.hariOlahraga.contains(hari) ?? false;

        return GestureDetector(
           onTap: () {
            if (!isHariOlahraga) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Tidak ada rencana olahraga di hari ini"),
                ),
              );
              return;
            }

            setState(() => activeDate = date);
            fetchProgressHarian(date); // ✅ PASTI TERPANGGIL
            fetchOlahragaUser();
          },
          child: Column(
            children: [
              Text(hari, style: const TextStyle(color: Color(0xFF1A354B))),
              const SizedBox(height: 6),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isToday ? Colors.orange : Colors.grey.shade700,
                  shape: BoxShape.circle,
                ),
                child: Center(
                    child: Text("${date.day}", style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)))),
              ),
              const SizedBox(height: 4),
              if (isHariOlahraga)
                Column(
                  children: const [
                    Icon(Icons.circle, size: 6, color: Colors.orange),
                  ],
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget buildDaftarOlahragaCard() {
    if (riwayatOlahraga == false) {
      /// 🔹 TAMPILAN PERTAMA (BELUM ADA DATA)
      return GestureDetector(
        onTap: () {
          Navigator.push(
          context,
          instantRoute(
            DaftarOlahragaScreen(
              penggunaId: widget.penggunaId,
            ),
          ),
        );
        },
        child: FeatureCard(
          icon: Ionicons.fitness_outline,
          title: "Daftar Olahraga",
          subtitle: "Tidak ada rekaman data\nAyo mulai!",
          showButton: true,
          borderColor: Colors.grey.shade300,
        ),
      );
    }

    /// 🔹 TAMPILAN KEDUA (SUDAH ADA DATA)
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          instantRoute(
            DaftarOlahragaScreen(
              penggunaId: widget.penggunaId,
            ),
          ),
        );

      },
      child: FeatureCard(
        icon: Ionicons.fitness_outline,
        title: "Daftar Olahraga",
        subtitle:
            "Klik untuk melihat riwayat olahraga",
        showButton: false,
        trailingIcon: Icons.arrow_forward_ios,
        borderColor: Colors.grey.shade300,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    const bg = Color(0xFFFFFFFF);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: bg,
        elevation: 0,
        title: Row(
          children: [
          Image.asset(
            'assets/images/logo.PNG',
            width: 50,
            height: 50,
          ),
          const Text(
            'IANT',
            style: TextStyle(
              color: Color(0xFF1A354B),
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Progress Card dengan border
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade300, width: 2),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 170,
                    height: 200,
                    child: AnimatedBuilder(
                      animation: _ctrl,
                      builder: (context, _) {
                        return CustomPaint(
                          painter: MultiCirclePainter(
                            kmProgress: kmTarget * _ctrl.value,
                            kaloriProgress: kaloriTarget * _ctrl.value,
                            durasiProgress: durasiTarget * _ctrl.value,
                          ),
                        );
                      },
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProgressDetailRow(
                        dotColor: const Color(0xFFFFC107),
                        label: 'KM',
                        value: kmHarian.toStringAsFixed(1),
                        unit: '/${targetKm.toStringAsFixed(1)} km',
                      ),
                      const SizedBox(height: 10),
                      ProgressDetailRow(
                        dotColor: const Color(0xFFE53935),
                        label: 'KALORI',
                        value: kaloriHarian.toStringAsFixed(0),
                        unit: '/${targetKalori.toStringAsFixed(0)} kcal',
                      ),
                      const SizedBox(height: 10),
                      ProgressDetailRow(
                        dotColor: const Color(0xFF1E88E5),
                        label: 'DURASI OLAHRAGA',
                        value: durasiHarian.toStringAsFixed(0),
                        unit: '/${targetDurasi.toStringAsFixed(0)} menit',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 🔹 Rencana Card dengan border
            if (isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (rencanaAktif == null)
              buildCardBuatRencana()
            else
              buildCardRencanaAktif(),

            const SizedBox(height: 20),

            // 🔹 Grid Feature dengan border di setiap card
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              childAspectRatio: 1,
              children: [
                buildDaftarOlahragaCard(),

                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      instantRoute(
                        BeratBadanScreen(
                          penggunaId: widget.penggunaId,
                        ),
                      ),
                    );
                  },
                  child: FeatureCard(
                    icon: Ionicons.barbell_outline,
                    title: "Berat Badan",
                    subtitle: "$beratBadan kg",
                    trailingIcon: Icons.arrow_forward_ios,
                    borderColor: Colors.grey.shade300,
                  ),
                ),

                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      instantRoute(
                        KaloriDetailScreen(
                          penggunaId: widget.penggunaId,
                        ),
                      ),
                    );
                  },
                  child: FeatureCard(
                    icon: Ionicons.flame_outline,
                    title: "Kalori Terbakar",
                    subtitle: "${kaloriHarian.toStringAsFixed(0)} kcal",
                    trailingIcon: Icons.arrow_forward_ios,
                    borderColor: Colors.grey.shade300,
                  ),
                ),

                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      instantRoute(
                        LangkahDetailScreen(
                          penggunaId: widget.penggunaId,
                        ),
                      ),
                    );
                  },
                  child: FeatureCard(
                    icon: Ionicons.footsteps_outline,
                    title: "Langkah harian",
                    subtitle: "$langkahHarian langkah",
                    trailingIcon: Icons.arrow_forward_ios,
                    borderColor: Colors.grey.shade300,
                  ),
                ),

                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      instantRoute(
                        JarakDetailScreen(
                          penggunaId: widget.penggunaId,
                        ),
                      ),
                    );
                  },
                  child: FeatureCard(
                    icon: Ionicons.navigate_outline,
                    title: "Jarak Tempuh",
                    subtitle: "${(kmTarget * 100).toStringAsFixed(1)} km",
                    trailingIcon: Icons.arrow_forward_ios,
                    borderColor: Colors.grey.shade300,
                  ),
                ),
              
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      instantRoute(
                        WaktuAktivitasDetailScreen(
                          penggunaId: widget.penggunaId,
                        ),
                      ),
                    );
                  },
                  child: FeatureCard(
                    icon: Ionicons.time_outline,
                    title: "Waktu Aktivitas",
                    subtitle: "${(durasiTarget * 30).toStringAsFixed(0)} menit",
                    trailingIcon: Icons.arrow_forward_ios,
                    borderColor: Colors.grey.shade300,
                  ),
                ),

              ],
            ),
          ],
        ),
      ),

    );

  }
}

// ===== Helper Classes =====
class ProgressDetailRow extends StatelessWidget {
  final Color dotColor;
  final String label;
  final String value;
  final String unit;

  const ProgressDetailRow({
    required this.dotColor,
    required this.label,
    required this.value,
    required this.unit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.only(top: 6),
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFF1A354B))),
            Row(
              children: [
                Text(value,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A354B))),
                const SizedBox(width: 6),
                Text(unit,
                    style: const TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
          ],
        )
      ],
    );
  }
}


class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool showButton;
  final IconData? trailingIcon;
  final Color? borderColor;

  const FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.showButton = false,
    this.trailingIcon,
    this.borderColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor ?? const Color(0xFFF5F5F5)),
      ),
      padding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          if (trailingIcon != null)
            Positioned(
              right: 0,
              top: 0,
              child: Icon(trailingIcon, size: 16, color: const Color(0xFF1A354B)),
            ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            
            children: [
              Icon(icon, size: 32, color: const Color(0xFF1A354B)),
              const SizedBox(height: 10),

              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF1A354B),
                ),
              ),
              const SizedBox(height: 6),

              Text(
                subtitle,
                style: const TextStyle(color: Colors.black54, fontSize: 12),
              ),

              if (showButton) ...[
                const SizedBox(height: 4),

                Align(
                  alignment: Alignment.centerLeft,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.55,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(6),
                      ),

                      /// 🔥 FittedBox membuat isi tombol mengecil otomatis
                      child: FittedBox(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Ionicons.fitness_outline,
                                color: Colors.white, size: 10),
                            SizedBox(width: 4),
                            Text(
                              "Pergi Berolahraga",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                /// 🔥 Tambah padding bawah agar card punya ruang ekstra
                const SizedBox(height: 4),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class MultiCirclePainter extends CustomPainter {
  final double kmProgress;
  final double kaloriProgress;
  final double durasiProgress;

  MultiCirclePainter({
    required this.kmProgress,
    required this.kaloriProgress,
    required this.durasiProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerR = min(size.width, size.height) * 0.44;
    final midR = outerR - 18;
    final innerR = midR - 18;
    const stroke = 12.0;

    final paintJarak = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = Color.fromARGB(141, 255, 204, 0);
    final paintKalori = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = Color.fromARGB(136, 253, 51, 51);
    final paintDurasi = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = Color.fromARGB(101, 0, 136, 255);

    final yellow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFFFC107);
    final red = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = const Color.fromARGB(255, 242, 9, 5);
    final blue = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF1E88E5);

    canvas.drawCircle(center, outerR, paintJarak);
    canvas.drawCircle(center, midR, paintKalori);
    canvas.drawCircle(center, innerR, paintDurasi);

    void drawArc(double radius, Paint paint, double progress, double startAngle) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      final sweep = progress * 2 * pi;
      canvas.drawArc(rect, startAngle, sweep, false, paint);
    }

    drawArc(outerR, yellow, kmProgress, -pi / 2 - 0.3);
    drawArc(midR, red, kaloriProgress, -pi / 2 + 0.5);
    drawArc(innerR, blue, durasiProgress, -pi / 2 - 1.0);

    final centerPaint = Paint()..color = const Color(0xFFF5F5F5);
    canvas.drawCircle(center, innerR - 26, centerPaint);
    final iconPaint = Paint()..color = const Color(0xFFF5F5F5);
    canvas.drawCircle(center, 6, iconPaint);
  }

  @override
  bool shouldRepaint(covariant MultiCirclePainter oldDelegate) {
    return oldDelegate.kmProgress != kmProgress ||
        oldDelegate.kaloriProgress != kaloriProgress ||
        oldDelegate.durasiProgress != durasiProgress;
  }
}

Route instantRoute(Widget page) {
  return PageRouteBuilder(
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
    pageBuilder: (_, __, ___) => page,
  );
}
