import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> logout() async {
    await _prefs?.setBool(_keyIsLoggedIn, false);
    await _prefs?.clear(); // Nettoie toutes les données utilisateur
  }

  static Future<bool> isLoggedIn() async {
    return _prefs?.getBool(_keyIsLoggedIn) ?? false;
  }

  static Future<void> setLoggedIn() async {
    await _prefs?.setBool(_keyIsLoggedIn, true);
  }
}
