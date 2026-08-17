import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/promo_model.dart';
import '../../../../core/api_config.dart';
import '../core/token_service.dart';

class PromoRepository {
  Future<Map<String, String>> _getHeaders() async {
    final token = await TokenService.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<PromoModel>> getPromos() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(ApiConfig.promos), headers: headers);
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        List<dynamic> data = decoded is Map && decoded.containsKey('data') ? decoded['data'] : decoded;
        return data.map((json) => PromoModel.fromJson(json)).toList();
      } else {
        throw Exception('Gagal mengambil data promo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<PromoModel> getPromoById(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse('${ApiConfig.promos}/$id'), headers: headers);
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final data = decoded is Map && decoded.containsKey('data') ? decoded['data'] : decoded;
        return PromoModel.fromJson(data);
      } else {
        throw Exception('Gagal mendapatkan detail promo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<PromoModel> createPromo(PromoModel promo) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(ApiConfig.promos),
        headers: headers,
        body: json.encode(promo.toJson()),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final data = decoded is Map && decoded.containsKey('data') ? decoded['data'] : decoded;
        return PromoModel.fromJson(data);
      } else {
        throw Exception('Gagal menambah promo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<PromoModel> updatePromo(int id, PromoModel promo) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('${ApiConfig.promos}/$id'),
        headers: headers,
        body: json.encode(promo.toJson()),
      );
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final data = decoded is Map && decoded.containsKey('data') ? decoded['data'] : decoded;
        return PromoModel.fromJson(data);
      } else {
        throw Exception('Gagal mengubah promo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> deletePromo(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('${ApiConfig.promos}/$id'),
        headers: headers,
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Gagal menghapus promo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
