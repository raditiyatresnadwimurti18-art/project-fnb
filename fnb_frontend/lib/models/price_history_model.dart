class PriceHistoryModel {
  final int? id;
  final int menuId;
  final double newPrice;
  final DateTime effectiveDate;
  final int? userId;

  PriceHistoryModel({
    this.id,
    required this.menuId,
    required this.newPrice,
    required this.effectiveDate,
    this.userId,
  });

  factory PriceHistoryModel.fromJson(Map<String, dynamic> json) {
    return PriceHistoryModel(
      id: json['id'],
      menuId: json['menu_id'] ?? 0,
      newPrice: double.tryParse(json['new_price']?.toString() ?? '0') ?? 0,
      effectiveDate: DateTime.tryParse(json['effective_date'] ?? '') ?? DateTime.now(),
      userId: json['user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'menu_id': menuId,
      'new_price': newPrice,
      'effective_date': effectiveDate.toIso8601String(),
      if (userId != null) 'user_id': userId,
    };
  }
}
