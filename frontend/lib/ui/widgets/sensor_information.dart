import 'package:flutter/material.dart';

class SensorInfoWidget extends StatelessWidget {
  final double detectionRange;
  final int rangeProfile;
  final double maxRange;
  final int percentage;
  final bool isReceivingData;

  const SensorInfoWidget({
    super.key,
    required this.detectionRange,
    required this.rangeProfile,
    required this.maxRange,
    required this.percentage,
    required this.isReceivingData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151B2D),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF2BE4DC).withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.sensors, color: const Color(0xFF2BE4DC), size: 18),
              const SizedBox(width: 8),
              const Text(
                "Sensor Information (mmVS Radar Sensor)",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Detection Range Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.radar, color: Colors.white70, size: 16),
                      const SizedBox(width: 6),
                      const Text(
                        "Detection Range",
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "${detectionRange.toStringAsFixed(2)}m",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    "Range Bin",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "$rangeProfile",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Max Range and Data Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.zoom_out_map, color: Colors.white70, size: 16),
                      const SizedBox(width: 6),
                      const Text(
                        "Max Range",
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "${maxRange.toStringAsFixed(1)}m",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Icon(
                        isReceivingData ? Icons.wifi : Icons.wifi_off,
                        color: isReceivingData ? Colors.green : Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "API Status",
                        style: TextStyle(
                          color: isReceivingData ? Colors.green : Colors.red,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isReceivingData ? "Receiving" : "No Data",
                    style: TextStyle(
                      color: isReceivingData ? Colors.green : Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Signal Quality Section
          Row(
            children: [
              Icon(Icons.signal_cellular_alt, color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              const Text(
                "Signal Quality",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Progress Bar Section
          Row(
            children: [
              // Progress Bar
              Expanded(
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.grey.withOpacity(0.3),
                  ),
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          gradient: const LinearGradient(
                            colors: [
                              Colors.red,
                              Colors.orange,
                              Colors.yellow,
                              Colors.green,
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          gradient: LinearGradient(
                            stops: [percentage / 100, percentage / 100],
                            colors: [Colors.transparent, Colors.grey.withOpacity(0.8)],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Percentage
              Text(
                "$percentage%",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Quality Description
          Text(
            _getQualityDescription(percentage),
            style: TextStyle(
              color: _getQualityColor(percentage),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),

          // Info Text
          Row(
            children: [
              Icon(Icons.info_outline, color: const Color(0xFF2BE4DC), size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "For best results, position yourself 0.5-2m from the sensor and remain still during measurement.",
                  style: TextStyle(
                    color: const Color(0xFF2BE4DC).withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getQualityDescription(int percentage) {
    if (percentage >= 80) {
      return "Excellent signal quality - Optimal for accurate measurements";
    } else if (percentage >= 60) {
      return "Good signal quality - Reliable measurements expected";
    } else if (percentage >= 40) {
      return "Fair signal quality - Some measurements may vary";
    } else if (percentage >= 20) {
      return "Poor signal quality - Consider repositioning";
    } else {
      return "Very poor signal - Please check sensor connection";
    }
  }

  Color _getQualityColor(int percentage) {
    if (percentage >= 80) {
      return Colors.green;
    } else if (percentage >= 60) {
      return Colors.lightGreen;
    } else if (percentage >= 40) {
      return Colors.yellow;
    } else if (percentage >= 20) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}