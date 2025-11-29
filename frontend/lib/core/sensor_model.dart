class SensorData {
  final double heartRate;
  final double breathRate;
  final double heartEnergy;
  final double breathEnergy;
  final List<double> rangeProfile;
  final double heartWaveform;  
  final double breathWaveform; 

  SensorData({
    required this.heartRate,
    required this.breathRate,
    required this.heartEnergy,
    required this.breathEnergy,
    required this.rangeProfile,
    required this.heartWaveform,
    required this.breathWaveform,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      heartRate: json["heartRateEst_FFT"]?.toDouble() ?? 0,
      breathRate: json["breathingRateEst_FFT"]?.toDouble() ?? 0,
      heartEnergy: json["sumEnergyHeartWfm"]?.toDouble() ?? 0,
      breathEnergy: json["sumEnergyBreathWfm"]?.toDouble() ?? 0,
      heartWaveform: json["outputFilterHeartOut"]?.toDouble() ?? 0,
      breathWaveform: json["outputFilterBreathOut"]?.toDouble() ?? 0,
      rangeProfile: (json["RangeProfile"] != null)
          ? List<double>.from(json["RangeProfile"].map((v) => v.toDouble()))
          : [],
    );
  }
}