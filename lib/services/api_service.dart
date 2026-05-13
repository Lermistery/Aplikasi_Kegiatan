import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Ganti IP ini sesuai IP komputer kamu jika pakai device fisik
  // Untuk emulator Android, gunakan 10.0.2.2
  // Untuk browser/desktop, gunakan localhost
  static const String baseUrl = 'http://localhost/KegiatanKu/api';

  // ====== AUTH ======
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> register(
    String nama,
    String email,
    String password,
    String confirmPassword,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nama': nama,
        'email': email,
        'password': password,
        'confirm_password': confirmPassword,
      }),
    );
    return jsonDecode(response.body);
  }

  // ====== KEGIATAN ======
  static Future<List<dynamic>> getKegiatan({
    int? userId,
    String? search,
  }) async {
    String url = '$baseUrl/kegiatan.php?';
    if (userId != null) url += 'user_id=$userId&';
    if (search != null && search.isNotEmpty) url += 'search=$search&';

    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body);
    return data['kegiatan'] ?? [];
  }

  // ====== DAFTAR KEGIATAN ======
  static Future<Map<String, dynamic>> daftarKegiatan(
    int userId,
    int kegiatanId,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/daftar.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': userId, 'kegiatan_id': kegiatanId}),
    );
    return jsonDecode(response.body);
  }

  // ====== RIWAYAT ======
  static Future<List<dynamic>> getRiwayat(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/riwayat.php?user_id=$userId'),
    );
    final data = jsonDecode(response.body);
    return data['riwayat'] ?? [];
  }

  // ====== STATS ======
  static Future<Map<String, dynamic>> getStats() async {
    final response = await http.get(Uri.parse('$baseUrl/stats.php'));
    return jsonDecode(response.body);
  }

  // ====== GAMIFIKASI & PROFIL ======
  static Future<Map<String, dynamic>> getUserStats(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/user_stats.php?user_id=$userId'));
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> tukarHadiah(int userId, String hadiah, int harga) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tukar_hadiah.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': userId, 'hadiah': hadiah, 'harga': harga}),
    );
    return jsonDecode(response.body);
  }
  // ====== ADMIN KEGIATAN ======
  static Future<Map<String, dynamic>> addKegiatan(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin_add_kegiatan.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    try {
      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Server PHP Error: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> updateKegiatan(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin_edit_kegiatan.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> deleteKegiatan(int kegiatanId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin_delete_kegiatan.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': kegiatanId}),
    );
    return jsonDecode(response.body);
  }
  // ====== ADMIN PENGGUNA ======
  static Future<List<dynamic>> getUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/admin_get_users.php'));
    try {
      final data = jsonDecode(response.body);
      return data['users'] ?? [];
    } catch (e) {
      throw Exception('Server PHP Error: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> updateUserRole(int id, String role) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin_update_user.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id, 'role': role}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> deleteUser(int id) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin_delete_user.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id}),
    );
    return jsonDecode(response.body);
  }

  // ====== ADMIN VERIFIKASI ======
  static Future<List<dynamic>> getPendingRegistrations() async {
    final response = await http.get(Uri.parse('$baseUrl/admin_get_registrations.php'));
    try {
      final data = jsonDecode(response.body);
      return data['registrations'] ?? [];
    } catch (e) {
      throw Exception('Server PHP Error: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> verifyRegistration(int id, String status) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin_verify_registration.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id, 'status': status}),
    );
    try {
      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Server PHP Error: ${response.body}');
    }
  }
}
