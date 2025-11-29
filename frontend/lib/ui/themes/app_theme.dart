import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0A0F1C),
    fontFamily: "SF Pro",
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF2BE4DC),
      secondary: Color(0xFF7B61FF),
    ),
  );
}
