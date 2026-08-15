import 'package:flutter/material.dart';
import '../repositories/menu_repository.dart';
import '../models/menu_model.dart';

class AdminMenuProvider with ChangeNotifier {
  final MenuRepository _menuRepository = MenuRepository();

  List<MenuModel> menus = [];
  bool isLoading = true;
  String? errorMessage;

  Future<void> loadMenus() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      menus = await _menuRepository.getMenus();
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  Future<bool> deleteMenu(int id) async {
    isLoading = true;
    notifyListeners();

    try {
      await _menuRepository.deleteMenu(id);
      await loadMenus();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> saveMenu(MenuModel menu, bool isEdit) async {
    isLoading = true;
    notifyListeners();

    try {
      if (isEdit) {
        await _menuRepository.updateMenu(menu.id!, menu);
      } else {
        await _menuRepository.createMenu(menu);
      }
      await loadMenus();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
