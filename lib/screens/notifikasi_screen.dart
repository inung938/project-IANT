import 'package:flutter/material.dart';

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  bool targetTercapai = true;
  bool langkahHarian = true;
  bool cincinVitalitas = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xFFF5F5F5),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Notifikasi",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            _item(
              title: "Peringatan untuk Pencapaian Target",
              
              value: targetTercapai,
              onChanged: (v) {
                setState(() => targetTercapai = v);
              },
            ),
            _item(
              title: "Peringatan untuk Total Langkah Hari ini",
              value: langkahHarian,
              onChanged: (v) {
                setState(() => langkahHarian = v);
              },
            ),
            _item(
              title: "Notifikasi Pencapaian Cincin Vitalitas",
              value: cincinVitalitas,
              onChanged: (v) {
                setState(() => cincinVitalitas = v);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _item({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14, // lebih kecil
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),

          /// ⬇️ switch diperkecil
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.white,
              activeTrackColor: const Color(0xFF1A354B),
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

}
