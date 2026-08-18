class MenuModel {
  final int? id;
  final String kodeMenu;
  final String namaMenu;
  final String kategori;
  final String deskripsi;
  final String gambar;
  final bool isActive;
  final double price;
  final double? modal;
  final int totalStock;

  MenuModel({
    this.id,
    required this.kodeMenu,
    required this.namaMenu,
    required this.kategori,
    required this.deskripsi,
    required this.gambar,
    required this.isActive,
    required this.price,
    this.modal,
    this.totalStock = 0,
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    return MenuModel(
      id: json['id'],
      kodeMenu: json['kode_menu'] ?? '',
      namaMenu: json['nama_menu'] ?? '',
      kategori: json['kategori'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      gambar: json['gambar'] ?? '',
      isActive: json['aktif'] == 1 || json['aktif'] == true || json['is_active'] == 1 || json['is_active'] == true,
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0,
      modal: json['modal'] != null ? double.tryParse(json['modal'].toString()) : null,
      totalStock: json['total_stock'] != null ? int.tryParse(json['total_stock'].toString()) ?? 0 : 0,
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
      'aktif': isActive ? 1 : 0,
      'is_active': isActive ? 1 : 0,
      'price': price,
      if (modal != null) 'modal': modal,
    };
  }
}
