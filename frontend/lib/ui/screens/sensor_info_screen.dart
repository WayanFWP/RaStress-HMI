import 'package:flutter/material.dart';
import '../widgets/stat_card.dart';
import '../widgets/section_title.dart';
import '../widgets/waveform_chart.dart';
import '../widgets/sensor_information.dart';
import '../../core/websocket_services.dart';
import '../../core/waveform_service.dart';
import '../../core/sensor_model.dart';
import 'dart:async';
import 'dart:math';
import '../widgets/stat_card_w_chart.dart';

class SensorInfoScreen extends StatefulWidget {
  final WebSocketService webSocketService;
  final WaveformService waveformService;

  const SensorInfoScreen({
    super.key,
    required this.webSocketService,
    required this.waveformService,
  });

  @override
  State<SensorInfoScreen> createState() => _SensorInfoScreenState();
}

class _SensorInfoScreenState extends State<SensorInfoScreen> {
  // UI throttling
  Timer? _uiUpdateTimer;
  bool _pendingUIUpdate = false;

  // Latest sensor data cache
  SensorData? _latestSensorData;

  // UI update interval (in seconds) duration
  static const Duration _uiUpdateInterval = Duration(seconds: 1);

  @override
  void initState() {
    super.initState();

    // Listen to high-frequency data but don't update UI immediately
    widget.webSocketService.latestData.addListener(_onHighFrequencyDataUpdate);

    // Listen to data receiving status changes (update immediately)
    widget.webSocketService.isReceivingData.addListener(_onDataStatusChange);

    // Listen to waveform changes for UI updates
    widget.waveformService.heartWaveform.addListener(_onWaveformUpdate);
    widget.waveformService.breathWaveform.addListener(_onWaveformUpdate);

    // Start throttled UI update timer
    _startUIUpdateTimer();
  }

  @override
  void dispose() {
    _uiUpdateTimer?.cancel();
    widget.webSocketService.latestData.removeListener(
      _onHighFrequencyDataUpdate,
    );
    widget.webSocketService.isReceivingData.removeListener(_onDataStatusChange);
    widget.waveformService.heartWaveform.removeListener(_onWaveformUpdate);
    widget.waveformService.breathWaveform.removeListener(_onWaveformUpdate);
    super.dispose();
  }

  /// Receives data at full rate but only caches it
  void _onHighFrequencyDataUpdate() {
    final newData = widget.webSocketService.latestData.value;
    if (newData != null) {
      // Cache the latest data without updating UI
      _latestSensorData = newData;

      // Mark that we have pending UI update
      _pendingUIUpdate = true;
    }
  }

  /// Handle waveform updates
  void _onWaveformUpdate() {
    _pendingUIUpdate = true;
  }

  /// Handle data receiving status changes (update UI immediately for status)
  void _onDataStatusChange() {
    if (mounted) {
      setState(() {
        // Rebuild UI when data receiving status changes
      });
    }
  }

  void _startUIUpdateTimer() {
    _uiUpdateTimer = Timer.periodic(_uiUpdateInterval, (timer) {
      if (_pendingUIUpdate && mounted) {
        setState(() {
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
              const Text(
                "Sensor Information",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              _buildSensorInfoWidget(data),
              const SizedBox(height: 20),

              _buildStatsGrid(data),
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
    bool isReceivingData = widget.webSocketService.isReceivingData.value;

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
    final heartWaveform = widget.waveformService.heartWaveform.value;
    final breathWaveform = widget.waveformService.breathWaveform.value;
    final chestDisplacement = data != null
        ? List<double>.generate(
            heartWaveform.length,
            (i) =>
                0.5 +
                0.25 *
                    sin(
                      2 * pi * i / 25 + (data.chestDisplacement / 10),
                    ), // phase shift
          )
        : <double>[];

    return Column(
      children: [
        // Heart Rate Card with Waveform
        StatCardWithWaveform(
          icon: Icons.favorite,
          color: Colors.redAccent,
          label: "Heart Rate",
          value: "${data?.heartRate.toInt() ?? 73}",
          unit: "BPM",
          waveformData: heartWaveform.isNotEmpty
              ? heartWaveform
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
          waveformData: breathWaveform.isNotEmpty
              ? breathWaveform
              : List.generate(120, (i) => 0.5 + 0.2 * sin(2 * pi * i / 30)),
        ),
        const SizedBox(height: 14),

        // Chest Displacement Card with Waveform
        StatCardWithWaveform(
          icon: Icons.start,
          color: const Color.fromARGB(255, 75, 185, 24),
          label: "Chest Displacement",
          value: "${data?.chestDisplacement.toInt() ?? 0}",
          unit: "a.u",
          waveformData: chestDisplacement.isNotEmpty
              ? chestDisplacement
              : List.generate(120, (i) => 0.5 + 0.25 * sin(2 * pi * i / 25)),
        ),
      ],
    );
  }
}
