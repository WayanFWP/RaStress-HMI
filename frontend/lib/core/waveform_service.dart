import 'package:flutter/foundation.dart';
import 'sensor_model.dart';
import 'constants/app_constants.dart';

class WaveformService {
  final ValueNotifier<List<double>> heartWaveform = ValueNotifier([]);
  final ValueNotifier<List<double>> breathWaveform = ValueNotifier([]);

  void processWaveformData(SensorData data) {
    _processHeartWaveform(data.heartWaveform);
    _processBreathWaveform(data.breathWaveform);
  }

  void _processHeartWaveform(double rawValue) {
    final normalized = _normalizeHeartWaveform(rawValue);
    _updateWaveformBuffer(heartWaveform, normalized);
  }

  void _processBreathWaveform(double rawValue) {
    final normalized = _normalizeBreathWaveform(rawValue);
    _updateWaveformBuffer(breathWaveform, normalized);
  }

  double _normalizeHeartWaveform(double rawValue) {
    return (0.5 + (rawValue * 0.1)).clamp(0.1, 0.9);
  }

  double _normalizeBreathWaveform(double rawValue) {
    return (0.5 + (rawValue * 0.15)).clamp(0.2, 0.8);
  }

  void _updateWaveformBuffer(
    ValueNotifier<List<double>> waveform,
    double value,
  ) {
    final buffer = List<double>.from(waveform.value);
    buffer.add(value);

    if (buffer.length > AppConstants.waveformBufferSize) {
      buffer.removeAt(0);
    }

    waveform.value = buffer;
  }

  void dispose() {
    heartWaveform.dispose();
    breathWaveform.dispose();
  }
}
