import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../ui/themes/app_theme.dart';

class SettingsService extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _fontSizeKey = 'font_size';
  static const String _dyslexicKey = 'dyslexic_mode';
  static const String _colorBlindKey = 'color_blind_mode';

  AppThemeMode _themeMode = AppThemeMode.neon;
  FontSize _fontSize = FontSize.medium;
  bool _isDyslexic = false;
  ColorBlindMode _colorBlindMode = ColorBlindMode.none;

  AppThemeMode get themeMode => _themeMode;
  FontSize get fontSize => _fontSize;
  bool get isDyslexic => _isDyslexic;
  ColorBlindMode get colorBlindMode => _colorBlindMode;

  SettingsService() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    _themeMode = AppThemeMode.values[prefs.getInt(_themeKey) ?? 0];
    _fontSize = FontSize.values[prefs.getInt(_fontSizeKey) ?? 1];
    _isDyslexic = prefs.getBool(_dyslexicKey) ?? false;
    _colorBlindMode = ColorBlindMode.values[prefs.getInt(_colorBlindKey) ?? 0];

    notifyListeners();
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
    notifyListeners();
  }

  Future<void> setFontSize(FontSize size) async {
    _fontSize = size;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_fontSizeKey, size.index);
    notifyListeners();
  }

  Future<void> setDyslexicMode(bool enabled) async {
    _isDyslexic = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dyslexicKey, enabled);
    notifyListeners();
  }

  Future<void> setColorBlindMode(ColorBlindMode mode) async {
    _colorBlindMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_colorBlindKey, mode.index);
    notifyListeners();
  }

  ThemeData getCurrentTheme() {
    switch (_themeMode) {
      case AppThemeMode.neon:
        return AppTheme.neonTheme(
          fontSize: _fontSize,
          isDyslexic: _isDyslexic,
          colorBlindMode: _colorBlindMode,
        );
      case AppThemeMode.dark:
        return AppTheme.darkMonochromeTheme(
          fontSize: _fontSize,
          isDyslexic: _isDyslexic,
          colorBlindMode: _colorBlindMode,
        );
      case AppThemeMode.light:
        return AppTheme.lightTheme(
          fontSize: _fontSize,
          isDyslexic: _isDyslexic,
          colorBlindMode: _colorBlindMode,
        );
      case AppThemeMode.nightOwl:
        return AppTheme.nightOwlTheme(
          fontSize: _fontSize,
          isDyslexic: _isDyslexic,
          colorBlindMode: _colorBlindMode,
        );
    }
  }
}
