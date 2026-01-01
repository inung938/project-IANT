import 'package:flutter/material.dart';

import '../services/api_service.dart';

class InfoPribadiScreen extends StatefulWidget {
  final int penggunaId;
  const InfoPribadiScreen({super.key, required this.penggunaId});

  @override
  State<InfoPribadiScreen> createState() => _InfoPribadiScreenState();
}

class _InfoPribadiScreenState extends State<InfoPribadiScreen> {
  String jenisKelamin = "-";
  double? tinggi; 
  double? berat;
  String tglLahir = "-";
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final response = await ApiService.getUserProfile(widget.penggunaId);

      if (response["success"] == true) {
        final pengguna = response["data"]["pengguna"];

        double? tinggiDb;
        if (pengguna["tinggi_badan"] != null) {
          tinggiDb = (pengguna["tinggi_badan"] as num).toDouble();

          // ❗ BUAT TINGGI SELALU COCOK DENGAN DROPDOWN
          // Jika 170.5 → dibulatkan menjadi 171
          tinggiDb = tinggiDb.roundToDouble();
        }

        double? beratDb;
        if (pengguna["berat_badan"] != null) {
          beratDb = (pengguna["berat_badan"] as num).toDouble();
        }

        DateTime? selectedDate;
        if (pengguna["tanggal_lahir"] != null && pengguna["tanggal_lahir"] != "") {
          try {
            selectedDate = DateTime.parse(pengguna["tanggal_lahir"]);
            tglLahir =
                "${selectedDate.day.toString().padLeft(2, '0')} "
                "${_bulan(selectedDate.month)} "
                "${selectedDate.year}";
          } catch (e) {
            print("Format tanggal error: $e");
          }
        }

        setState(() {
          jenisKelamin = pengguna["jenis_kelamin"] ?? "-";
          tinggi = tinggiDb;
          berat = beratDb;
          tglLahir = pengguna["tanggal_lahir"] ?? "-";
        });
      }
    } catch (e) {
      print("Error load profile: $e");
    }
  }

  Future<void> _updateGender(String value) async {
    await ApiService().updateUserProfile({
      "id_pengguna": widget.penggunaId,
      "jenis_kelamin": value,
    });

    Navigator.pop(context);
    setState(() => jenisKelamin = value);

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Jenis kelamin diperbarui")));
  }

  void _openGenderDialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Container(
          padding: EdgeInsets.all(20),
          height: 200,
          color: Color(0xFFF5F5F5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Jenis Kelamin",
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A354B))),
              SizedBox(height: 20),

              // Wanita
              ListTile(
                title: Text("Wanita"),
                textColor: Color(0xFF1A354B),
                trailing: Radio(
                  value: "Wanita",
                  activeColor: Color(0xFF000000),
                  groupValue: jenisKelamin,
                  onChanged: (val) => _updateGender(val.toString()),
                ),
              ),

              // Pria
              ListTile(
                title: Text("Pria"),
                textColor: Color(0xFF1A354B),
                trailing: Radio(
                  value: "Pria",
                  activeColor: Color(0xFF000000),
                  groupValue: jenisKelamin,
                  onChanged: (val) => _updateGender(val.toString()),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --------------------------- POPUP TINGGI ------------------------------
  void _openTinggiDialog() {
    double selected = tinggi ?? 160.0;

    // ❗ jika tinggi tidak berada dalam range 120-270, reset ke 160
    if (selected < 120 || selected > 270) selected = 160.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Container(
              padding: const EdgeInsets.all(20),
              color: Color(0xFFF5F5F5),
              height: 260,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Tinggi Badan",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF1A354B),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Color(0xFF1A354B)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: DropdownButton<double>(
                            value: selected,
                            isExpanded: true,
                            underline: SizedBox(),
                            items: List.generate(
                              150,
                              (i) {
                                double v = 120.0 + i;
                                return DropdownMenuItem(
                                  value: v,
                                  child: Text("$v"),
                                );
                              },
                            ),
                            onChanged: (value) {
                              setStateModal(() => selected = value!);
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text("Cm",
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A354B)))
                      ],
                    ),
                  ),

                  const Spacer(),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        child: const Text("Batal",
                            style: TextStyle(color: Color(0xFF1A354B))),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 20),
                      TextButton(
                        child: const Text(
                          "OK",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A354B),
                          ),
                        ),
                        onPressed: () async {
                          await ApiService().updateUserProfile({
                            'id_pengguna': widget.penggunaId,
                            'tinggi_badan': selected,
                          });

                          setState(() => tinggi = selected);

                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Tinggi badan diperbarui"),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --------------------------- POPUP BERAT BADAN ------------------------------
  void _openBeratDialog() {
    double selected = berat ?? 60.0;

    // ❗ jika berat tidak berada dalam range 40-200, reset ke 60
    if (selected < 40 || selected > 200) selected = 60.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Container(
              padding: const EdgeInsets.all(20),
              color: Color(0xFFF5F5F5),
              height: 260,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Berat Badan",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF1A354B),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Color(0xFF1A354B)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: DropdownButton<double>(
                            value: selected,
                            isExpanded: true,
                            underline: SizedBox(),
                            items: List.generate(
                              160,
                              (i) {
                                double v = 40.0 + i;
                                return DropdownMenuItem(
                                  value: v,
                                  child: Text("$v"),
                                );
                              },
                            ),
                            onChanged: (value) {
                              setStateModal(() => selected = value!);
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text("Kg",
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A354B)))
                      ],
                    ),
                  ),

                  const Spacer(),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        child: const Text("Batal",
                            style: TextStyle(color: Color(0xFF1A354B))),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 20),
                      TextButton(
                        child: const Text(
                          "OK",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A354B),
                          ),
                        ),
                        onPressed: () async {
                          await ApiService().updateUserProfile({
                            'id_pengguna': widget.penggunaId,
                            'berat_badan': selected,
                          });

                          setState(() => berat = selected);

                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Berat badan diperbarui"),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openTanggalLahirDialog() {
    DateTime initial =
        selectedDate ??
        DateTime.now().subtract(const Duration(days: 365 * 18)); // default umur 18 tahun

    showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.50,
      maxChildSize: 0.90,
      builder: (context, scrollController) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFF0F0F0),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),

              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // TITLE
                    const Text(
                      "Pilih tanggal",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1A354B),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // TANGGAL BESAR
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${initial.day} ${_bulan(initial.month)} ${initial.year}",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A354B),
                            ),
                          ),
                          const Icon(Icons.edit, color: Color(0xFF1A354B)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // KALENDER
                    Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: Colors.black,
                          onPrimary: Colors.white,
                          onSurface: Colors.black,
                        ),
                      ),
                      child: CalendarDatePicker(
                        initialDate: initial,
                        firstDate: DateTime(1950),
                        lastDate: DateTime.now(),
                        onDateChanged: (picked) {
                          setStateModal(() {
                            initial = picked;
                            selectedDate = picked;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 10),

                    // BUTTON
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          child: const Text(
                            "BATALKAN",
                            style: TextStyle(
                              color: Color(0xFF1A354B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        TextButton(
                          child: const Text(
                            "OK",
                            style: TextStyle(
                              color: Color(0xFF1A354B),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () async {
                            if (selectedDate == null) return;

                            String formatted =
                                "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}";

                            await ApiService().updateUserProfile({
                              "id_pengguna": widget.penggunaId,
                              "tanggal_lahir": formatted,
                            });

                            setState(() {
                              tglLahir = formatted;
                            });

                            Navigator.pop(context);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Tanggal lahir diperbarui"),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  },
);

  }

  String _bulan(int m) {
    const bulan = [
      "Januari",
      "Februari",
      "Maret",
      "April",
      "Mei",
      "Juni",
      "Juli",
      "Agustus",
      "September",
      "Oktober",
      "November",
      "Desember"
    ];
    return bulan[m - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Info Pribadi",
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Color(0xFF1C3C50)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1C3C50)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            _infoTile("Jenis Kelamin", jenisKelamin, _openGenderDialog),
            _infoTile("Tinggi Badan",
                tinggi != null ? "${tinggi!.toStringAsFixed(0)} cm" : "-", _openTinggiDialog),
            _infoTile("Berat Badan",
                berat != null ? "${berat!.toStringAsFixed(0)} kg" : "-", _openBeratDialog),
            _infoTile("Tanggal Lahir", tglLahir, _openTanggalLahirDialog),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(String title, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F4F6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1C3C50))),
            Row(
              children: [
                Text(value,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF78808A),
                    )),
                const Icon(Icons.chevron_right, color: Color(0xFF1C3C50)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
