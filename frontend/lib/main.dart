import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'ui/screens/main_navigation_screen.dart';
import 'ui/themes/app_theme.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const VitalMonitorApp());
}

class VitalMonitorApp extends StatelessWidget {
  const VitalMonitorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "mmWave Vital Monitor",
      theme: AppTheme.darkTheme,
      home: const MainNavigationScreen(),
    );
  }
}