class BeratBadanStats {
  final int statsId;
  final double berat;
  final DateTime tanggal;

  BeratBadanStats({
    required this.statsId,
    required this.berat,
    required this.tanggal,
  });

  factory BeratBadanStats.fromJson(Map<String, dynamic> json) {
    return BeratBadanStats(
      statsId: json['stats_id'],
      berat: (json['berat'] ?? json['berat_badan']).toDouble(),
      tanggal: DateTime.parse(json['tanggal']),
    );
  }
}
