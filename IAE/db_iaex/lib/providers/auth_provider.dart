import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../core/services/api_client.dart';
import '../core/services/storage_service.dart';

/// Authentication state management
class AuthProvider extends ChangeNotifier {
  final ApiClient _api;
  final StorageService _storage;
  AppUser? _currentUser;
  bool _isLoading = false;
  String? _error;

  AuthProvider({required ApiClient api, required StorageService storage})
      : _api = api,
        _storage = storage;

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  String? get error => _error;

  Future<void> loadUser() async {
    final userJson = await _storage.getUser();
    if (userJson != null) {
      try {
        _currentUser = AppUser.fromJson(jsonDecode(userJson));
        notifyListeners();
      } catch (_) {}
    }
  }

  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await _api.post('/auth/login', body: {'email': email, 'password': password}, withAuth: false);
      if (res.isSuccess) {
        final token = res.data['token'] as String?;
        if (token != null) await _storage.saveToken(token);
        _currentUser = AppUser.fromJson(res.data['user'] as Map<String, dynamic>);
        await _storage.saveUser(jsonEncode(_currentUser!.toJson()));
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _error = res.message;
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register({required String name, required String email, required String phone, required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await _api.post('/auth/register', body: {'name': name, 'email': email, 'phone': phone, 'password': password, 'password_confirmation': password}, withAuth: false);
      if (res.isSuccess) {
        final token = res.data['token'] as String?;
        if (token != null) await _storage.saveToken(token);
        _currentUser = AppUser.fromJson(res.data['user'] as Map<String, dynamic>);
        await _storage.saveUser(jsonEncode(_currentUser!.toJson()));
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _error = res.message;
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }



  Future<void> logout() async {
    try {
      await _api.post('/auth/logout');
    } catch (_) {}
    _currentUser = null;
    await _storage.removeToken();
    await _storage.removeUser();
    notifyListeners();
  }

  void setUser(AppUser user) {
    _currentUser = user;
    notifyListeners();
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await _api.put('/profile', body: data);
      if (res.isSuccess) {
        final userData = Map<String, dynamic>.from(res.data['user'] as Map);
        userData['sl_profile'] = res.data['profile'];
        _currentUser = AppUser.fromJson(userData);
        await _storage.saveUser(jsonEncode(_currentUser!.toJson()));
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _error = res.message;
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }
}
