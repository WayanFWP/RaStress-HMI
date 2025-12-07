import '../stress_level_service.dart';
import '../constants/app_constants.dart';

/// Helper class for checking vital signs alerts
class VitalAlertsChecker {
  VitalAlertsChecker._();

  /// Check all vital signs and return list of active alerts
  static List<VitalAlert> checkAlerts({
    required double avgHeartRate,
    required double avgBreathRate,
    required double avgChestDisplacement,
    required double? lastChestDisplacement,
  }) {
    final alerts = <VitalAlert>[];

    alerts.addAll(_checkHeartRateAlerts(avgHeartRate));
    alerts.addAll(_checkBreathingRateAlerts(avgBreathRate));
    alerts.addAll(
      _checkDisplacementAlerts(avgChestDisplacement, lastChestDisplacement),
    );

    return alerts;
  }

  static List<VitalAlert> _checkHeartRateAlerts(double heartRate) {
    final alerts = <VitalAlert>[];

    if (heartRate > AppConstants.highHeartRateThreshold) {
      alerts.add(
        VitalAlert(
          type: AlertType.highHeartRate,
          message:
              "Heart rate elevated above ${AppConstants.highHeartRateThreshold.toInt()} BPM",
          value: heartRate,
          timestamp: DateTime.now(),
        ),
      );
    } else if (heartRate < AppConstants.lowHeartRateThreshold) {
      alerts.add(
        VitalAlert(
          type: AlertType.lowHeartRate,
          message:
              "Heart rate below ${AppConstants.lowHeartRateThreshold.toInt()} BPM",
          value: heartRate,
          timestamp: DateTime.now(),
        ),
      );
    }

    return alerts;
  }

  static List<VitalAlert> _checkBreathingRateAlerts(double breathRate) {
    final alerts = <VitalAlert>[];

    if (breathRate > AppConstants.highBreathingRateThreshold) {
      alerts.add(
        VitalAlert(
          type: AlertType.highBreathingRate,
          message:
              "Breathing rate elevated above ${AppConstants.highBreathingRateThreshold.toInt()} breaths/min",
          value: breathRate,
          timestamp: DateTime.now(),
        ),
      );
    } else if (breathRate < AppConstants.lowBreathingRateThreshold) {
      alerts.add(
        VitalAlert(
          type: AlertType.lowBreathingRate,
          message:
              "Breathing rate below ${AppConstants.lowBreathingRateThreshold.toInt()} breaths/min",
          value: breathRate,
          timestamp: DateTime.now(),
        ),
      );
    }

    return alerts;
  }

  static List<VitalAlert> _checkDisplacementAlerts(
    double currentDisplacement,
    double? lastDisplacement,
  ) {
    final alerts = <VitalAlert>[];

    if (lastDisplacement != null) {
      final displacementChange = (currentDisplacement - lastDisplacement).abs();

      if (displacementChange > AppConstants.suddenDisplacementThreshold) {
        alerts.add(
          VitalAlert(
            type: AlertType.suddenMovement,
            message:
                "Sudden movement detected (${displacementChange.toStringAsFixed(1)}mm displacement)",
            value: displacementChange,
            timestamp: DateTime.now(),
          ),
        );
      }
    }

    return alerts;
  }
}
