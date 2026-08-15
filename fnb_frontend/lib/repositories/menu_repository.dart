import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/menu_model.dart';
import '../models/price_history_model.dart';
import '../../../../core/api_config.dart';

class MenuRepository {
  Future<List<MenuModel>> getMenus() async {
    try {
      final response = await http.get(Uri.parse(ApiConfig.menus));
      
      if (response.statusCode == 200) {
        // Asumsi API mengembalikan JSON dalam bentuk list, atau object dengan key 'data'
        final dynamic decoded = json.decode(response.body);
        List<dynamic> data;
        
        if (decoded is List) {
          data = decoded;
        } else if (decoded is Map && decoded.containsKey('data')) {
          data = decoded['data'];
        } else {
          throw Exception('Format response tidak dikenali');
        }

        return data.map((json) => MenuModel.fromJson(json)).toList();
      } else {
        throw Exception('Gagal mengambil data menu: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<MenuModel> createMenu(MenuModel menu) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.menus),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: json.encode(menu.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final data = decoded is Map && decoded.containsKey('data') ? decoded['data'] : decoded;
        return MenuModel.fromJson(data);
      } else {
        throw Exception('Gagal menambah menu: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<MenuModel> updateMenu(int id, MenuModel menu) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.menus}/$id'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: json.encode(menu.toJson()),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final data = decoded is Map && decoded.containsKey('data') ? decoded['data'] : decoded;
        return MenuModel.fromJson(data);
      } else {
        throw Exception('Gagal mengubah menu: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> deleteMenu(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.menus}/$id'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Gagal menghapus menu: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<PriceHistoryModel>> getPrices(int menuId) async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.menus}/$menuId/prices'), headers: {'Accept': 'application/json'});
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        List<dynamic> data = decoded is Map && decoded.containsKey('data') ? decoded['data'] : decoded;
        return data.map((j) => PriceHistoryModel.fromJson(j)).toList();
      } else {
        throw Exception('Gagal mengambil riwayat harga');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<PriceHistoryModel> addPrice(int menuId, PriceHistoryModel price) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.menus}/$menuId/prices'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: json.encode(price.toJson()),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final data = decoded is Map && decoded.containsKey('data') ? decoded['data'] : decoded;
        return PriceHistoryModel.fromJson(data);
      } else {
        throw Exception('Gagal menambah harga: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
