import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'home_screen.dart';
import 'sensor_info_screen.dart';
import '../../core/websocket_services.dart';
import '../../core/waveform_service.dart';
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

  @override
  void initState() {
    super.initState();

    // Initialize services once for the entire app
    final ip = dotenv.env['IP'] ?? '';
    final port = dotenv.env['PORT'] ?? '';

    _webSocketService = WebSocketService('ws://$ip:$port');
    _waveformService = WaveformService();
    
    _webSocketService.connect();

    // Process waveform data in background continuously
    _webSocketService.latestData.addListener(_processWaveformInBackground);
  }

  void _processWaveformInBackground() {
    final data = _webSocketService.latestData.value;
    if (data != null) {
      _waveformService.processWaveformData(data);
    }
  }

  @override
  void dispose() {
    _webSocketService.latestData.removeListener(_processWaveformInBackground);
    _webSocketService.dispose();
    _waveformService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const HomeScreen(),
      SensorInfoScreen(
        webSocketService: _webSocketService,
        waveformService: _waveformService,
      ),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: const Color(0xFF2BE4DC).withOpacity(0.3),
              width: 1,
            ),
          ),
        ),
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
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.sensors),
              label: 'Sensor',
            ),
          ],
        ),
      ),
    );
  }
}