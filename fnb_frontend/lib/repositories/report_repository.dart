import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';
import '../core/token_service.dart';
import '../models/report_model.dart';

class ReportRepository {
  Future<Map<String, String>> _getHeaders() async {
    final token = await TokenService.getToken();
    return {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<ReportResponseModel> getSalesSummary({String? startDate, String? endDate}) async {
    try {
      final headers = await _getHeaders();
      
      String url = ApiConfig.reportsSales;
      if (startDate != null && endDate != null) {
        url += '?start_date=$startDate&end_date=$endDate';
      }

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final data = decoded is Map && decoded.containsKey('data') ? decoded['data'] : decoded;
        return ReportResponseModel.fromJson(data);
      } else {
        throw Exception('Gagal mengambil laporan penjualan: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
