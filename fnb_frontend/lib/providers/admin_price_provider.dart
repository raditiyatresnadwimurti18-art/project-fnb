import 'package:flutter/material.dart';
import '../repositories/menu_repository.dart';
import '../models/menu_model.dart';
import '../models/price_history_model.dart';

class AdminPriceProvider with ChangeNotifier {
  final MenuRepository _menuRepository = MenuRepository();

  List<MenuModel> menus = [];
  MenuModel? selectedMenu;
  List<PriceHistoryModel> priceHistories = [];

  bool isLoadingMenus = true;
  bool isLoadingPrices = false;
  String? errorMessage;

  Future<void> loadMenus() async {
    isLoadingMenus = true;
    errorMessage = null;
    notifyListeners();

    try {
      menus = await _menuRepository.getMenus();
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoadingMenus = false;
    notifyListeners();
  }

  Future<void> selectMenuAndLoadPrices(MenuModel menu) async {
    selectedMenu = menu;
    isLoadingPrices = true;
    errorMessage = null;
    notifyListeners();

    try {
      priceHistories = await _menuRepository.getPrices(menu.id!);
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoadingPrices = false;
    notifyListeners();
  }

  Future<bool> addPrice(PriceHistoryModel price) async {
    if (selectedMenu == null) return false;
    
    isLoadingPrices = true;
    notifyListeners();

    try {
      await _menuRepository.addPrice(selectedMenu!.id!, price);
      await selectMenuAndLoadPrices(selectedMenu!);
      return true;
    } catch (e) {
      errorMessage = e.toString();
      isLoadingPrices = false;
      notifyListeners();
      return false;
    }
  }
}
