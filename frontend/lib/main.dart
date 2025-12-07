import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'ui/screens/main_navigation_screen.dart';
import 'core/settings_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const VitalMonitorApp());
}

class VitalMonitorApp extends StatelessWidget {
  const VitalMonitorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsService(),
      child: Consumer<SettingsService>(
        builder: (context, settings, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: "mmWave Vital Monitor",
            theme: settings.getCurrentTheme(),
            home: const MainNavigationScreen(),
          );
        },
      ),
    );
  }
}
