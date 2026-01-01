class WaktuAktivitasStats {
  final int durasiMenit;
  final DateTime tanggal;

  WaktuAktivitasStats({
    required this.durasiMenit,
    required this.tanggal,
  });

  factory WaktuAktivitasStats.fromJson(Map<String, dynamic> json) {
    return WaktuAktivitasStats(
      durasiMenit: json['durasi'] ?? json['durasi_olahraga'] ?? 0,
      tanggal: DateTime.parse(json['tanggal']),
    );
  }
}
