import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final mode = await StorageService.getThemeMode();
    _themeMode = mode == 'dark' 
        ? ThemeMode.dark 
        : mode == 'system' 
        ? ThemeMode.system 
        : ThemeMode.light;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await StorageService.setThemeMode(
      mode == ThemeMode.dark ? 'dark' : mode == ThemeMode.system ? 'system' : 'light',
    );
    notifyListeners();
  }

  void toggleTheme() {
    setThemeMode(_themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light);
  }
}

