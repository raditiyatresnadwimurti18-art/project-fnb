import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transaction_model.dart';
import '../../../../core/api_config.dart';

class TransactionRepository {
  Future<Map<String, dynamic>> calculateCart(TransactionModel transaction) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.transactions}/calculate'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: json.encode(transaction.toJson()),
      );
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return decoded is Map<String, dynamic> && decoded.containsKey('data') ? decoded['data'] : decoded;
      } else {
        throw Exception('Gagal kalkulasi keranjang: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Map<String, dynamic>> checkout(TransactionModel transaction) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.transactions),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: json.encode(transaction.toJson()),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return decoded is Map<String, dynamic> && decoded.containsKey('data') ? decoded['data'] : decoded;
      } else {
        throw Exception('Gagal checkout transaksi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Map<String, dynamic>> getInvoice(String invoiceNumber) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.transactions}/$invoiceNumber'),
        headers: {'Accept': 'application/json'},
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
