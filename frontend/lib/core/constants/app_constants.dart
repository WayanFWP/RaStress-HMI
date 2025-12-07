/// Application-wide constants
class AppConstants {
  AppConstants._();

  // Sensor Configuration
  static const int rangeProfileBins = 64;
  static const double minDetectionRange = 0.3; // meters
  static const double maxDetectionRange = 2.5; // meters
  static const double detectionRangeCoverage = 2.2; // meters (2.5 - 0.3)

  // Peak Detection
  static const double peakThresholdRatio = 0.3; // 30% of strongest peak
  static const double minimumPeakSeparation = 0.3; // meters

  // Vital Signs Thresholds
  static const double highHeartRateThreshold = 100.0; // BPM
  static const double lowHeartRateThreshold = 50.0; // BPM
  static const double normalHeartRateMin = 60.0; // BPM
  static const double normalHeartRateMax = 100.0; // BPM

  static const double highBreathingRateThreshold = 25.0; // breaths/min
  static const double lowBreathingRateThreshold = 10.0; // breaths/min
  static const double normalBreathingRateMin = 12.0; // breaths/min
  static const double normalBreathingRateMax = 20.0; // breaths/min

  static const double suddenDisplacementThreshold = 5.0; // mm

  // Data Buffering
  static const int sensorDataBufferSize = 100; // ~5 seconds at 20Hz
  static const int waveformBufferSize = 120; // 6 seconds at 20Hz
  static const int trendDataMaxPoints = 100; // 5 minutes at 3-second intervals

  // Timing
  static const Duration stressAnalysisInterval = Duration(seconds: 5);
  static const Duration trendAggregationInterval = Duration(seconds: 3);
  static const Duration dataTimeoutDuration = Duration(seconds: 3);
  static const Duration uiUpdateInterval = Duration(seconds: 1);

  // WebSocket
  static const Duration reconnectDelay = Duration(seconds: 2);

  // Signal Quality
  static const int excellentSignalThreshold = 80;
  static const int goodSignalThreshold = 60;
  static const int fairSignalThreshold = 40;
  static const int poorSignalThreshold = 20;

  // Stress Level Calculation
  static const double relaxedHeartRateMax = 70.0; // BPM
  static const double relaxedBreathingRateMax = 15.0; // breaths/min
  static const double highStressHeartRateMin = 90.0; // BPM
  static const double highStressBreathingRateMin = 20.0; // breaths/min

  // UI Constants
  static const double cardBorderRadius = 18.0;
  static const double sectionSpacing = 16.0;
  static const double defaultPadding = 20.0;

  // Chart Constants
  static const double chartHeight = 160.0;
  static const double waveformHeight = 80.0;
  static const double chartPadding = 4.0;
  static const double strokeWidth = 2.0;
  static const double progressRingWidth = 12.0;

  // Animation
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration pulseAnimationDuration = Duration(seconds: 2);
}
