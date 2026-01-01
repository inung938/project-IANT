import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import '../services/api_service.dart';
import 'detail_rencana_olahraga.dart';

class RencanaOlahragaScreen extends StatefulWidget {
  final int penggunaId;

  const RencanaOlahragaScreen({super.key, required this.penggunaId});

  @override
  State<RencanaOlahragaScreen> createState() => _RencanaOlahragaScreenState();
}

class _RencanaOlahragaScreenState extends State<RencanaOlahragaScreen> {
  String targetOlahraga = "lari";
  int durasiMenit = 30;
  List<String> hariTerpilih = [];
  bool pengingatAktif = true;
  TimeOfDay waktuPengingat = const TimeOfDay(hour: 8, minute: 0);

  final TextEditingController namaController = TextEditingController();
  final TextEditingController kmController = TextEditingController();
  final TextEditingController kaloriController = TextEditingController();

  final hariList = ["Min", "Sen", "Sel", "Rab", "Kam", "Jum", "Sab"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Color(0xFF1A354B)),
        title: const Text("Rencana Olahraga",
            style: TextStyle(color: Color(0xFF1A354B))),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          /// TARGET OLAHRAGA
          const Text("Target Olahraga", style: _titleStyle),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _targetCard("Berlari", Ionicons.walk_outline, "lari"),
              _targetCard("Berjalan", Ionicons.accessibility_outline, "jalan"),
              _targetCard("Bersepeda", Ionicons.bicycle_outline, "sepeda"),
            ],
          ),

          const SizedBox(height: 30),

          /// DURASI
          const Text("Durasi Harian", style: _titleStyle),
          Slider(
            min: 20,
            max: 90,
            divisions: 7,
            value: durasiMenit.toDouble(),
            activeColor: Color(0xFF272D34),
            label: "$durasiMenit menit",
            onChanged: (v) => setState(() => durasiMenit = v.toInt()),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text("$durasiMenit menit",
                style: const TextStyle(color: Color(0xFF1A354B), fontSize: 16)),
          ),

          const SizedBox(height: 30),

          /// HARI
          const Text("Hari untuk Olahraga", style: _titleStyle),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            children: hariList.map((h) {
              final aktif = hariTerpilih.contains(h);
              return ChoiceChip(
                label: Text(h),
                selected: aktif,
                selectedColor: Color(0xFF272D34),
                backgroundColor: Colors.grey.shade300,
                labelStyle: TextStyle(
                    color: aktif ? Colors.white : Colors.grey),
                onSelected: (_) {
                  setState(() {
                    aktif ? hariTerpilih.remove(h) : hariTerpilih.add(h);
                  });
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 30),

          /// PENGINGAT
          SwitchListTile(
            title: const Text("Pengingat Hari Olahraga",
                style: TextStyle(color: Color(0xFF1A354B))),
            activeColor: Color(0xFF272D34),
            value: pengingatAktif,
            onChanged: (v) => setState(() => pengingatAktif = v),
          ),

          ListTile(
            enabled: pengingatAktif,
            title: const Text("Waktu Pengingat",
                style: TextStyle(color: Color(0xFF1A354B))),
            trailing: Text(
              waktuPengingat.format(context),
              style: const TextStyle(color: Color(0xFF1A354B)),
            ),
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: waktuPengingat,
              );
              if (picked != null) {
                setState(() => waktuPengingat = picked);
              }
            },
          ),

          const SizedBox(height: 30),

          /// TARGET TAMBAHAN
          _inputNamaRencana(namaController, "Nama Rencana"),
          _input(kmController, "Target KM"),
          _input(kaloriController, "Target Kalori"),

          const SizedBox(height: 40),

          /// SUBMIT
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF272D34),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: _submit,
              child: const Text("Buat Rencana",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ]),
      ),
    );
  }

  /// ================= LOGIC SUBMIT =================
  void _submit() async {
    final now = DateTime.now();
    final waktu = DateTime(
      now.year,
      now.month,
      now.day,
      waktuPengingat.hour,
      waktuPengingat.minute,
    );

    await ApiService.createRencanaOlahraga({
      "id_pengguna": widget.penggunaId,
      "nama_rencana": namaController.text,
      "target_km": double.tryParse(kmController.text),
      "target_kalori": double.tryParse(kaloriController.text),
      "target_durasi": durasiMenit,
      "target_olahraga": targetOlahraga,
      "tanggal_mulai": now.toIso8601String(),
      "tanggal_berakhir": now.add(const Duration(days: 30)).toIso8601String(),
      "waktu_pengingat": waktu.toIso8601String(),
      "hari_olahraga": hariTerpilih.join(","),
    });

    final rencana = await ApiService.getLatestRencana(widget.penggunaId);

    if (rencana != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DetailRencanaScreen(rencana: rencana, penggunaId: widget.penggunaId),
        ),
      );
    }
  }

  /// ================= WIDGET =================
  Widget _targetCard(String title, IconData icon, String value) {
    final aktif = targetOlahraga == value;
    return GestureDetector(
      onTap: () => setState(() => targetOlahraga = value),
      child: Container(
        width: 100,
        height: 120,
        decoration: BoxDecoration(
          color: aktif ? Color(0xFF272D34) : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: Colors.grey.shade300),
            const SizedBox(height: 10),
            Text(title,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _input(TextEditingController c, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: c,
        keyboardType: TextInputType.number,
        style: const TextStyle(color: Color(0xFF1A354B)),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          filled: true,
          fillColor: Colors.grey.shade300,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none),
        ),
      ),
    );
  }
  Widget _inputNamaRencana(TextEditingController c, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: c,
        keyboardType: TextInputType.text,
        style: const TextStyle(color: Color(0xFF1A354B)),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          filled: true,
          fillColor: Colors.grey.shade300,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none),
        ),
      ),
    );
  }
}

/// ================= STYLE =================
const _titleStyle =
    TextStyle(color: Color(0xFF1A354B), fontSize: 16, fontWeight: FontWeight.bold);
