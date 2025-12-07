class SensorData {
  final double heartRate;
  final double breathRate;
  final double heartEnergy;
  final double breathEnergy;
  final List<double> rangeProfile;
  final double heartWaveform;
  final double breathWaveform;
  final double chestDisplacement;

  SensorData({
    required this.heartRate,
    required this.breathRate,
    required this.heartEnergy,
    required this.breathEnergy,
    required this.rangeProfile,
    required this.heartWaveform,
    required this.breathWaveform,
    required this.chestDisplacement,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    final vitals = json["vitals"] ?? {};

    return SensorData(
      heartRate: vitals["heartRateEst_FFT"]?.toDouble() ?? 0.0,
      breathRate: vitals["breathingRateEst_FFT"]?.toDouble() ?? 0.0,
      heartEnergy: vitals["sumEnergyHeartWfm"]?.toDouble() ?? 0.0,
      breathEnergy: vitals["sumEnergyBreathWfm"]?.toDouble() ?? 0.0,
      heartWaveform: vitals["outputFilterHeartOut"]?.toDouble() ?? 0.0,
      breathWaveform: vitals["outputFilterBreathOut"]?.toDouble() ?? 0.0,
      chestDisplacement: vitals["unwrapPhasePeak_mm"]?.toDouble() ?? 0.0,
      rangeProfile: (vitals["RangeProfile"] != null)
          ? List<double>.from(vitals["RangeProfile"].map((v) => v.toDouble()))
          : [],
    );
  }
}
