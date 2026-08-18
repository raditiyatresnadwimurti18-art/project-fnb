import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/api_config.dart';
import '../core/token_service.dart';
import '../models/inventory_model.dart';

class InventoryRepository {
  Future<Map<String, String>> _getHeaders() async {
    final token = await TokenService.getToken();
    return {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Mengambil ringkasan stok seluruh menu beserta batch-batch inventory.
  Future<InventoryOverviewModel> getInventory({
    int? menuId,
    bool activeOnly = false,
  }) async {
    try {
      final queryParameters = <String, String>{
        if (menuId != null) 'menu_id': menuId.toString(),
        if (activeOnly) 'active_only': 'true',
      };
      final uri = Uri.parse(ApiConfig.inventory).replace(
        queryParameters:
            queryParameters.isEmpty ? null : queryParameters,
      );
      final response = await http.get(uri, headers: await _getHeaders());

      if (response.statusCode == 200) {
        return InventoryOverviewModel.fromJson(
          Map<String, dynamic>.from(json.decode(response.body) as Map),
        );
      }
      throw Exception('Gagal mengambil inventory: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Mengambil riwayat batch FIFO dan ringkasan stok untuk satu menu.
  Future<InventoryDetailModel> getInventoryByMenuId(int menuId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.inventory}/$menuId'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return InventoryDetailModel.fromJson(
          Map<String, dynamic>.from(json.decode(response.body) as Map),
        );
      }
      throw Exception(
        'Gagal mengambil detail inventory: ${response.statusCode}',
      );
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
