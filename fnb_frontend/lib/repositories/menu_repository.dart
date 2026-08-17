import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/menu_model.dart';
import '../models/price_history_model.dart';
import '../../../../core/api_config.dart';
import '../core/token_service.dart';

class MenuRepository {
  Future<Map<String, String>> _getHeaders({bool isMultipart = false}) async {
    final token = await TokenService.getToken();
    final headers = {
      'Accept': 'application/json',
    };
    if (!isMultipart) {
      headers['Content-Type'] = 'application/json';
    }
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<List<MenuModel>> getMenus() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(ApiConfig.menus), headers: headers);
      
      if (response.statusCode == 200) {
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

  Future<MenuModel> getMenuById(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse('${ApiConfig.menus}/$id'), headers: headers);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final data = decoded is Map && decoded.containsKey('data') ? decoded['data'] : decoded;
        return MenuModel.fromJson(data);
      } else {
        throw Exception('Gagal mendapatkan detail menu: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(ApiConfig.categories), headers: headers);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        List<dynamic> data = decoded is Map && decoded.containsKey('data') ? decoded['data'] : decoded;
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Gagal mengambil data kategori: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<MenuModel> createMenu(MenuModel menu, {String? imagePath}) async {
    try {
      if (imagePath != null) {
        var request = http.MultipartRequest('POST', Uri.parse(ApiConfig.menus));
        final headers = await _getHeaders(isMultipart: true);
        request.headers.addAll(headers);

        request.fields['nama_menu'] = menu.namaMenu;
        request.fields['kategori'] = menu.kategori;
        request.fields['deskripsi'] = menu.deskripsi;
        if (menu.modal != null) request.fields['modal'] = menu.modal.toString();
        request.fields['price'] = menu.price.toString();
        request.fields['is_active'] = menu.isActive ? '1' : '0';
        
        request.files.add(await http.MultipartFile.fromPath('gambar', imagePath));

        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 201 || response.statusCode == 200) {
          final decoded = json.decode(response.body);
          final data = decoded is Map && decoded.containsKey('data') ? decoded['data'] : decoded;
          return MenuModel.fromJson(data);
        } else {
          throw Exception('Gagal menambah menu: ${response.statusCode}');
        }
      } else {
        // Fallback to JSON if no image
        final headers = await _getHeaders();
        final response = await http.post(
          Uri.parse(ApiConfig.menus),
          headers: headers,
          body: json.encode(menu.toJson()),
        );

        if (response.statusCode == 201 || response.statusCode == 200) {
          final decoded = json.decode(response.body);
          final data = decoded is Map && decoded.containsKey('data') ? decoded['data'] : decoded;
          return MenuModel.fromJson(data);
        } else {
          throw Exception('Gagal menambah menu: ${response.statusCode}');
        }
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<MenuModel> updateMenu(int id, MenuModel menu, {String? imagePath}) async {
    try {
      if (imagePath != null) {
        // Using POST with _method=PUT is common in Laravel for multipart requests
        var request = http.MultipartRequest('POST', Uri.parse('${ApiConfig.menus}/$id'));
        final headers = await _getHeaders(isMultipart: true);
        request.headers.addAll(headers);
        
        request.fields['_method'] = 'PUT';
        request.fields['nama_menu'] = menu.namaMenu;
        request.fields['kategori'] = menu.kategori;
        request.fields['deskripsi'] = menu.deskripsi;
        if (menu.modal != null) request.fields['modal'] = menu.modal.toString();
        request.fields['price'] = menu.price.toString();
        request.fields['is_active'] = menu.isActive ? '1' : '0';
        
        request.files.add(await http.MultipartFile.fromPath('gambar', imagePath));

        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200) {
          final decoded = json.decode(response.body);
          final data = decoded is Map && decoded.containsKey('data') ? decoded['data'] : decoded;
          return MenuModel.fromJson(data);
        } else {
          throw Exception('Gagal mengubah menu: ${response.statusCode}');
        }
      } else {
        final headers = await _getHeaders();
        final response = await http.put(
          Uri.parse('${ApiConfig.menus}/$id'),
          headers: headers,
          body: json.encode(menu.toJson()),
        );

        if (response.statusCode == 200) {
          final decoded = json.decode(response.body);
          final data = decoded is Map && decoded.containsKey('data') ? decoded['data'] : decoded;
          return MenuModel.fromJson(data);
        } else {
          throw Exception('Gagal mengubah menu: ${response.statusCode}');
        }
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> deleteMenu(int id) async {
    try {
      final headers = await _getHeaders(isMultipart: true); // no content type
      final response = await http.delete(
        Uri.parse('${ApiConfig.menus}/$id'),
        headers: headers,
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
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse('${ApiConfig.menus}/$menuId/prices'), headers: headers);
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
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${ApiConfig.menus}/$menuId/prices'),
        headers: headers,
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
