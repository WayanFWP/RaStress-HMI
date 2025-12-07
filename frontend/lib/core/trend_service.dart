import 'dart:async';
import 'package:flutter/foundation.dart';
import 'sensor_model.dart';
import 'constants/app_constants.dart';

class TrendDataPoint {
  final DateTime timestamp;
  final double heartRate;
  final double breathRate;

  TrendDataPoint({
    required this.timestamp,
    required this.heartRate,
    required this.breathRate,
  });

  @override
  String toString() =>
      'TrendDataPoint(time: $timestamp, HR: ${heartRate.toStringAsFixed(1)}, BR: ${breathRate.toStringAsFixed(1)})';
}

class TrendService {
  final ValueNotifier<List<TrendDataPoint>> trendData = ValueNotifier([]);

  Timer? _aggregationTimer;
  final List<double> _heartRateBuffer = [];
  final List<double> _breathRateBuffer = [];

  TrendService() {
    _startAggregation();
  }

  void _startAggregation() {
    _aggregationTimer = Timer.periodic(
      AppConstants.trendAggregationInterval,
      (_) => _aggregateData(),
    );
  }

  void _aggregateData() {
    if (_heartRateBuffer.isEmpty || _breathRateBuffer.isEmpty) return;

    final avgHeartRate = _calculateAverage(_heartRateBuffer);
    final avgBreathRate = _calculateAverage(_breathRateBuffer);

    _addTrendPoint(avgHeartRate, avgBreathRate);
    _clearBuffers();
  }

  double _calculateAverage(List<double> values) {
    return values.reduce((a, b) => a + b) / values.length;
  }

  void _addTrendPoint(double heartRate, double breathRate) {
    final newData = List<TrendDataPoint>.from(trendData.value);
    newData.add(
      TrendDataPoint(
        timestamp: DateTime.now(),
        heartRate: heartRate,
        breathRate: breathRate,
      ),
    );

    // Keep only recent data points
    if (newData.length > AppConstants.trendDataMaxPoints) {
      newData.removeAt(0);
    }

    trendData.value = newData;
  }

  void _clearBuffers() {
    _heartRateBuffer.clear();
    _breathRateBuffer.clear();
  }

  void addSensorData(SensorData data) {
    _heartRateBuffer.add(data.heartRate);
    _breathRateBuffer.add(data.breathRate);
  }

  void dispose() {
    _aggregationTimer?.cancel();
    trendData.dispose();
  }
}
