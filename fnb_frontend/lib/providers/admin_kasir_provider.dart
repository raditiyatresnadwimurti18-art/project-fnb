import 'package:flutter/material.dart';
import '../repositories/kasir_repository.dart';
import '../models/user_model.dart';

class AdminKasirProvider with ChangeNotifier {
  final KasirRepository _kasirRepository = KasirRepository();

  List<UserModel> kasirs = [];
  bool isLoading = true;
  String? errorMessage;
  String? actionErrorMessage;

  Future<void> loadKasirs() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      kasirs = await _kasirRepository.getKasirs();
    } catch (e) {
      errorMessage = e.toString().replaceAll('Exception: ', '');
    }

    isLoading = false;
    notifyListeners();
  }

  Future<bool> createKasir(UserModel kasir, String password) async {
    try {
      final data = kasir.toJson();
      data['password'] = password;
      await _kasirRepository.createKasir(data);
      await loadKasirs();
      return true;
    } catch (e) {
      actionErrorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    }
  }

  Future<bool> updateKasir(UserModel kasir, String? newPassword) async {
    try {
      final data = kasir.toJson();
      if (newPassword != null) {
        data['password'] = newPassword;
      }
      await _kasirRepository.updateKasir(kasir.id!, data);
      await loadKasirs();
      return true;
    } catch (e) {
      actionErrorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    }
  }

  Future<bool> deleteKasir(int id) async {
    try {
      await _kasirRepository.deleteKasir(id);
      await loadKasirs();
      return true;
    } catch (e) {
      actionErrorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    }
  }
}
