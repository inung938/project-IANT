class LangkahStats {
  final int langkah;
  final DateTime tanggal;

  LangkahStats({
    required this.langkah,
    required this.tanggal,
  });

  factory LangkahStats.fromJson(Map<String, dynamic> json) {
    return LangkahStats(
      langkah: json['langkah'] ?? 0,
      tanggal: DateTime.parse(json['tanggal']),
    );
  }
}
