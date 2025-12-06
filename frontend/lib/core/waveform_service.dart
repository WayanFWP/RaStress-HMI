import 'dart:async';
import 'package:flutter/foundation.dart';
import 'sensor_model.dart';

class WaveformService {
  final ValueNotifier<List<double>> heartWaveform = ValueNotifier([]);
  final ValueNotifier<List<double>> breathWaveform = ValueNotifier([]);

  static const int maxBufferSize = 120; // 6 seconds at 20Hz

  void processWaveformData(SensorData data) {
    // Heart waveform processing
    double heartNormalized = 0.5 + (data.heartWaveform * 0.1);
    final newHeartWaveform = List<double>.from(heartWaveform.value);
    newHeartWaveform.add(heartNormalized.clamp(0.1, 0.9));

    // Keep ring buffer size
    if (newHeartWaveform.length > maxBufferSize) {
      newHeartWaveform.removeAt(0);
    }
    heartWaveform.value = newHeartWaveform;

    // Breathing waveform processing
    double breathNormalized = 0.5 + (data.breathWaveform * 0.15);
    final newBreathWaveform = List<double>.from(breathWaveform.value);
    newBreathWaveform.add(breathNormalized.clamp(0.2, 0.8));

    // Keep ring buffer size
    if (newBreathWaveform.length > maxBufferSize) {
      newBreathWaveform.removeAt(0);
    }
    breathWaveform.value = newBreathWaveform;
  }

  void dispose() {
    heartWaveform.dispose();
    breathWaveform.dispose();
  }
}