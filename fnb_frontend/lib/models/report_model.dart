import 'user_model.dart';

class ReportSummaryModel {
  final int totalTransactions;
  final double grossRevenue;
  final double totalDiscount;
  final double netRevenue;
  final double totalCogs;
  final double grossProfit;
  final double totalInventoryAsset;

  ReportSummaryModel({
    required this.totalTransactions,
    required this.grossRevenue,
    required this.totalDiscount,
    required this.netRevenue,
    required this.totalCogs,
    required this.grossProfit,
    required this.totalInventoryAsset,
  });

  factory ReportSummaryModel.fromJson(Map<String, dynamic> json) {
    return ReportSummaryModel(
      totalTransactions: int.tryParse(json['total_transactions']?.toString() ?? '0') ?? 0,
      grossRevenue: double.tryParse(json['gross_revenue']?.toString() ?? '0') ?? 0.0,
      totalDiscount: double.tryParse(json['total_discount']?.toString() ?? '0') ?? 0.0,
      netRevenue: double.tryParse(json['net_revenue']?.toString() ?? '0') ?? 0.0,
      totalCogs: double.tryParse(json['total_cogs']?.toString() ?? '0') ?? 0.0,
      grossProfit: double.tryParse(json['gross_profit']?.toString() ?? '0') ?? 0.0,
      totalInventoryAsset: double.tryParse(json['total_inventory_asset']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class SalesByMenuModel {
  final int menuId;
  final String menuName;
  final int qtySold;
  final double grossRevenue;
  final double cogs;

  SalesByMenuModel({
    required this.menuId,
    required this.menuName,
    required this.qtySold,
    required this.grossRevenue,
    required this.cogs,
  });

  factory SalesByMenuModel.fromJson(Map<String, dynamic> json) {
    return SalesByMenuModel(
      menuId: json['menu_id'] ?? 0,
      menuName: json['menu_name'] ?? 'Unknown',
      qtySold: int.tryParse(json['qty_sold']?.toString() ?? '0') ?? 0,
      grossRevenue: double.tryParse(json['gross_revenue']?.toString() ?? '0') ?? 0.0,
      cogs: double.tryParse(json['cogs']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class PromoAnalyticsModel {
  final int promoId;
  final String promoName;
  final int timesUsed;
  final double totalDiscountGiven;

  PromoAnalyticsModel({
    required this.promoId,
    required this.promoName,
    required this.timesUsed,
    required this.totalDiscountGiven,
  });

  factory PromoAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return PromoAnalyticsModel(
      promoId: json['promo_id'] ?? 0,
      promoName: json['promo_name'] ?? 'Unknown',
      timesUsed: int.tryParse(json['times_used']?.toString() ?? '0') ?? 0,
      totalDiscountGiven: double.tryParse(json['total_discount_given']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class SalesByKasirModel {
  final int? userId;
  final int totalTransactions;
  final double totalRevenue;
  final UserModel? user;

  SalesByKasirModel({
    required this.userId,
    required this.totalTransactions,
    required this.totalRevenue,
    this.user,
  });

  factory SalesByKasirModel.fromJson(Map<String, dynamic> json) {
    return SalesByKasirModel(
      userId: json['user_id'],
      totalTransactions: int.tryParse(json['total_transactions']?.toString() ?? '0') ?? 0,
      totalRevenue: double.tryParse(json['total_revenue']?.toString() ?? '0') ?? 0.0,
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
    );
  }
}

class ReportResponseModel {
  final String? startDate;
  final String? endDate;
  final ReportSummaryModel summary;
  final List<SalesByMenuModel> salesByMenu;
  final List<PromoAnalyticsModel> promoAnalytics;
  final List<SalesByKasirModel> salesByKasir;

  ReportResponseModel({
    this.startDate,
    this.endDate,
    required this.summary,
    required this.salesByMenu,
    required this.promoAnalytics,
    required this.salesByKasir,
  });

  factory ReportResponseModel.fromJson(Map<String, dynamic> json) {
    final period = json['period'] ?? {};
    return ReportResponseModel(
      startDate: period['start'],
      endDate: period['end'],
      summary: ReportSummaryModel.fromJson(json['summary'] ?? {}),
      salesByMenu: (json['sales_by_menu'] as List?)
              ?.map((item) => SalesByMenuModel.fromJson(item))
              .toList() ??
          [],
      promoAnalytics: (json['promo_analytics'] as List?)
              ?.map((item) => PromoAnalyticsModel.fromJson(item))
              .toList() ??
          [],
      salesByKasir: (json['sales_by_kasir'] as List?)
              ?.map((item) => SalesByKasirModel.fromJson(item))
              .toList() ??
          [],
    );
  }
}
