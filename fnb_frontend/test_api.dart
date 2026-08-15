import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final url = Uri.parse('http://127.0.0.1:8000/api/transactions/calculate');
  final payload = {
    "items": [
      {"menu_id": 1, "qty": 2}
    ],
    "promo_id": 1
  };
  print("Sending: ${json.encode(payload)}");

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    },
    body: json.encode(payload),
  );

  print("Status: ${response.statusCode}");
  print("Body: ${response.body}");
}
