class JarakStats {
  final double jarakKm;
  final DateTime tanggal;

  JarakStats({
    required this.jarakKm,
    required this.tanggal,
  });

  factory JarakStats.fromJson(Map<String, dynamic> json) {
    return JarakStats(
      jarakKm: (json['jarak'] ?? json['km_tempuh'] ?? 0).toDouble(),
      tanggal: DateTime.parse(json['tanggal']),
    );
  }
}
