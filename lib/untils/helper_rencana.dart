int hitungTotalHariOlahraga({
  required DateTime mulai,
  required DateTime akhir,
  required List<String> hariTerpilih,
}) {
  final Map<String, int> hariMap = {
    'Sen': DateTime.monday,
    'Sel': DateTime.tuesday,
    'Rab': DateTime.wednesday,
    'Kam': DateTime.thursday,
    'Jum': DateTime.friday,
    'Sab': DateTime.saturday,
    'Min': DateTime.sunday,
  };

  final selectedWeekdays =
      hariTerpilih.map((h) => hariMap[h]!).toList();

  int total = 0;
  DateTime cursor = mulai;

  while (!cursor.isAfter(akhir)) {
    if (selectedWeekdays.contains(cursor.weekday)) {
      total++;
    }
    cursor = cursor.add(const Duration(days: 1));
  }

  return total;
}
