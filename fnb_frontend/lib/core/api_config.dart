class ApiConfig {
  //GUNAKAN API INI UNTUK TESTING
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  //INI ADALAH API UTAMA
  // static const String baseUrl =
  //     'https://potato-das-random-annual.trycloudflare.com/api';

  static const String menus = '$baseUrl/menus';
  static const String promos = '$baseUrl/promos';
  static const String transactions = '$baseUrl/transactions';
  
  // Modul 0: Autentikasi
  static const String login = '$baseUrl/login';
  static const String logout = '$baseUrl/logout';
  
  // Modul 0.5: Kasir
  static const String kasir = '$baseUrl/kasir';
  
  // Modul 1: Menu
  static const String categories = '$baseUrl/categories';
  
  // Modul 5: Reports
  static const String reportsSales = '$baseUrl/reports/sales';

  // Modul 6: Inventory
  static const String inventory = '$baseUrl/inventory';
}
