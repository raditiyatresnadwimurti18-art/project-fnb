class MenuModel {
  final int? id;
  final String kodeMenu;
  final String namaMenu;
  final String kategori;
  final String deskripsi;
  final String gambar;
  final bool isActive;
  final double price;

  MenuModel({
    this.id,
    required this.kodeMenu,
    required this.namaMenu,
    required this.kategori,
    required this.deskripsi,
    required this.gambar,
    required this.isActive,
    required this.price,
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    return MenuModel(
      id: json['id'],
      kodeMenu: json['kode_menu'] ?? '',
      namaMenu: json['nama_menu'] ?? '',
      kategori: json['kategori'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      gambar: json['gambar'] ?? '',
      isActive: json['is_active'] ?? false,
      price: json['current_price'] != null 
          ? double.tryParse(json['current_price']['new_price']?.toString() ?? '0') ?? 0
          : double.tryParse(json['price']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'kode_menu': kodeMenu,
      'nama_menu': namaMenu,
      'kategori': kategori,
      'deskripsi': deskripsi,
      'gambar': gambar,
      'is_active': isActive,
      'price': price,
    };
  }
}
