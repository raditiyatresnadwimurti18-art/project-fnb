class ApiConfig {
  //GUNAKAN API INI UNTUK TESTING
  // static const String baseUrl = 'http://127.0.0.1:8000/api';

  //INI ADALAH API UTAMA
  static const String baseUrl =
      'https://potato-das-random-annual.trycloudflare.com/api';

  static const String menus = '$baseUrl/menus';
  static const String promos = '$baseUrl/promos';
  static const String transactions = '$baseUrl/transactions';
}
