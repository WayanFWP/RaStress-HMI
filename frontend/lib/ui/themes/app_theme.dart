import 'package:flutter/material.dart';

enum AppThemeMode {
  neon,
  dark,
  light,
  nightOwl,
}

enum FontSize {
  small,
  medium,
  large,
}

enum ColorBlindMode {
  none,
  protanopia, // Red-blind
  deuteranopia, // Green-blind
  tritanopia, // Blue-blind
}

class AppTheme {
  // Font size multipliers
  static double getFontSizeMultiplier(FontSize size) {
    switch (size) {
      case FontSize.small:
        return 0.85;
      case FontSize.medium:
        return 1.0;
      case FontSize.large:
        return 1.15;
    }
  }

  // Get colors adjusted for color blind modes
  static Color adjustColorForColorBlind(Color original, ColorBlindMode mode) {
    if (mode == ColorBlindMode.none) return original;

    final hsv = HSVColor.fromColor(original);
    
    switch (mode) {
      case ColorBlindMode.protanopia:
        // Adjust red hues to be more distinguishable
        return hsv.withHue((hsv.hue + 30) % 360).toColor();
      case ColorBlindMode.deuteranopia:
        // Adjust green hues
        return hsv.withHue((hsv.hue - 30) % 360).toColor();
      case ColorBlindMode.tritanopia:
        // Adjust blue hues
        return hsv.withSaturation(hsv.saturation * 1.3).toColor();
      default:
        return original;
    }
  }

  // Neon Theme (Current)
  static ThemeData neonTheme({
    FontSize fontSize = FontSize.medium,
    bool isDyslexic = false,
    ColorBlindMode colorBlindMode = ColorBlindMode.none,
  }) {
    final fontMultiplier = getFontSizeMultiplier(fontSize);
    final fontFamily = isDyslexic ? "OpenDyslexic" : "SF Pro";

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0A0F1C),
      fontFamily: fontFamily,
      useMaterial3: true,
      textTheme: _buildTextTheme(fontMultiplier, fontFamily),
      colorScheme: ColorScheme.dark(
        primary: adjustColorForColorBlind(const Color(0xFF2BE4DC), colorBlindMode),
        secondary: adjustColorForColorBlind(const Color(0xFF7B61FF), colorBlindMode),
        surface: const Color(0xFF151B2D),
        background: const Color(0xFF0A0F1C),
      ),
    );
  }

  // Dark Monochrome Theme
  static ThemeData darkMonochromeTheme({
    FontSize fontSize = FontSize.medium,
    bool isDyslexic = false,
    ColorBlindMode colorBlindMode = ColorBlindMode.none,
  }) {
    final fontMultiplier = getFontSizeMultiplier(fontSize);
    final fontFamily = isDyslexic ? "OpenDyslexic" : "SF Pro";

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF000000),
      fontFamily: fontFamily,
      useMaterial3: true,
      textTheme: _buildTextTheme(fontMultiplier, fontFamily),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFFFFFFF),
        secondary: Color(0xFFCCCCCC),
        surface: Color(0xFF1A1A1A),
        background: Color(0xFF000000),
      ),
    );
  }

  // Light Theme
  static ThemeData lightTheme({
    FontSize fontSize = FontSize.medium,
    bool isDyslexic = false,
    ColorBlindMode colorBlindMode = ColorBlindMode.none,
  }) {
    final fontMultiplier = getFontSizeMultiplier(fontSize);
    final fontFamily = isDyslexic ? "OpenDyslexic" : "SF Pro";

    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      fontFamily: fontFamily,
      useMaterial3: true,
      textTheme: _buildTextTheme(fontMultiplier, fontFamily),
      colorScheme: ColorScheme.light(
        primary: adjustColorForColorBlind(const Color(0xFF00BFA5), colorBlindMode),
        secondary: adjustColorForColorBlind(const Color(0xFF6200EA), colorBlindMode),
        surface: const Color(0xFFFFFFFF),
        background: const Color(0xFFF5F5F5),
      ),
    );
  }

  // Night Owl Theme
  static ThemeData nightOwlTheme({
    FontSize fontSize = FontSize.medium,
    bool isDyslexic = false,
    ColorBlindMode colorBlindMode = ColorBlindMode.none,
  }) {
    final fontMultiplier = getFontSizeMultiplier(fontSize);
    final fontFamily = isDyslexic ? "OpenDyslexic" : "SF Pro";

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF011627),
      fontFamily: fontFamily,
      useMaterial3: true,
      textTheme: _buildTextTheme(fontMultiplier, fontFamily),
      colorScheme: ColorScheme.dark(
        primary: adjustColorForColorBlind(const Color(0xFF82AAFF), colorBlindMode),
        secondary: adjustColorForColorBlind(const Color(0xFFC792EA), colorBlindMode),
        surface: const Color(0xFF0B2942),
        background: const Color(0xFF011627),
      ),
    );
  }

  static TextTheme _buildTextTheme(double multiplier, String fontFamily) {
    return TextTheme(
      displayLarge: TextStyle(fontSize: 57 * multiplier, fontFamily: fontFamily),
      displayMedium: TextStyle(fontSize: 45 * multiplier, fontFamily: fontFamily),
      displaySmall: TextStyle(fontSize: 36 * multiplier, fontFamily: fontFamily),
      headlineLarge: TextStyle(fontSize: 32 * multiplier, fontFamily: fontFamily),
      headlineMedium: TextStyle(fontSize: 28 * multiplier, fontFamily: fontFamily),
      headlineSmall: TextStyle(fontSize: 24 * multiplier, fontFamily: fontFamily),
      titleLarge: TextStyle(fontSize: 22 * multiplier, fontFamily: fontFamily),
      titleMedium: TextStyle(fontSize: 16 * multiplier, fontFamily: fontFamily),
      titleSmall: TextStyle(fontSize: 14 * multiplier, fontFamily: fontFamily),
      bodyLarge: TextStyle(fontSize: 16 * multiplier, fontFamily: fontFamily),
      bodyMedium: TextStyle(fontSize: 14 * multiplier, fontFamily: fontFamily),
      bodySmall: TextStyle(fontSize: 12 * multiplier, fontFamily: fontFamily),
      labelLarge: TextStyle(fontSize: 14 * multiplier, fontFamily: fontFamily),
      labelMedium: TextStyle(fontSize: 12 * multiplier, fontFamily: fontFamily),
      labelSmall: TextStyle(fontSize: 11 * multiplier, fontFamily: fontFamily),
    );
  }

  // Legacy getter for backward compatibility
  static ThemeData get darkTheme => neonTheme();
}