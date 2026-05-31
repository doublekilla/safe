import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

/// SharedPreferences wrapper for local persistence
class StorageService {
  SharedPreferences? _prefs;

  Future<SharedPreferences> get _instance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<void> saveToken(String token) async {
    final prefs = await _instance;
    await prefs.setString(AppConstants.tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await _instance;
    return prefs.getString(AppConstants.tokenKey);
  }

  Future<void> removeToken() async {
    final prefs = await _instance;
    await prefs.remove(AppConstants.tokenKey);
  }

  Future<void> saveUser(String userJson) async {
    final prefs = await _instance;
    await prefs.setString(AppConstants.userKey, userJson);
  }

  Future<String?> getUser() async {
    final prefs = await _instance;
    return prefs.getString(AppConstants.userKey);
  }

  Future<void> removeUser() async {
    final prefs = await _instance;
    await prefs.remove(AppConstants.userKey);
  }

  Future<void> setOnboardingComplete() async {
    final prefs = await _instance;
    await prefs.setBool(AppConstants.onboardingKey, true);
  }

  Future<bool> isOnboardingComplete() async {
    final prefs = await _instance;
    return prefs.getBool(AppConstants.onboardingKey) ?? false;
  }

  Future<void> clearAll() async {
    final prefs = await _instance;
    await prefs.clear();
  }
}
