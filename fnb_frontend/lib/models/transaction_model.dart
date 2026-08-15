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
  final double paymentAmount;
  final int userId;

  TransactionModel({
    required this.items,
    this.promoId,
    required this.paymentAmount,
    required this.userId,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      items: (json['items'] as List?)
              ?.map((item) => TransactionItemModel.fromJson(item))
              .toList() ??
          [],
      promoId: json['promo_id'],
      paymentAmount: (json['payment_amount'] ?? 0).toDouble(),
      userId: json['user_id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'promo_id': promoId,
      'payment_amount': paymentAmount,
      'user_id': userId,
    };
  }
}
