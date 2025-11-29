import 'package:flutter/material.dart';
import '../widgets/stat_card.dart';
import '../widgets/section_title.dart';
import '../widgets/waveform_chart.dart';
import '../widgets/sensor_information.dart';
import '../../core/websocket_services.dart';
import '../../core/sensor_model.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late WebSocketService _webSocketService;

  // Ring buffers for waveform data
  List<double> _heartWaveform = [];
  List<double> _breathWaveform = [];
  
  // UI throttling
  Timer? _uiUpdateTimer;
  bool _pendingUIUpdate = false;
  
  // Latest sensor data cache
  SensorData? _latestSensorData;
  
  // UI update rate by FPS
  static const int _uiUpdateRateHz = 3; // 3 FPS 
  static  int _uiUpdateIntervalMs = 1000 ~/ _uiUpdateRateHz; 
  static final Duration _uiUpdateInterval = Duration(milliseconds: _uiUpdateIntervalMs);

  @override
  void initState() {
    super.initState();
    
    final ip = dotenv.env['IP'] ?? '';
    final port = dotenv.env['PORT'] ?? '';
    
    _webSocketService = WebSocketService('ws://$ip:$port');
    _webSocketService.connect();
    
    // Listen to high-frequency data but don't update UI immediately
    _webSocketService.latestData.addListener(_onHighFrequencyDataUpdate);
    
    // Start throttled UI update timer
    _startUIUpdateTimer();
  }

  @override
  void dispose() {
    _uiUpdateTimer?.cancel();
    _webSocketService.latestData.removeListener(_onHighFrequencyDataUpdate);
    _webSocketService.dispose();
    super.dispose();
  }

  /// Receives data at full rate (20-50Hz) but only caches it
  void _onHighFrequencyDataUpdate() {
    final newData = _webSocketService.latestData.value;
    if (newData != null) {
      // Cache the latest data without updating UI
      _latestSensorData = newData;
      
      // Mark that we have pending UI update
      _pendingUIUpdate = true;
      
      // Process waveform data immediately (for ring buffer)
      _processWaveformData(newData);
    }
  }

  /// Process waveform data at full rate for accurate signal processing
  void _processWaveformData(SensorData data) {
    // Heart waveform processing
    double heartNormalized = 0.5 + (data.heartWaveform * 0.1);
    _heartWaveform.add(heartNormalized.clamp(0.1, 0.9));
    
    // Keep ring buffer size (120 points = 6 seconds at 20Hz)
    if (_heartWaveform.length > 120) {
      _heartWaveform.removeAt(0);
    }
    
    // Breathing waveform processing
    double breathNormalized = 0.5 + (data.breathWaveform * 0.15);
    _breathWaveform.add(breathNormalized.clamp(0.2, 0.8));
    
    if (_breathWaveform.length > 120) {
      _breathWaveform.removeAt(0);
    }
  }

  /// Start throttled UI update timer (10-20 Hz)
  void _startUIUpdateTimer() {
    _uiUpdateTimer = Timer.periodic(_uiUpdateInterval, (timer) {
      // Only update UI if there's pending data
      if (_pendingUIUpdate && mounted) {
        setState(() {
          // UI will rebuild with latest cached data
        });
        _pendingUIUpdate = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use cached data for UI rendering
    final data = _latestSensorData;
    
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with connection status
              const Text("mmWave Vital Monitor",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              
              const SizedBox(height: 20),

              // Sensor Information Widget
              _buildSensorInfoWidget(data),
              const SizedBox(height: 20),

              // Stats Grid with throttled updates
              _buildStatsGrid(data),
              const SizedBox(height: 20),

              // Heartbeat Waveform (full rate ring buffer)
              const SectionTitle(
                title: "Heartbeat Signal",
                subtitle: "Live",
                icon: Icons.show_chart,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF151B2D),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: WaveformChart(
                  data: _heartWaveform.isNotEmpty 
                      ? _heartWaveform 
                      : List.generate(120, (i) => 0.5 + 0.3 * sin(2 * pi * i / 20)),
                  color: Colors.redAccent,
                ),
              ),
              const SizedBox(height: 20),

              // Breathing Waveform (full rate ring buffer)
              const SectionTitle(
                title: "Breathing Signal",
                subtitle: "Live",
                icon: Icons.air,
                color: Color(0xFF2BE4DC),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF151B2D),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: WaveformChart(
                  data: _breathWaveform.isNotEmpty 
                      ? _breathWaveform 
                      : List.generate(120, (i) => 0.5 + 0.2 * sin(2 * pi * i / 30)),
                  color: const Color(0xFF2BE4DC),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build sensor information widget with throttled data
  Widget _buildSensorInfoWidget(SensorData? data) {
    double detectionRange = 1.35; 
    int rangeProfile = 27;  
    double maxRange = 2.5; // in meters
    int percentage = 57; 
    bool isReceivingData = data != null && _webSocketService.isConnected.value;
    
    if (data != null) {
      // Calculate values from cached full-rate data
      if (data.rangeProfile.isNotEmpty) {
        int maxIndex = 0;
        double maxValue = 0;
        for (int i = 0; i < data.rangeProfile.length; i++) {
          if (data.rangeProfile[i] > maxValue) {
            maxValue = data.rangeProfile[i];
            maxIndex = i;
          }
        }
        detectionRange = 0.3 + (maxIndex / 64.0) * 1.3;
        rangeProfile = maxIndex;
        
        // Calculate max range based on sensor specifications
        maxRange = 0.3 + (data.rangeProfile.length / 64.0) * 2.2; // Assuming 64 bins cover ~2.5m
      }
      
      // Calculate signal quality based on energy levels
      double signalStrength = (data.heartEnergy + data.breathEnergy) / 35;
      percentage = (signalStrength.clamp(0, 100)).toInt();
    }
    
    return SensorInfoWidget(
      detectionRange: detectionRange,
      rangeProfile: rangeProfile,
      maxRange: maxRange,
      percentage: percentage,
      isReceivingData: isReceivingData,
    );
  }

  /// Build stats grid with throttled data
  Widget _buildStatsGrid(SensorData? data) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(  
                icon: Icons.favorite,
                color: Colors.redAccent,
                label: "Heart Rate",
                value: "${data?.heartRate.toInt() ?? 73}",
                unit: "BPM",
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: StatCard(
                icon: Icons.monitor_heart,
                color: Colors.greenAccent,
                label: "HR Energy",
                value: "${data?.heartEnergy.toInt() ?? 500}",
                unit: "units",
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.air,
                color: const Color(0xFF2BE4DC),
                label: "Breathing",
                value: "${data?.breathRate.toInt() ?? 13}",
                unit: "breaths/min",
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: StatCard(
                icon: Icons.bolt,
                color: const Color(0xFF9C6BFF),
                label: "Breath Energy",
                value: "${data?.breathEnergy.toInt() ?? 1000}",
                unit: "units",
              ),
            ),
          ],
        ),
      ],
    );
  }
}