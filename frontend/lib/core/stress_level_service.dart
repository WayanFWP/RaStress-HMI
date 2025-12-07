import 'dart:async';
import 'package:flutter/foundation.dart';
import 'sensor_model.dart';
import 'constants/app_constants.dart';

enum StressLevel { relaxed, normal, highStress }

enum AlertType {
  highHeartRate,
  lowHeartRate,
  highBreathingRate,
  lowBreathingRate,
  suddenMovement,
}

class VitalAlert {
  final AlertType type;
  final String message;
  final double value;
  final DateTime timestamp;

  VitalAlert({
    required this.type,
    required this.message,
    required this.value,
    required this.timestamp,
  });
}

class StressLevelData {
  final StressLevel level;
  final String label;
  final DateTime timestamp;

  StressLevelData({
    required this.level,
    required this.label,
    required this.timestamp,
  });
}

class VitalsSnapshot {
  final double heartRate;
  final double breathingRate;
  final double chestDisplacement;
  final List<VitalAlert> activeAlerts;
  final DateTime timestamp;

  VitalsSnapshot({
    required this.heartRate,
    required this.breathingRate,
    required this.chestDisplacement,
    required this.activeAlerts,
    required this.timestamp,
  });
}

class StressLevelService {
  final ValueNotifier<StressLevelData?> currentStressLevel = ValueNotifier(
    null,
  );
  final ValueNotifier<VitalsSnapshot?> currentVitals = ValueNotifier(null);
  final ValueNotifier<List<VitalAlert>> activeAlerts = ValueNotifier([]);

  // Buffers for averaging data over time
  final List<double> _heartRateBuffer = [];
  final List<double> _breathRateBuffer = [];
  final List<double> _heartEnergyBuffer = [];
  final List<double> _breathEnergyBuffer = [];
  final List<double> _chestDisplacementBuffer = [];

  Timer? _analysisTimer;
  double? _lastChestDisplacement;

  StressLevelService() {
    _startAnalysis();
  }

  void _startAnalysis() {
    _analysisTimer = Timer.periodic(AppConstants.stressAnalysisInterval, (
      timer,
    ) {
      if (_heartRateBuffer.isNotEmpty &&
          _breathRateBuffer.isNotEmpty &&
          _heartEnergyBuffer.isNotEmpty &&
          _breathEnergyBuffer.isNotEmpty &&
          _chestDisplacementBuffer.isNotEmpty) {
        _analyzeStressLevel();
        _checkVitalAlerts();
      }
    });
  }

  void addSensorData(SensorData data) {
    // Add to buffers
    _heartRateBuffer.add(data.heartRate);
    _breathRateBuffer.add(data.breathRate);
    _heartEnergyBuffer.add(data.heartEnergy);
    _breathEnergyBuffer.add(data.breathEnergy);
    _chestDisplacementBuffer.add(data.chestDisplacement);

    // Keep buffer size limited
    if (_heartRateBuffer.length > AppConstants.sensorDataBufferSize) {
      _heartRateBuffer.removeAt(0);
      _breathRateBuffer.removeAt(0);
      _heartEnergyBuffer.removeAt(0);
      _breathEnergyBuffer.removeAt(0);
      _chestDisplacementBuffer.removeAt(0);
    }
  }

  void _checkVitalAlerts() {
    final avgHeartRate =
        _heartRateBuffer.reduce((a, b) => a + b) / _heartRateBuffer.length;
    final avgBreathRate =
        _breathRateBuffer.reduce((a, b) => a + b) / _breathRateBuffer.length;
    final avgChestDisplacement =
        _chestDisplacementBuffer.reduce((a, b) => a + b) /
        _chestDisplacementBuffer.length;

    List<VitalAlert> newAlerts = [];

    // Check heart rate alerts
    if (avgHeartRate > AppConstants.highHeartRateThreshold) {
      newAlerts.add(
        VitalAlert(
          type: AlertType.highHeartRate,
          message:
              "Heart rate elevated above ${AppConstants.highHeartRateThreshold.toInt()} BPM",
          value: avgHeartRate,
          timestamp: DateTime.now(),
        ),
      );
    } else if (avgHeartRate < AppConstants.lowHeartRateThreshold) {
      newAlerts.add(
        VitalAlert(
          type: AlertType.lowHeartRate,
          message:
              "Heart rate below ${AppConstants.lowHeartRateThreshold.toInt()} BPM",
          value: avgHeartRate,
          timestamp: DateTime.now(),
        ),
      );
    }

    // Check breathing rate alerts
    if (avgBreathRate > AppConstants.highBreathingRateThreshold) {
      newAlerts.add(
        VitalAlert(
          type: AlertType.highBreathingRate,
          message:
              "Breathing rate elevated above ${AppConstants.highBreathingRateThreshold.toInt()} breaths/min",
          value: avgBreathRate,
          timestamp: DateTime.now(),
        ),
      );
    } else if (avgBreathRate < AppConstants.lowBreathingRateThreshold) {
      newAlerts.add(
        VitalAlert(
          type: AlertType.lowBreathingRate,
          message:
              "Breathing rate below ${AppConstants.lowBreathingRateThreshold.toInt()} breaths/min",
          value: avgBreathRate,
          timestamp: DateTime.now(),
        ),
      );
    }

    // Check sudden chest displacement (possible cough or motion)
    if (_lastChestDisplacement != null) {
      final displacementChange =
          (avgChestDisplacement - _lastChestDisplacement!).abs();
      if (displacementChange > AppConstants.suddenDisplacementThreshold) {
        newAlerts.add(
          VitalAlert(
            type: AlertType.suddenMovement,
            message: "Sudden movement detected (possible cough or motion)",
            value: displacementChange,
            timestamp: DateTime.now(),
          ),
        );
      }
    }
    _lastChestDisplacement = avgChestDisplacement;

    // Update active alerts
    activeAlerts.value = newAlerts;

    // Update current vitals snapshot
    currentVitals.value = VitalsSnapshot(
      heartRate: avgHeartRate,
      breathingRate: avgBreathRate,
      chestDisplacement: avgChestDisplacement,
      activeAlerts: newAlerts,
      timestamp: DateTime.now(),
    );

    if (kDebugMode && newAlerts.isNotEmpty) {
      print("=== VITAL ALERTS ===");
      for (var alert in newAlerts) {
        print("${alert.type}: ${alert.message}");
      }
    }
  }

  void _analyzeStressLevel() {
    // Calculate averages
    final avgHeartRate =
        _heartRateBuffer.reduce((a, b) => a + b) / _heartRateBuffer.length;
    final avgBreathRate =
        _breathRateBuffer.reduce((a, b) => a + b) / _breathRateBuffer.length;
    final avgHeartEnergy =
        _heartEnergyBuffer.reduce((a, b) => a + b) / _heartEnergyBuffer.length;
    final avgBreathEnergy =
        _breathEnergyBuffer.reduce((a, b) => a + b) /
        _breathEnergyBuffer.length;

    // Stress indicators scoring
    int stressScore = 0;

    // 1. Heart Rate Analysis
    if (avgHeartRate > 120) {
      stressScore += 3;
    } else if (avgHeartRate > 100) {
      stressScore += 2;
    } else if (avgHeartRate > 80) {
      stressScore += 1;
    }

    // 2. Breathing Rate Analysis
    if (avgBreathRate > 25) {
      stressScore += 3;
    } else if (avgBreathRate > 20) {
      stressScore += 2;
    } else if (avgBreathRate > 16) {
      stressScore += 1;
    }

    // 3. Heart Energy Analysis
    if (avgHeartEnergy > 150) {
      stressScore += 2;
    } else if (avgHeartEnergy > 100) {
      stressScore += 1;
    }

    // 4. Breath Energy Analysis
    if (avgBreathEnergy > 150) {
      stressScore += 2;
    } else if (avgBreathEnergy > 100) {
      stressScore += 1;
    }

    // Determine stress level
    StressLevel level;
    String label;

    if (stressScore <= 2) {
      level = StressLevel.relaxed;
      label = "Relaxed";
    } else if (stressScore <= 5) {
      level = StressLevel.normal;
      label = "Normal";
    } else {
      level = StressLevel.highStress;
      label = "High Stress";
    }

    currentStressLevel.value = StressLevelData(
      level: level,
      label: label,
      timestamp: DateTime.now(),
    );
  }

  void dispose() {
    _analysisTimer?.cancel();
    currentStressLevel.dispose();
    currentVitals.dispose();
    activeAlerts.dispose();
  }
}
