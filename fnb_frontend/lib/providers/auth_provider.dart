import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/auth_repository.dart';
import '../models/user_model.dart';
import '../core/token_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  bool _isLoggedIn = false;
  String? _role;
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoggedIn => _isLoggedIn;
  String? get role => _role;
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final token = await TokenService.getToken();
    final prefs = await SharedPreferences.getInstance();
    final savedRole = prefs.getString('user_role');

    if (token != null && savedRole != null) {
      _isLoggedIn = true;
      _role = savedRole;
      notifyListeners();
    }
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authRepository.login(username, password);
      _isLoggedIn = true;
      _user = user;
      _role = user.role;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_role', user.role);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _authRepository.logout();
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_role');

    _isLoggedIn = false;
    _role = null;
    _user = null;
    _isLoading = false;
    notifyListeners();
  }
}
