import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transaction_model.dart';
import '../../../../core/api_config.dart';
import '../core/token_service.dart';

class TransactionRepository {
  Future<Map<String, String>> _getHeaders() async {
    final token = await TokenService.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> calculateCart(TransactionModel transaction) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${ApiConfig.transactions}/calculate'),
        headers: headers,
        body: json.encode(transaction.toJson()),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = json.decode(response.body);
        return decoded is Map<String, dynamic> && decoded.containsKey('data') ? decoded['data'] : decoded;
      } else {
        String msg = 'Gagal kalkulasi keranjang: ${response.statusCode}';
        try {
          final decoded = json.decode(response.body);
          if (decoded['message'] != null) msg = decoded['message'];
        } catch (_) {}
        throw Exception(msg);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> checkout(TransactionModel transaction) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(ApiConfig.transactions),
        headers: headers,
        body: json.encode(transaction.toJson()),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic>) {
          if (decoded.containsKey('transaction')) {
            return decoded['transaction'];
          } else if (decoded.containsKey('data')) {
            return decoded['data'];
          }
        }
        return decoded;
      } else {
        String msg = 'Gagal checkout transaksi: ${response.statusCode}';
        try {
          final decoded = json.decode(response.body);
          if (decoded['message'] != null) msg = decoded['message'];
        } catch (_) {}
        throw Exception(msg);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getInvoice(String invoiceNumber) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.transactions}/$invoiceNumber'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return decoded is Map<String, dynamic> && decoded.containsKey('data') ? decoded['data'] : decoded;
      } else {
        throw Exception('Gagal mendapatkan invoice: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
