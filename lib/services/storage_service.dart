import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _languageKey = 'language';
  static const String _themeKey = 'theme_mode';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> setToken(String token) async {
    await _prefs?.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    return _prefs?.getString(_tokenKey);
  }

  static Future<void> clearToken() async {
    await _prefs?.remove(_tokenKey);
  }

  static Future<void> setLanguage(String language) async {
    await _prefs?.setString(_languageKey, language);
  }

  static Future<String?> getLanguage() async {
    return _prefs?.getString(_languageKey) ?? 'en';
  }

  static Future<void> setThemeMode(String mode) async {
    await _prefs?.setString(_themeKey, mode);
  }

  static Future<String?> getThemeMode() async {
    return _prefs?.getString(_themeKey) ?? 'light';
  }
}

