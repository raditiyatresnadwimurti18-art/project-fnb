import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';
import '../core/token_service.dart';
import '../models/user_model.dart';

class KasirRepository {
  Future<Map<String, String>> _getHeaders() async {
    final token = await TokenService.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<UserModel>> getKasirs() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(ApiConfig.kasir), headers: headers);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        List<dynamic> data = decoded is Map && decoded.containsKey('data') ? decoded['data'] : decoded;
        return data.map((json) => UserModel.fromJson(json)).toList();
      } else {
        throw Exception('Gagal mengambil data kasir: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<UserModel> createKasir(Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(ApiConfig.kasir),
        headers: headers,
        body: json.encode(data),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final resData = decoded is Map && decoded.containsKey('data') ? decoded['data'] : decoded;
        return UserModel.fromJson(resData);
      } else {
        throw Exception('Gagal menambah kasir: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<UserModel> getKasirById(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse('${ApiConfig.kasir}/$id'), headers: headers);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final resData = decoded is Map && decoded.containsKey('data') ? decoded['data'] : decoded;
        return UserModel.fromJson(resData);
      } else {
        throw Exception('Gagal mendapatkan detail kasir: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<UserModel> updateKasir(int id, Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('${ApiConfig.kasir}/$id'),
        headers: headers,
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final resData = decoded is Map && decoded.containsKey('data') ? decoded['data'] : decoded;
        return UserModel.fromJson(resData);
      } else {
        throw Exception('Gagal mengubah kasir: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> deleteKasir(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('${ApiConfig.kasir}/$id'),
        headers: headers,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Gagal menghapus kasir: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
