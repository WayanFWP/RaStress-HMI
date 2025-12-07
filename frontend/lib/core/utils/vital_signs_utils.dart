import '../stress_level_service.dart';
import '../constants/app_constants.dart';

/// Utility functions for vital signs analysis
class VitalSignsUtils {
  VitalSignsUtils._();

  /// Calculate stress level based on heart rate and breathing rate
  static StressLevel calculateStressLevel(double heartRate, double breathRate) {
    // High stress: elevated heart rate OR elevated breathing rate
    if (heartRate > AppConstants.highStressHeartRateMin ||
        breathRate > AppConstants.highStressBreathingRateMin) {
      return StressLevel.highStress;
    }

    // Relaxed: both heart rate and breathing rate are low
    if (heartRate < AppConstants.relaxedHeartRateMax &&
        breathRate < AppConstants.relaxedBreathingRateMax) {
      return StressLevel.relaxed;
    }

    // Normal: everything in between
    return StressLevel.normal;
  }

  /// Get stress level label
  static String getStressLevelLabel(StressLevel level) {
    switch (level) {
      case StressLevel.relaxed:
        return "Relaxed";
      case StressLevel.normal:
        return "Normal";
      case StressLevel.highStress:
        return "High Stress";
    }
  }

  /// Check if heart rate is in normal range
  static bool isHeartRateNormal(double heartRate) {
    return heartRate >= AppConstants.normalHeartRateMin &&
        heartRate <= AppConstants.normalHeartRateMax;
  }

  /// Check if breathing rate is in normal range
  static bool isBreathingRateNormal(double breathRate) {
    return breathRate >= AppConstants.normalBreathingRateMin &&
        breathRate <= AppConstants.normalBreathingRateMax;
  }

  /// Get heart rate status description
  static String getHeartRateStatus(double heartRate) {
    if (heartRate > AppConstants.highHeartRateThreshold) {
      return "High";
    } else if (heartRate < AppConstants.lowHeartRateThreshold) {
      return "Low";
    } else {
      return "Normal";
    }
  }

  /// Get breathing rate status description
  static String getBreathingRateStatus(double breathRate) {
    if (breathRate > AppConstants.highBreathingRateThreshold) {
      return "High";
    } else if (breathRate < AppConstants.lowBreathingRateThreshold) {
      return "Low";
    } else {
      return "Normal";
    }
  }

  /// Get signal quality description
  static String getSignalQualityDescription(int percentage) {
    if (percentage >= AppConstants.excellentSignalThreshold) {
      return "Excellent signal quality - Optimal for accurate measurements";
    } else if (percentage >= AppConstants.goodSignalThreshold) {
      return "Good signal quality - Reliable measurements expected";
    } else if (percentage >= AppConstants.fairSignalThreshold) {
      return "Fair signal quality - Some measurements may vary";
    } else if (percentage >= AppConstants.poorSignalThreshold) {
      return "Poor signal quality - Consider repositioning";
    } else {
      return "Very poor signal - Please check sensor connection";
    }
  }

  /// Calculate average from list
  static double calculateAverage(List<double> values) {
    if (values.isEmpty) return 0.0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  /// Find minimum value in list
  static double findMin(List<double> values) {
    if (values.isEmpty) return 0.0;
    return values.reduce((a, b) => a < b ? a : b);
  }

  /// Find maximum value in list
  static double findMax(List<double> values) {
    if (values.isEmpty) return 0.0;
    return values.reduce((a, b) => a > b ? a : b);
  }
}
