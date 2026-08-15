import 'package:flutter/material.dart';
import '../repositories/promo_repository.dart';
import '../models/promo_model.dart';

class AdminPromoProvider with ChangeNotifier {
  final PromoRepository _promoRepository = PromoRepository();

  List<PromoModel> promos = [];
  bool isLoading = true;
  String? errorMessage;

  Future<void> loadPromos() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      promos = await _promoRepository.getPromos();
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  Future<bool> deletePromo(int id) async {
    isLoading = true;
    notifyListeners();

    try {
      await _promoRepository.deletePromo(id);
      await loadPromos();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> savePromo(PromoModel promo, bool isEdit) async {
    isLoading = true;
    notifyListeners();

    try {
      if (isEdit) {
        await _promoRepository.updatePromo(promo.id!, promo);
      } else {
        await _promoRepository.createPromo(promo);
      }
      await loadPromos();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
