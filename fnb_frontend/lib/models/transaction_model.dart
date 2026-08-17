class TransactionItemModel {
  final int menuId; // Assuming menu_id is int based on Postman, though kodeMenu is String. Let's use dynamic or String to be safe. We will use int as per postman JSON.
  final int qty;

  TransactionItemModel({
    required this.menuId,
    required this.qty,
  });

  factory TransactionItemModel.fromJson(Map<String, dynamic> json) {
    return TransactionItemModel(
      menuId: json['menu_id'] ?? 0,
      qty: json['qty'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'menu_id': menuId,
      'qty': qty,
    };
  }
}

class TransactionModel {
  final List<TransactionItemModel> items;
  final int? promoId;
  final double? paymentAmount;
  final int? userId;
  final String? paymentMethod;
  final String? invoiceNumber;
  final double? totalAmount;
  final double? changeAmount;
  final String? createdAt;

  TransactionModel({
    required this.items,
    this.promoId,
    this.paymentAmount,
    this.userId,
    this.paymentMethod,
    this.invoiceNumber,
    this.totalAmount,
    this.changeAmount,
    this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      items: (json['items'] as List?)
              ?.map((item) => TransactionItemModel.fromJson(item))
              .toList() ??
          [],
      promoId: json['promo_id'],
      paymentAmount: json['payment_amount'] != null ? double.tryParse(json['payment_amount'].toString()) : null,
      userId: json['user_id'],
      paymentMethod: json['payment_method'],
      invoiceNumber: json['invoice_number'],
      totalAmount: json['total_amount'] != null ? double.tryParse(json['total_amount'].toString()) : null,
      changeAmount: json['change_amount'] != null ? double.tryParse(json['change_amount'].toString()) : null,
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'items': items.map((item) => item.toJson()).toList(),
    };
    if (promoId != null) data['promo_id'] = promoId;
    if (paymentAmount != null) data['payment_amount'] = paymentAmount;
    if (userId != null) data['user_id'] = userId;
    if (paymentMethod != null) data['payment_method'] = paymentMethod;
    return data;
  }
}
