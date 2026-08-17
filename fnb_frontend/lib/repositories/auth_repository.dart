import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';
import '../core/token_service.dart';
import '../models/user_model.dart';

class AuthRepository {
  Future<UserModel> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.login),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final token = decoded['access_token'];
        
        // Simpan token
        if (token != null) {
          await TokenService.saveToken(token);
        }

        final userData = decoded['user'];
        return UserModel.fromJson(userData);
      } else {
        final decoded = json.decode(response.body);
        throw Exception(decoded['message'] ?? 'Gagal login');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> logout() async {
    try {
      final token = await TokenService.getToken();
      if (token == null) return; // Sudah logout

      final response = await http.post(
        Uri.parse(ApiConfig.logout),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 401) {
        // Hapus token lokal baik jika sukses dari server atau jika token sudah tidak valid di server
        await TokenService.removeToken();
      } else {
        throw Exception('Gagal logout dari server');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
