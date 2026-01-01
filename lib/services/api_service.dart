import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

import '../models/home_stats.dart';
import '../models/rencanaOlahraga.dart';
import '../models/kalori_stats.dart';
import '../models/langkah_stats.dart';
import '../models/jarak_stats.dart';
import '../models/durasi_stats.dart';
import '../models/berat_badan_stats.dart';

class ApiService {
  static String? loggedUsername; // simpan global
  static String? token;
  static const baseUrl = "http://192.168.1.19:3000";
  // static const baseUrl = "http://localhost:3000"; 

  static Future<void> logout() async {
    loggedUsername = null;
    token = null;
  }
  
  // Tes koneksi
  static Future<String> testConnection() async {
    final url = Uri.parse("$baseUrl/api/test");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['message'];
      } else {
        return "Error: ${response.statusCode}";
      }
    } catch (e) {
      return "Failed to connect: $e";
    }
  }

  // Daftar user dan ambil ID dari backend
  static Future<Map<String, dynamic>> registerUser({
  required String email,
  required String password,
  }) async {


    final url = Uri.parse("$baseUrl/api/users/register");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "email": email.trim(),
          "password": password.trim(),
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Ambil id_pengguna dengan aman
        final userId = data['pengguna']?['id_pengguna'];
      
        final username = data['pengguna']?['username']; // 🔹 ambil username

        // Simpan ke variabel global agar bisa dipakai di layar lain
        loggedUsername = username;
        
        if (userId == null) {
          return {
            "success": false,
            "message": "ID pengguna tidak ditemukan di response backend",
            "data": data,
          };
        }

        return {
          "success": true,
          "message": data['message'] ?? "Registrasi berhasil",
          "userId": userId,
          "data": data,
        };
      } else {
        return {
          "success": false,
          "message": data['message'] ?? "Error ${response.statusCode}",
          "error": data,
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Gagal terhubung ke server: $e",
      };
    }
  }

  static Future<Map<String, dynamic>> loginUser(String email, String password) async {
    final url = Uri.parse('$baseUrl/api/users/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = json.decode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {

      final userId = data['pengguna']?['id_pengguna'];
      final username = data['pengguna']?['username']; // 🔹 ambil username

      // Simpan ke variabel global agar bisa dipakai di layar lain
      loggedUsername = username;

      if (userId == null) {
        return {
          "success": false,
          "message": "ID pengguna tidak ditemukan",
          "data": data,
        };
      }

      return {
        "success": true,
        "message": data['message'] ?? "Login berhasil",
        "userId": userId,
        "username": username, // 🔹 kirim juga kalau perlu
        "data": data,
      };
    } else {
      return {
        "success": false,
        "message": data['message'] ?? "Error ${response.statusCode}",
        "error": data,
      };
    }
  }


  // SIMPAN DATA PROFILE
  static Future<Map<String, dynamic>> saveProfile({
    required int id_pengguna,
    String? username,
    String? firstName,
    String? lastName,
    String? jenisKelamin, // "Pria" / "Wanita"
    String? infoTentang, 
    String? aktivitasFavorit, 
  }) async {
    try {
      String fullName = "";
      if (firstName != null && lastName != null) {
        fullName = "$firstName $lastName";
      }

      final response = await http.post(
        Uri.parse("$baseUrl/api/users/profile"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "id_pengguna": id_pengguna,
          "username": username,
          "nama": fullName,
          "jenis_kelamin": jenisKelamin,
          "info_tentang": infoTentang,
          "aktivitas_favorit": aktivitasFavorit,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": data["message"] ?? "Berhasil",
        };
      }

      return {
        "success": false,
        "message": data["message"] ?? "Gagal update profile",
      };
    } catch (e) {
      return {
        "success": false,
        "message": "Gagal terhubung ke server",
      };
    }
  }

  Future<Map<String, dynamic>> simpanProfil(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/users/profile"), // endpoint API kamu
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {'success': false, 'message': 'Gagal menyimpan profil'};
    }
  }

  static Future<Map<String, dynamic>> sendOtp({required String email}) async {
    final url = Uri.parse("$baseUrl/api/users/send-otp");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({"email": email}),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Ambil id_pengguna dengan aman
        final userId = data['otpCode']?['id_pengguna'];
        
        if (userId == null) {
          return {
            "success": false,
            "message": "ID pengguna tidak ditemukan di response backend",
            "data": data,
          };
        }

        return {
          "success": data["success"] == true,
          "message": data["message"] ?? "Gagal mengirim OTP",
          "userId": userId,
        };
      } else {
        return {
          "success": false,
          "message": data['message'] ?? "Error ${response.statusCode}",
          "error": data,
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Gagal koneksi server: $e",
      };
    }
  }

  static Future<Map<String, dynamic>> verifyOtp({
    required int userId,
    required String email,
    required String kode,
  }) async {
    final url = Uri.parse("$baseUrl/api/users/verify-otp");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "userId": userId,
          "email": email,
          "kode": kode,
        }),
      );

      final data = json.decode(response.body);

      return {
        "success": data["success"] == true,
        "message": data["message"] ?? "Verifikasi gagal",
      };
    } catch (e) {
      return {
        "success": false,
        "message": "Gagal koneksi server: $e",
      };
    }
  }
  
  static Future<Map<String, dynamic>> resetPassword({
  required int userId,
  required String email,
  required String newPassword,
  }) async {
    final url = Uri.parse("$baseUrl/api/users/reset-password");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "userId": userId,
          "email": email,
          "password": newPassword,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {"success": true, "message": data["message"] ?? "Berhasil."};
      } else {
        return {
          "success": false,
          "message": data["message"] ?? "Gagal reset password."
        };
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }

  static Future<HomeStats?> fetchHomeStats(
    int userId,
    String tanggal,
  ) async {
    try {
      final uri = Uri.parse("$baseUrl/api/users/home/$userId")
          .replace(queryParameters: {
        'tanggal': tanggal,
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);

        if (jsonBody['success'] == true && jsonBody['data'] != null) {
          return HomeStats.fromJson(jsonBody['data']);
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>> createHomeStats(int userId) async {
    final url = Uri.parse("$baseUrl/api/users/create-home");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "id_pengguna": userId,
          "km_tempuh": 0,
          "kalori_terbakar": 0,
          "durasi_olahraga": 0,
          "langkah_harian": 0,
          "berat_badan": 0,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {"success": true, "message": data["message"]};
      } else {
        return {"success": false, "message": data["message"] ?? "Gagal membuat HomeStats"};
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }

  static Future<HomeStats?> createHomeStatsIfNotExist(
    int userId,
    DateTime date,
  ) async {
    final tanggal = DateFormat('yyyy-MM-dd').format(date);

    final url = Uri.parse("$baseUrl/api/users/create-home-day");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "id_pengguna": userId,
          "tanggal": tanggal,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonBody = json.decode(response.body);

        if (jsonBody['success'] == true) {
          return HomeStats.fromJson(jsonBody['data']);
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>> updateHomeStats({
    required int userId,
    required String tanggal,
    required double kmTempuh,
    required double kaloriTerbakar,
    required int durasiOlahraga,
    required int langkahHarian,
    double? beratBadan,
  }) async {
    final url = Uri.parse("$baseUrl/api/users/home/$userId");

    final response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "tanggal": tanggal,
        "km_tempuh": kmTempuh,
        "kalori_terbakar": kaloriTerbakar,
        "durasi_olahraga": durasiOlahraga,
        "langkah_harian": langkahHarian,
        "berat_badan": beratBadan,
      }),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getUserProfile(int userId) async {
    final response = await http.get(Uri.parse("$baseUrl/api/users/profil/$userId"));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return {};
  }

  Future<bool> updateUserProfile(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/users/profile"),
      body: jsonEncode(data),
      headers: {"Content-Type": "application/json"},
    );

    return response.statusCode == 200;
  }

  final Map<String, String> _headers = {
    "Content-Type": "application/json",
    "Accept": "application/json",
  };

  Future<int?> startOlahraga(Map<String, dynamic> payload) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/users/olahraga"),
      headers: _headers,
      body: jsonEncode({
        "id_pengguna": payload["id_pengguna"],
        "jenis_olahraga": payload["jenis_olahraga"],
        "status": payload["status_olahraga"],
        "tanggal_olahraga": DateTime.now().toIso8601String(),
        "waktu_mulai": payload["waktu_mulai"],
        "koordinat_gps": payload["koordinat_gps"],
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data["data"]["olahraga_id"];
    }
    return null;
  }

  /// ===============================
  /// PUT : UPDATE RUTE (SYNC GPS)
  /// ===============================
  Future<bool> updateOlahraga(int olahragaId, Map<String, dynamic> payload) async {
    final response = await http.put(
      Uri.parse("$baseUrl/api/users/olahraga/$olahragaId"),
      headers: _headers,
      body: jsonEncode(payload),
    );

    return response.statusCode == 200;
  }

  /// ===============================
  /// GET : RIWAYAT OLAHRAGA USER
  /// ===============================
  Future<List<dynamic>> getOlahragaUser(int penggunaId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/api/users/olahraga/$penggunaId"),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["data"];
    }
    return [];
  }

  /// ===============================
  /// GET : DETAIL OLAHRAGA + MAP
  /// ===============================
  Future<Map<String, dynamic>?> getDetailOlahraga(int olahragaId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/api/users/olahraga-detail/$olahragaId"),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["data"];
    }
    return null;
  }

  static Future<void> createRencanaOlahraga(Map<String, dynamic> data) async {
    await http.post(
      Uri.parse("$baseUrl/api/users/rencana-olahraga"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
  }

  static Future<RencanaOlahraga?> getLatestRencana(int penggunaId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/users/rencana-olahraga/$penggunaId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData['success'] == true && jsonData['rencana'] != null) {
          return RencanaOlahraga.fromJson(jsonData['rencana']);
        } else {
          return null; // belum punya rencana
        }
      } else {
        throw Exception('Gagal memuat rencana olahraga');
      }
    } catch (e) {
      print('❌ getLatestRencana error: $e');
      return null;
    }
  }

  // ==============================
  // DELETE RENCANA
  // ==============================
  static Future<bool> deleteRencana(int rencanaId) async {
    final url = Uri.parse("$baseUrl/api/users/rencana-olahraga/$rencanaId");
    final response = await http.delete(url);
    return response.statusCode == 200;
  }

  static Future<List<KaloriStats>> fetchKaloriHistory(
    int userId,
    String filter, // day | week | month
  ) async {
    final url = Uri.parse(
      "$baseUrl/api/users/home/kalori/$userId?filter=$filter",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List data = body['data'] ?? [];

      return data.map((e) => KaloriStats.fromJson(e)).toList();
    }

    return [];
  }

  static Future<List<LangkahStats>> fetchLangkahHistory(
    int userId,
    String filter, // day | week | month
  ) async {
    final url = Uri.parse(
      "$baseUrl/api/users/home/langkah/$userId?filter=$filter",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'] as List;
      return data.map((e) => LangkahStats.fromJson(e)).toList();
    }

    return [];
  }

  static Future<List<JarakStats>> fetchJarakHistory(
    int userId,
    String filter, // day | week | month
  ) async {
    final url = Uri.parse(
      "$baseUrl/api/users/home/jarak/$userId?filter=$filter",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List list = body['data'] ?? [];

      return list.map((e) => JarakStats.fromJson(e)).toList();
    }

    return [];
  }

  static Future<List<WaktuAktivitasStats>> fetchWaktuAktivitasHistory(
    int userId,
    String filter, // day | week | month
  ) async {
    final url = Uri.parse(
      "$baseUrl/api/users/home/durasi/$userId?filter=$filter",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List list = body['data'] ?? [];

      return list
          .map((e) => WaktuAktivitasStats.fromJson(e))
          .toList();
    }

    return [];
  }

  static Future<List<BeratBadanStats>> fetchBeratBadanHistory(
    int userId,
    String filter,
  ) async {
    final url = Uri.parse(
      "$baseUrl/api/users/home/berat/$userId?filter=$filter",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List list = body['data'] ?? [];

      return list
          .map((e) => BeratBadanStats.fromJson(e))
          .toList();
    }

    return [];
  }

  static Future<bool> saveBeratBadan({
    required int userId,
    required double berat,
    required DateTime tanggal,
  }) async {
    final url = Uri.parse("$baseUrl/api/users/home/berat/$userId");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "berat_badan": berat,
        "tanggal": tanggal.toIso8601String(),
      }),
    );

    return response.statusCode == 200;
  }

  static Future<bool> updateBeratBadan({
    required int statsId,
    required double berat,
  }) async {
    final url = Uri.parse("$baseUrl/api/users/home/berat/$statsId");

    final response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "berat_badan": berat,
      }),
    );

    return response.statusCode == 200;
  }

}