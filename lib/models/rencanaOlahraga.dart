class RencanaOlahraga {
  final int rencanaId;

  // ================= DATA UTAMA =================
  final String namaRencana;
  final String targetOlahraga;
  final int durasiHarian;
  final double targetKalori;
  final double targetKm;

  final DateTime tanggalMulai;
  final DateTime tanggalBerakhir;

  final DateTime? waktuPengingat;
  final List<String> hariOlahraga;

  RencanaOlahraga({
    required this.rencanaId,
    required this.namaRencana,
    required this.targetOlahraga,
    required this.tanggalMulai,
    required this.tanggalBerakhir,
    required this.hariOlahraga,
    required this.durasiHarian,
    required this.targetKalori,
    required this.targetKm,
    required this.waktuPengingat,
  });

  factory RencanaOlahraga.fromJson(Map<String, dynamic> json) {
    final hariList = json['hari_olahraga'] != null
        ? json['hari_olahraga']
            .toString()
            .split(',')
            .map((e) => e.trim())
            .toList()
        : <String>[];

    return RencanaOlahraga(
      rencanaId: json['rencana_id'],
      namaRencana: json['nama_rencana'] ?? '',
      targetOlahraga: json['target_olahraga'] ?? '',
      tanggalMulai: DateTime.parse(json['tanggal_mulai']),
      tanggalBerakhir: DateTime.parse(json['tanggal_berakhir']),
      hariOlahraga: hariList,
      durasiHarian: json['target_durasi'] ?? 0,
      targetKalori: (json['target_kalori'] ?? 0).toDouble(),
      targetKm: (json['target_km'] ?? 0).toDouble(),
      waktuPengingat: json['waktu_pengingat'] != null
          ? DateTime.parse(json['waktu_pengingat'])
          : null,
    );
  }

  // ================= TURUNAN (BUKAN DARI API) =================

  bool get pengingatAktif => waktuPengingat != null;

  int get hariMingguan => hariOlahraga.length;

  int get totalHari {
    final totalDays =
        tanggalBerakhir.difference(tanggalMulai).inDays + 1;

    return (totalDays / 7 * hariMingguan).round();
  }
}
