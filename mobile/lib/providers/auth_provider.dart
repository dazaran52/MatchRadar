import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart'; // To get User model
import '../../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  User? get user => _user;
  int? _userId;
  int? get userId => _userId;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _tryAutoLogin();
  }

  Future<void> _tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final userData = jsonDecode(prefs.getString('userData')!);
      _user = User(
        id: userData['id'],
        name: userData['name'],
        photoUrl: userData['photoUrl'],
        latitude: 0,
        longitude: 0
      );
      _userId = _user!.id;
    } catch (e) {
      // Corrupt data
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _authService.login(email, password);

      if (data != null) {
        _user = User.fromJson(data['user']);
        _userId = _user!.id;

        final prefs = await SharedPreferences.getInstance();
        final userData = jsonEncode({
          'id': _user!.id,
          'name': _user!.name,
          'photoUrl': _user!.photoUrl,
        });
        prefs.setString('userData', userData);
        return true;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  Future<bool> signUp(String email, String password, String name) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _authService.register(name, email, password);

      if (data != null) {
        _user = User.fromJson(data['user']);
        _userId = _user!.id;

        final prefs = await SharedPreferences.getInstance();
        final userData = jsonEncode({
          'id': _user!.id,
          'name': _user!.name,
          'photoUrl': _user!.photoUrl,
        });
        prefs.setString('userData', userData);
        return true;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  Future<void> signOut() async {
    _user = null;
    _userId = null;
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
    notifyListeners();
  }
}
