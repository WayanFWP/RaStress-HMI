import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'home_screen.dart';
import 'sensor_info_screen.dart';
import '../../core/websocket_services.dart';
import '../../core/waveform_service.dart';
import '../../core/trend_service.dart';
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

  @override
  void initState() {
    super.initState();

    // Initialize services once for the entire app
    final ip = dotenv.env['IP'] ?? '';
    final port = dotenv.env['PORT'] ?? '';

    _webSocketService = WebSocketService('ws://$ip:$port');
    _waveformService = WaveformService();
    _trendService = TrendService();
    
    _webSocketService.connect();

    // Process waveform data in background continuously
    _webSocketService.latestData.addListener(_processDataInBackground);
  }

  void _processDataInBackground() {
    final data = _webSocketService.latestData.value;
    if (data != null) {
      _waveformService.processWaveformData(data);
      _trendService.addSensorData(data);
    }
  }

  @override
  void dispose() {
    _webSocketService.latestData.removeListener(_processDataInBackground);
    _webSocketService.dispose();
    _waveformService.dispose();
    _trendService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(
        trendService: _trendService,
        webSocketService: _webSocketService,
      ),
      SensorInfoScreen(
        webSocketService: _webSocketService,
        waveformService: _waveformService,
      ),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: Container(
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: const Color(0xFF151B2D),
          selectedItemColor: const Color(0xFF2BE4DC),
          unselectedItemColor: Colors.white54,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.punch_clock),
              label: 'Trends',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.sensors),
              label: 'Sensor Info',
            ),
          ],
        ),
      ),
    );
  }
}