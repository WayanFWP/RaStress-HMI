import 'package:flutter/material.dart';
import '../../core/stress_level_service.dart';
import 'dart:math' as math;

class StressDetailScreen extends StatefulWidget {
  final StressLevelService stressLevelService;

  const StressDetailScreen({super.key, required this.stressLevelService});

  @override
  State<StressDetailScreen> createState() => _StressDetailScreenState();
}

class _StressDetailScreenState extends State<StressDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Listen to real-time updates
    widget.stressLevelService.currentVitals.addListener(_onVitalsUpdate);
    widget.stressLevelService.currentStressLevel.addListener(_onStressUpdate);
  }

  @override
  void dispose() {
    widget.stressLevelService.currentVitals.removeListener(_onVitalsUpdate);
    widget.stressLevelService.currentStressLevel.removeListener(
      _onStressUpdate,
    );
    super.dispose();
  }

  void _onVitalsUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onStressUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final vitalsSnapshot = widget.stressLevelService.currentVitals.value;
    final stressData = widget.stressLevelService.currentStressLevel.value;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1C),
      appBar: AppBar(
        title: const Text("Vital Analysis"),
        backgroundColor: const Color(0xFF151B2D),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Overall Stress Level Summary
              _buildStressSummary(stressData),

              const SizedBox(height: 24),

              // Active Alerts Section
              if (vitalsSnapshot != null &&
                  vitalsSnapshot.activeAlerts.isNotEmpty) ...[
                _buildAlertsSection(vitalsSnapshot),
                const SizedBox(height: 24),
              ],

              // Heart Rate Analysis
              _buildVitalCard(
                title: "Heart Rate",
                value: vitalsSnapshot?.heartRate ?? 0,
                unit: "BPM",
                icon: Icons.favorite,
                color: Colors.redAccent,
                normalRange: "60-100 BPM",
                status: _getHeartRateStatus(vitalsSnapshot),
                description: _getHeartRateDescription(vitalsSnapshot),
              ),

              const SizedBox(height: 16),

              // Breathing Rate Analysis
              _buildVitalCard(
                title: "Breathing Rate",
                value: vitalsSnapshot?.breathingRate ?? 0,
                unit: "breaths/min",
                icon: Icons.air,
                color: const Color(0xFF2BE4DC),
                normalRange: "12-20 breaths/min",
                status: _getBreathingRateStatus(vitalsSnapshot),
                description: _getBreathingRateDescription(vitalsSnapshot),
              ),

              const SizedBox(height: 16),

              // Chest Displacement Analysis
              _buildVitalCard(
                title: "Chest Displacement",
                value: vitalsSnapshot?.chestDisplacement ?? 0,
                unit: "mm",
                icon: Icons.straighten,
                color: Colors.purple,
                normalRange: "2-8 mm",
                status: _getChestDisplacementStatus(vitalsSnapshot),
                description: _getChestDisplacementDescription(vitalsSnapshot),
              ),

              const SizedBox(height: 24),

              // Info footer
              _buildInfoFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStressSummary(StressLevelData? stressData) {
    final color = _getStressColor(stressData);
    final label = stressData?.label ?? "Analyzing...";

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(_getStressIcon(stressData), color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Overall Stress Level",
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 28,
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsSection(VitalsSnapshot vitalsSnapshot) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.notifications_active, color: Colors.orange, size: 20),
            SizedBox(width: 8),
            Text(
              "Active Alerts",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...vitalsSnapshot.activeAlerts.map((alert) => _buildAlertItem(alert)),
      ],
    );
  }

  Widget _buildAlertItem(VitalAlert alert) {
    Color alertColor = Colors.orange;
    IconData alertIcon = Icons.warning_amber_rounded;

    switch (alert.type) {
      case AlertType.highHeartRate:
      case AlertType.lowHeartRate:
        alertColor = Colors.red;
        alertIcon = Icons.favorite;
        break;
      case AlertType.highBreathingRate:
      case AlertType.lowBreathingRate:
        alertColor = Colors.orange;
        alertIcon = Icons.air;
        break;
      case AlertType.suddenMovement:
        alertColor = Colors.yellow;
        alertIcon = Icons.motion_photos_on;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: alertColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: alertColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(alertIcon, color: alertColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              alert.message,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalCard({
    required String title,
    required double value,
    required String unit,
    required IconData icon,
    required Color color,
    required String normalRange,
    required String status,
    required String description,
  }) {
    final progress = _calculateProgress(title, value);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF151B2D),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Circular progress indicator
              SizedBox(
                width: 80,
                height: 80,
                child: CustomPaint(
                  painter: _MiniCircularProgressPainter(
                    progress: progress,
                    color: color,
                    backgroundColor: color.withOpacity(0.1),
                  ),
                  child: Center(child: Icon(icon, color: color, size: 28)),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          value.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 32,
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            unit,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: color, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      "Status: $status",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(fontSize: 13, color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Text(
                  "Normal range: $normalRange",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white54,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151B2D).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.white.withOpacity(0.5),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "This analysis is updated every 5 seconds based on averaged sensor data. Consult healthcare professionals for medical concerns.",
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods for status and descriptions
  String _getHeartRateStatus(VitalsSnapshot? vitalsSnapshot) {
    final hr = vitalsSnapshot?.heartRate ?? 0;
    if (hr > 100) return "Elevated";
    if (hr < 50) return "Low";
    if (hr >= 60 && hr <= 100) return "Normal";
    return "Check reading";
  }

  String _getHeartRateDescription(VitalsSnapshot? vitalsSnapshot) {
    final hr = vitalsSnapshot?.heartRate ?? 0;
    if (hr > 120) {
      return "Your heart rate is significantly elevated. This may indicate high stress, physical activity, or anxiety. Consider relaxation techniques.";
    } else if (hr > 100) {
      return "Your heart rate is moderately elevated. This is common during stress or light activity. Monitor for changes.";
    } else if (hr < 50) {
      return "Your heart rate is low. This may be normal for athletes but could indicate other issues. Consult a doctor if you feel unwell.";
    } else if (hr >= 60 && hr <= 100) {
      return "Your heart rate is within normal resting range. This indicates good cardiovascular health.";
    }
    return "Heart rate data being collected.";
  }

  String _getBreathingRateStatus(VitalsSnapshot? vitalsSnapshot) {
    final br = vitalsSnapshot?.breathingRate ?? 0;
    if (br > 25) return "Rapid";
    if (br < 10) return "Slow";
    if (br >= 12 && br <= 20) return "Normal";
    return "Check reading";
  }

  String _getBreathingRateDescription(VitalsSnapshot? vitalsSnapshot) {
    final br = vitalsSnapshot?.breathingRate ?? 0;
    if (br > 25) {
      return "Your breathing rate is elevated. This may indicate stress, anxiety, or physical exertion. Practice deep breathing exercises.";
    } else if (br < 10) {
      return "Your breathing rate is low. This may indicate deep relaxation or could be a concern. Monitor closely.";
    } else if (br >= 12 && br <= 20) {
      return "Your breathing rate is within normal range. This indicates comfortable, relaxed breathing.";
    }
    return "Breathing rate data being collected.";
  }

  String _getChestDisplacementStatus(VitalsSnapshot? vitalsSnapshot) {
    final cd = vitalsSnapshot?.chestDisplacement ?? 0;
    if (cd > 10) return "High";
    if (cd < 2) return "Low";
    if (cd >= 2 && cd <= 8) return "Normal";
    return "Check reading";
  }

  String _getChestDisplacementDescription(VitalsSnapshot? vitalsSnapshot) {
    final cd = vitalsSnapshot?.chestDisplacement ?? 0;
    if (cd > 10) {
      return "Large chest displacement detected. This may indicate deep breathing, coughing, or body movement. Ensure you're sitting still for accurate readings.";
    } else if (cd < 2) {
      return "Minimal chest displacement. This may indicate shallow breathing or positioning issues. Ensure proper sensor alignment.";
    } else if (cd >= 2 && cd <= 8) {
      return "Normal chest displacement range. This indicates healthy breathing depth and good sensor positioning.";
    }
    return "Chest displacement data being collected.";
  }

  double _calculateProgress(String title, double value) {
    switch (title) {
      case "Heart Rate":
        return (value / 120).clamp(0.0, 1.0);
      case "Breathing Rate":
        return (value / 30).clamp(0.0, 1.0);
      case "Chest Displacement":
        return (value / 12).clamp(0.0, 1.0);
      default:
        return 0.5;
    }
  }

  Color _getStressColor(StressLevelData? stressData) {
    if (stressData == null) return Colors.grey;
    switch (stressData.level) {
      case StressLevel.relaxed:
        return Colors.green;
      case StressLevel.normal:
        return Colors.orange;
      case StressLevel.highStress:
        return Colors.red;
    }
  }

  IconData _getStressIcon(StressLevelData? stressData) {
    if (stressData == null) return Icons.psychology;
    switch (stressData.level) {
      case StressLevel.relaxed:
        return Icons.spa;
      case StressLevel.normal:
        return Icons.self_improvement;
      case StressLevel.highStress:
        return Icons.warning_amber_rounded;
    }
  }
}

class _MiniCircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  _MiniCircularProgressPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 8.0;

    // Background ring
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius - strokeWidth / 2, backgroundPaint);

    // Progress ring
    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_MiniCircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
