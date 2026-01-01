class HomeStats {
  final double kmTempuh;
  final double kaloriTerbakar;
  final int durasiOlahraga;
  final int langkahHarian;
  final double beratBadan;
  final DateTime tanggal;

  HomeStats({
    required this.kmTempuh,
    required this.kaloriTerbakar,
    required this.durasiOlahraga,
    required this.langkahHarian,
    required this.beratBadan,
    required this.tanggal,
  });

  factory HomeStats.fromJson(Map<String, dynamic> json) {
    return HomeStats(
      kmTempuh: (json['km_tempuh'] ?? 0).toDouble(),
      kaloriTerbakar: (json['kalori_terbakar'] ?? 0).toDouble(),
      durasiOlahraga: json['durasi_olahraga'] ?? 0,
      langkahHarian: json['langkah_harian'] ?? 0,
      beratBadan: (json['berat_badan'] ?? 0).toDouble(),
      tanggal: json['tanggal'] != null
        ? DateTime.tryParse(json['tanggal'].toString()) ?? DateTime.now()
        : DateTime.now(),

    );
  }
}