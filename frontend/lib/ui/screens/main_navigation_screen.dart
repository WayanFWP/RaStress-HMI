import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'home_screen.dart';
import 'sensor_info_screen.dart';
import 'settings_screen.dart';
import '../../core/websocket_services.dart';
import '../../core/waveform_service.dart';
import '../../core/trend_service.dart';
import '../../core/stress_level_service.dart';
import '../../core/sensor_model.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  late WebSocketService _webSocketService;
  late WaveformService _waveformService;
  late TrendService _trendService;
  late StressLevelService _stressLevelService;

  @override
  void initState() {
    super.initState();

    // Initialize services once for the entire app
    final ip = dotenv.env['IP'] ?? '';
    final port = dotenv.env['PORT'] ?? '';

    _webSocketService = WebSocketService('ws://$ip:$port');
    _waveformService = WaveformService();
    _trendService = TrendService();
    _stressLevelService = StressLevelService();
    
    _webSocketService.connect();

    // Process waveform data in background continuously
    _webSocketService.latestData.addListener(_processDataInBackground);
  }

  void _processDataInBackground() {
    final data = _webSocketService.latestData.value;
    if (data != null) {
      _waveformService.processWaveformData(data);
      _trendService.addSensorData(data);
      _stressLevelService.addSensorData(data);
    }
  }

  @override
  void dispose() {
    _webSocketService.latestData.removeListener(_processDataInBackground);
    _webSocketService.dispose();
    _waveformService.dispose();
    _trendService.dispose();
    _stressLevelService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(
        trendService: _trendService,
        webSocketService: _webSocketService,
        stressLevelService: _stressLevelService,
      ),
      SensorInfoScreen(
        webSocketService: _webSocketService,
        waveformService: _waveformService,
      ),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Theme.of(context).colorScheme.surface,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Colors.white54,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.punch_clock),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.sensors),
              label: 'Sensor Info',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}