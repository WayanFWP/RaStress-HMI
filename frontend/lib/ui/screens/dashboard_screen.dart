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
import '../widgets/stat_card_w_chart.dart';

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

  // UI update interval (in seconds) duration
  static const Duration _uiUpdateInterval = Duration(seconds: 2);

  @override
  void initState() {
    super.initState();

    final ip = dotenv.env['IP'] ?? '';
    final port = dotenv.env['PORT'] ?? '';

    _webSocketService = WebSocketService('ws://$ip:$port');
    _webSocketService.connect();

    // Listen to high-frequency data but don't update UI immediately
    _webSocketService.latestData.addListener(_onHighFrequencyDataUpdate);

    // Listen to data receiving status changes (update immediately)
    _webSocketService.isReceivingData.addListener(_onDataStatusChange);

    // Start throttled UI update timer
    _startUIUpdateTimer();
  }

  @override
  void dispose() {
    _uiUpdateTimer?.cancel();
    _webSocketService.latestData.removeListener(_onHighFrequencyDataUpdate);
    _webSocketService.isReceivingData.removeListener(_onDataStatusChange);
    _webSocketService.dispose();
    super.dispose();
  }

  /// Receives data at full rate but only caches it
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

  /// Handle data receiving status changes (update UI immediately for status)
  void _onDataStatusChange() {
    if (mounted) {
      setState(() {
        // Rebuild UI when data receiving status changes
      });
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

  /// Start throttled UI update timer (every 500ms)
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
    final data = _latestSensorData;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                "mmWave Vital Monitor",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Stats Grid with integrated waveforms (1x2 layout)
              _buildStatsGrid(data),
              const SizedBox(height: 20),

              // Sensor Information Widget
              _buildSensorInfoWidget(data),
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

    // Check if actually receiving data (not just connected)
    bool isReceivingData = _webSocketService.isReceivingData.value;

    if (data != null && isReceivingData) {
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
        maxRange =
            0.3 +
            (data.rangeProfile.length / 64.0) *
                2.2; // Assuming 64 bins cover ~2.5m
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
        // Heart Rate Card with Waveform
        StatCardWithWaveform(
          icon: Icons.favorite,
          color: Colors.redAccent,
          label: "Heart Rate",
          value: "${data?.heartRate.toInt() ?? 73}",
          unit: "BPM",
          waveformData: _heartWaveform.isNotEmpty
              ? _heartWaveform
              : List.generate(120, (i) => 0.5 + 0.3 * sin(2 * pi * i / 20)),
        ),
        const SizedBox(height: 14),

        // Breathing Card with Waveform
        StatCardWithWaveform(
          icon: Icons.air,
          color: const Color(0xFF2BE4DC),
          label: "Breathing Rate",
          value: "${data?.breathRate.toInt() ?? 13}",
          unit: "breaths/min",
          waveformData: _breathWaveform.isNotEmpty
              ? _breathWaveform
              : List.generate(120, (i) => 0.5 + 0.2 * sin(2 * pi * i / 30)),
        ),
      ],
    );
  }
}
