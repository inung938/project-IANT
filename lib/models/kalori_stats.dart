class KaloriStats {
  final double kalori;
  final DateTime tanggal;

  KaloriStats({
    required this.kalori,
    required this.tanggal,
  });

  factory KaloriStats.fromJson(Map<String, dynamic> json) {
    return KaloriStats(
      kalori: (json['kalori'] ?? json['kalori_terbakar'] ?? 0).toDouble(),
      tanggal: DateTime.parse(json['tanggal']),
    );
  }
}
