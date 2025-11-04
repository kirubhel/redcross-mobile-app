import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('en', '');

  Locale get locale => _locale;

  LanguageProvider() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final lang = await StorageService.getLanguage();
    _locale = Locale(lang ?? 'en', '');
    notifyListeners();
  }

  Future<void> setLanguage(String languageCode) async {
    _locale = Locale(languageCode, '');
    await StorageService.setLanguage(languageCode);
    notifyListeners();
  }

  String get currentLanguage => _locale.languageCode;
}

