class InventoryMenuModel {
  final int id;
  final String namaMenu;
  final String kategori;
  final double price;

  const InventoryMenuModel({
    required this.id,
    required this.namaMenu,
    required this.kategori,
    required this.price,
  });

  factory InventoryMenuModel.fromJson(Map<String, dynamic> json) {
    return InventoryMenuModel(
      id: _asInt(json['id']),
      namaMenu: json['nama_menu']?.toString() ?? '',
      kategori: json['kategori']?.toString() ?? '',
      price: _asDouble(json['price']),
    );
  }
}

class InventoryBatchModel {
  final int id;
  final int menuId;
  final int qtyPurchased;
  final int qtyRemaining;
  final double modal;
  final DateTime? purchasedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final InventoryMenuModel? menu;

  const InventoryBatchModel({
    required this.id,
    required this.menuId,
    required this.qtyPurchased,
    required this.qtyRemaining,
    required this.modal,
    this.purchasedAt,
    this.createdAt,
    this.updatedAt,
    this.menu,
  });

  factory InventoryBatchModel.fromJson(Map<String, dynamic> json) {
    final menuJson = json['menu'];
    return InventoryBatchModel(
      id: _asInt(json['id']),
      menuId: _asInt(json['menu_id']),
      qtyPurchased: _asInt(json['qty_purchased']),
      qtyRemaining: _asInt(json['qty_remaining']),
      modal: _asDouble(json['modal']),
      purchasedAt: _asDateTime(json['purchased_at']),
      createdAt: _asDateTime(json['created_at']),
      updatedAt: _asDateTime(json['updated_at']),
      menu: menuJson is Map<String, dynamic>
          ? InventoryMenuModel.fromJson(menuJson)
          : null,
    );
  }
}

class InventorySummaryModel {
  final int menuId;
  final InventoryMenuModel menu;
  final int totalPurchased;
  final int totalRemaining;
  final double avgModal;
  final int batchCount;
  final int activeBatchCount;

  const InventorySummaryModel({
    required this.menuId,
    required this.menu,
    required this.totalPurchased,
    required this.totalRemaining,
    required this.avgModal,
    required this.batchCount,
    required this.activeBatchCount,
  });

  factory InventorySummaryModel.fromJson(Map<String, dynamic> json) {
    return InventorySummaryModel(
      menuId: _asInt(json['menu_id']),
      menu: InventoryMenuModel.fromJson(
        Map<String, dynamic>.from(json['menu'] as Map? ?? const {}),
      ),
      totalPurchased: _asInt(json['total_purchased']),
      totalRemaining: _asInt(json['total_remaining']),
      avgModal: _asDouble(json['avg_modal']),
      batchCount: _asInt(json['batch_count']),
      activeBatchCount: _asInt(json['active_batch_count']),
    );
  }
}

class InventoryOverviewModel {
  final String message;
  final List<InventorySummaryModel> summary;
  final List<InventoryBatchModel> batches;

  const InventoryOverviewModel({
    required this.message,
    required this.summary,
    required this.batches,
  });

  factory InventoryOverviewModel.fromJson(Map<String, dynamic> json) {
    return InventoryOverviewModel(
      message: json['message']?.toString() ?? '',
      summary: _asList(json['summary'])
          .map((item) => InventorySummaryModel.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList(),
      batches: _asList(json['batches'])
          .map((item) => InventoryBatchModel.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList(),
    );
  }
}

class InventoryDetailModel {
  final String message;
  final InventorySummaryModel summary;
  final List<InventoryBatchModel> batches;

  const InventoryDetailModel({
    required this.message,
    required this.summary,
    required this.batches,
  });

  factory InventoryDetailModel.fromJson(Map<String, dynamic> json) {
    final data = Map<String, dynamic>.from(json['data'] as Map? ?? const {});
    final summary = InventorySummaryModel.fromJson(data);
    return InventoryDetailModel(
      message: json['message']?.toString() ?? '',
      summary: summary,
      batches: _asList(data['batches'])
          .map((item) => InventoryBatchModel.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList(),
    );
  }
}

List<dynamic> _asList(dynamic value) => value is List ? value : const [];

int _asInt(dynamic value) => int.tryParse(value?.toString() ?? '') ?? 0;

double _asDouble(dynamic value) => double.tryParse(value?.toString() ?? '') ?? 0;

DateTime? _asDateTime(dynamic value) =>
    value == null ? null : DateTime.tryParse(value.toString());
