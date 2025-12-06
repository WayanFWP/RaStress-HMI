import 'dart:async';
import 'package:flutter/foundation.dart';
import 'sensor_model.dart';

class TrendDataPoint {
  final DateTime timestamp;
  final double heartRate;
  final double breathRate;

  TrendDataPoint({
    required this.timestamp,
    required this.heartRate,
    required this.breathRate,
  });
}

class TrendService {
  final ValueNotifier<List<TrendDataPoint>> trendData = ValueNotifier([]);
  
  Timer? _aggregationTimer;
  List<double> _heartRateBuffer = [];
  List<double> _breathRateBuffer = [];
  
  // Store data every 5 seconds for 3 minutes (36 data points)
  static const Duration _aggregationInterval = Duration(seconds: 5);
  static const int _maxDataPoints = 36; // 3 minutes / 5 seconds

  TrendService() {
    _startAggregation();
  }

  void _startAggregation() {
    _aggregationTimer = Timer.periodic(_aggregationInterval, (timer) {
      if (_heartRateBuffer.isNotEmpty && _breathRateBuffer.isNotEmpty) {
        // Calculate average for this interval
        final avgHeartRate = _heartRateBuffer.reduce((a, b) => a + b) / _heartRateBuffer.length;
        final avgBreathRate = _breathRateBuffer.reduce((a, b) => a + b) / _breathRateBuffer.length;
        
        // Add new data point
        final newData = List<TrendDataPoint>.from(trendData.value);
        newData.add(TrendDataPoint(
          timestamp: DateTime.now(),
          heartRate: avgHeartRate,
          breathRate: avgBreathRate,
        ));
        
        // Keep only last 36 data points (3 minutes)
        if (newData.length > _maxDataPoints) {
          newData.removeAt(0);
        }
        
        trendData.value = newData;
        
        // Clear buffers
        _heartRateBuffer.clear();
        _breathRateBuffer.clear();
      }
    });
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