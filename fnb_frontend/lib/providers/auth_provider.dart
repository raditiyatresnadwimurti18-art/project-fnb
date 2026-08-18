import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/auth_repository.dart';
import '../models/user_model.dart';
import '../core/token_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  bool _isLoggedIn = false;
  String? _role;
  int? _userId;
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoggedIn => _isLoggedIn;
  String? get role => _role;
  int? get userId => _userId ?? _user?.id;
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
    final savedUserId = prefs.getInt('user_id');

    if (token != null && savedRole != null) {
      _isLoggedIn = true;
      _role = savedRole;
      _userId = savedUserId;
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
      _userId = user.id;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_role', user.role);
      if (user.id != null) await prefs.setInt('user_id', user.id!);

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
    await prefs.remove('user_id');

    _isLoggedIn = false;
    _role = null;
    _userId = null;
    _user = null;
    _isLoading = false;
    notifyListeners();
  }
}
