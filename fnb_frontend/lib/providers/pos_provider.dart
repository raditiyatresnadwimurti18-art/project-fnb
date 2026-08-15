import 'package:flutter/material.dart';
import '../repositories/menu_repository.dart';
import '../models/menu_model.dart';
import '../repositories/promo_repository.dart';
import '../models/promo_model.dart';
import '../repositories/transaction_repository.dart';
import '../models/transaction_model.dart';

class PosProvider with ChangeNotifier {
  final MenuRepository _menuRepository = MenuRepository();
  final PromoRepository _promoRepository = PromoRepository();
  final TransactionRepository _transactionRepository = TransactionRepository();

  List<MenuModel> menus = [];
  List<PromoModel> promos = [];
  PromoModel? selectedPromo;

  bool isLoading = true;
  bool isCalculating = false;

  final Map<int, int> cart = {};

  double subtotal = 0;
  double discountTotal = 0;
  double finalTotal = 0;

  String? lastInvoiceNumber;

  Future<void> loadData() async {
    isLoading = true;
    notifyListeners();

    try {
      menus = await _menuRepository.getMenus();
      final allPromos = await _promoRepository.getPromos();
      promos = allPromos.where((p) => p.isActive == true).toList();
    } catch (e) {
      debugPrint('Error loading data: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  void addToCart(MenuModel menu) {
    if (menu.id == null) return;
    if (cart.containsKey(menu.id!)) {
      cart[menu.id!] = cart[menu.id!]! + 1;
    } else {
      cart[menu.id!] = 1;
    }
    notifyListeners();
    _calculateCart();
  }

  void removeFromCart(MenuModel menu) {
    if (menu.id == null || !cart.containsKey(menu.id!)) return;
    if (cart[menu.id!]! > 1) {
      cart[menu.id!] = cart[menu.id!]! - 1;
    } else {
      cart.remove(menu.id!);
    }
    notifyListeners();
    _calculateCart();
  }

  void selectPromo(PromoModel? promo) {
    selectedPromo = promo;
    notifyListeners();
    _calculateCart();
  }

  Future<void> _calculateCart() async {
    if (cart.isEmpty) {
      subtotal = 0;
      discountTotal = 0;
      finalTotal = 0;
      notifyListeners();
      return;
    }

    isCalculating = true;
    notifyListeners();

    try {
      final transaction = TransactionModel(
        promoId: selectedPromo?.id,
        items: cart.entries.map((e) => TransactionItemModel(menuId: e.key, qty: e.value)).toList(),
        paymentAmount: 0,
        userId: 1,
      );
      
      final result = await _transactionRepository.calculateCart(transaction);
      
      subtotal = double.tryParse(result['subtotal']?.toString() ?? '0') ?? 0;
      discountTotal = double.tryParse(result['discount_amount']?.toString() ?? '0') ?? 0;
      finalTotal = double.tryParse(result['total_amount']?.toString() ?? '0') ?? 0;
    } catch (e) {
      debugPrint('Error calculate cart: $e');
    }

    isCalculating = false;
    notifyListeners();
  }

  Future<bool> checkout(double paymentAmount) async {
    if (cart.isEmpty) return false;
    isLoading = true;
    notifyListeners();

    try {
      final transaction = TransactionModel(
        promoId: selectedPromo?.id,
        items: cart.entries.map((e) => TransactionItemModel(menuId: e.key, qty: e.value)).toList(),
        paymentAmount: paymentAmount,
        userId: 1,
      );
      
      final result = await _transactionRepository.checkout(transaction);
      lastInvoiceNumber = result['invoice_number'];
      
      cart.clear();
      selectedPromo = null;
      subtotal = 0;
      discountTotal = 0;
      finalTotal = 0;
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      debugPrint('Error checkout: $e');
      return false;
    }
  }
}
