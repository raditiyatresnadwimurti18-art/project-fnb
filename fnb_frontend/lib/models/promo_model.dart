class PromoModel {
  final int? id;
  final String name;
  final String type;
  final double value;
  final bool isPercentage;
  final double maxDiscount;
  final double minPurchase;
  final DateTime startDate;
  final DateTime endDate;
  final int quota;
  final int usedQuota;
  final bool isActive;
  // BOGO & Menu Fields
  final int? buyQty;
  final int? freeQty;
  final bool? applyMultiple;
  final int? menuId;
  final int? freeMenuId;

  PromoModel({
    this.id,
    required this.name,
    required this.type,
    required this.value,
    required this.isPercentage,
    required this.maxDiscount,
    required this.minPurchase,
    required this.startDate,
    required this.endDate,
    required this.quota,
    this.usedQuota = 0,
    required this.isActive,
    this.buyQty,
    this.freeQty,
    this.applyMultiple,
    this.menuId,
    this.freeMenuId,
  });

  factory PromoModel.fromJson(Map<String, dynamic> json) {
    return PromoModel(
      id: json['id'],
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      value: double.tryParse(json['value']?.toString() ?? '0') ?? 0,
      isPercentage: json['is_percentage'] ?? false,
      maxDiscount: double.tryParse(json['max_discount']?.toString() ?? '0') ?? 0,
      minPurchase: double.tryParse(json['min_purchase']?.toString() ?? '0') ?? 0,
      startDate: DateTime.tryParse(json['start_date'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['end_date'] ?? '') ?? DateTime.now(),
      quota: json['quota'] ?? 0,
      usedQuota: json['used_quota'] ?? 0,
      isActive: json['is_active'] ?? false,
      buyQty: json['buy_qty'],
      freeQty: json['free_qty'],
      applyMultiple: json['apply_multiple'],
      menuId: json['menu_id'],
      freeMenuId: json['free_menu_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'type': type,
      'value': value,
      'is_percentage': isPercentage,
      'max_discount': maxDiscount,
      'min_purchase': minPurchase,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'quota': quota,
      'used_quota': usedQuota,
      'is_active': isActive,
      if (menuId != null) 'menu_id': menuId,
      if (type == 'bogo') 'buy_qty': buyQty,
      if (type == 'bogo') 'free_qty': freeQty,
      if (type == 'bogo') 'apply_multiple': applyMultiple,
      if (type == 'bogo' && freeMenuId != null) 'free_menu_id': freeMenuId,
    };
  }
}
