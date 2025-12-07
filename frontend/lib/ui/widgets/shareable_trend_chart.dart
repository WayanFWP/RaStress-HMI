import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/trend_service.dart';

class ShareableTrendChart extends StatelessWidget {
  final List<TrendDataPoint> trendData;

  const ShareableTrendChart({super.key, required this.trendData});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1920, // Changed to landscape (wider)
      height: 1080, // Changed to landscape (shorter)
      color: const Color(0xFF0A0F1C),
      child: Stack(
        children: [
          // Background: Full trend charts
          Positioned.fill(child: _buildBackgroundCharts()),

          // Foreground: Stats overlay
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(50),
              child: Row(
                children: [
                  // Left side - Title and date
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Row(
                              children: [
                                Icon(
                                  Icons.sensors,
                                  color: const Color(0xFF2BE4DC),
                                  size: 32,
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'VITAL MONITOR',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 40),

                            // Title
                            const Text(
                              'Vital Signs',
                              style: TextStyle(
                                fontSize: 56,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.1,
                              ),
                            ),
                            const Text(
                              'Trends',
                              style: TextStyle(
                                fontSize: 56,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Date & Time
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    DateFormat(
                                      'EEEE, MMM dd, yyyy',
                                    ).format(DateTime.now()),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    DateFormat('HH:mm').format(DateTime.now()),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 40),

                  // Right side - Stats overlay
                  Expanded(
                    flex: 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [_buildStatsOverlay()],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundCharts() {
    final hrValues = trendData.map((d) => d.heartRate).toList();
    final brValues = trendData.map((d) => d.breathRate).toList();

    final minHR = hrValues.reduce((a, b) => a < b ? a : b);
    final maxHR = hrValues.reduce((a, b) => a > b ? a : b);
    final minBR = brValues.reduce((a, b) => a < b ? a : b);
    final maxBR = brValues.reduce((a, b) => a > b ? a : b);

    return Column(
      children: [
        // Heart Rate background chart (top half)
        Expanded(
          child: CustomPaint(
            painter: _BackgroundChartPainter(
              values: hrValues,
              minValue: minHR,
              maxValue: maxHR,
              lineColor: Colors.redAccent,
            ),
            child: Container(),
          ),
        ),

        // Breathing Rate background chart (bottom half)
        Expanded(
          child: CustomPaint(
            painter: _BackgroundChartPainter(
              values: brValues,
              minValue: minBR,
              maxValue: maxBR,
              lineColor: const Color(0xFF2BE4DC),
            ),
            child: Container(),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsOverlay() {
    final hrValues = trendData.map((d) => d.heartRate).toList();
    final brValues = trendData.map((d) => d.breathRate).toList();

    final avgHR = hrValues.reduce((a, b) => a + b) / hrValues.length;
    final avgBR = brValues.reduce((a, b) => a + b) / brValues.length;

    final stressLevel = _calculateStressLevel(avgHR, avgBR);
    final stressColor = _getStressColor(avgHR, avgBR);

    return Container(
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        // color: const Color(0xFF000000).withOpacity(0.8), // Darker background
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          // Heart Rate
          _buildMetricRow(
            Icons.favorite,
            avgHR.toStringAsFixed(0),
            'BPM',
            'Avg Heart Rate',
            Colors.redAccent,
          ),

          const SizedBox(height: 28),

          // Breathing Rate
          _buildMetricRow(
            Icons.air,
            avgBR.toStringAsFixed(0),
            'breaths/min',
            'Avg Breathing Rate',
            const Color(0xFF2BE4DC),
          ),

          const SizedBox(height: 28),

          // Stress Level
          _buildMetricRow(
            Icons.psychology,
            stressLevel,
            '',
            'Stress Level',
            stressColor,
          ),

          const SizedBox(height: 32),
          Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.0),
                  Colors.white.withOpacity(0.3),
                  Colors.white.withOpacity(0.0),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Duration info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildInfoItem(Icons.schedule, 'Duration', _getDuration()),
              Container(
                width: 2,
                height: 40,
                color: Colors.white.withOpacity(0.2),
              ),
              _buildInfoItem(
                Icons.show_chart,
                'Data Points',
                '${trendData.length}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(
    IconData icon,
    String value,
    String unit,
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.5), width: 2),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: 24),

          // Label
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white, // Changed to pure white
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Value
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: color,
                  height: 1,
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    unit,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white, // Changed to pure white
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF2BE4DC)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white, // Changed to pure white
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white, // Changed to pure white
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _calculateStressLevel(double avgHR, double avgBR) {
    if (avgHR > 100 || avgBR > 20) {
      return 'High';
    } else if (avgHR > 80 || avgBR > 16) {
      return 'Moderate';
    } else {
      return 'Low';
    }
  }

  Color _getStressColor(double avgHR, double avgBR) {
    if (avgHR > 100 || avgBR > 20) {
      return Colors.redAccent;
    } else if (avgHR > 80 || avgBR > 16) {
      return Colors.orangeAccent;
    } else {
      return Colors.greenAccent;
    }
  }

  String _getDuration() {
    if (trendData.isEmpty) return '0 min';

    final duration = trendData.last.timestamp.difference(
      trendData.first.timestamp,
    );
    final minutes = duration.inMinutes;

    if (minutes < 1) {
      return '${duration.inSeconds}s';
    } else if (minutes < 60) {
      return '${minutes}m';
    } else {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      return '${hours}h ${mins}m';
    }
  }
}

class _BackgroundChartPainter extends CustomPainter {
  final List<double> values;
  final double minValue;
  final double maxValue;
  final Color lineColor;

  _BackgroundChartPainter({
    required this.values,
    required this.minValue,
    required this.maxValue,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    const padding = 40.0;
    final width = size.width - padding * 2;
    final height = size.height - padding * 2;

    final range = maxValue - minValue;
    if (range <= 0) return;

    // Draw subtle grid
    _drawGrid(canvas, size, padding);

    // Draw filled area with gradient
    _drawFilledArea(canvas, size, width, height, padding, range);

    // Draw line
    _drawLine(canvas, size, width, height, padding, range);

    // Draw points
    _drawPoints(canvas, size, width, height, padding, range);
  }

  void _drawGrid(Canvas canvas, Size size, double padding) {
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Horizontal lines
    for (int i = 1; i <= 3; i++) {
      final y = (size.height / 4) * i;
      canvas.drawLine(
        Offset(padding, y),
        Offset(size.width - padding, y),
        gridPaint,
      );
    }
  }

  void _drawFilledArea(
    Canvas canvas,
    Size size,
    double width,
    double height,
    double padding,
    double range,
  ) {
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [lineColor.withOpacity(0.4), lineColor.withOpacity(0.1)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final fillPath = Path();
    fillPath.moveTo(padding, height + padding);

    for (int i = 0; i < values.length; i++) {
      final x = (i / (values.length - 1)) * width + padding;
      final normalizedValue = (values[i] - minValue) / range;
      final y = height + padding - (normalizedValue * height);
      fillPath.lineTo(x, y);
    }

    fillPath.lineTo(width + padding, height + padding);
    fillPath.close();
    canvas.drawPath(fillPath, fillPaint);
  }

  void _drawLine(
    Canvas canvas,
    Size size,
    double width,
    double height,
    double padding,
    double range,
  ) {
    final linePaint = Paint()
      ..color = lineColor.withOpacity(0.95)
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final linePath = Path();

    for (int i = 0; i < values.length; i++) {
      final x = (i / (values.length - 1)) * width + padding;
      final normalizedValue = (values[i] - minValue) / range;
      final y = height + padding - (normalizedValue * height);

      if (i == 0) {
        linePath.moveTo(x, y);
      } else {
        linePath.lineTo(x, y);
      }
    }

    canvas.drawPath(linePath, linePaint);
  }

  void _drawPoints(
    Canvas canvas,
    Size size,
    double width,
    double height,
    double padding,
    double range,
  ) {
    final pointPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    // Only draw points if there aren't too many
    if (values.length <= 50) {
      for (int i = 0; i < values.length; i++) {
        final x = (i / (values.length - 1)) * width + padding;
        final normalizedValue = (values[i] - minValue) / range;
        final y = height + padding - (normalizedValue * height);

        canvas.drawCircle(Offset(x, y), 7.0, borderPaint);
        canvas.drawCircle(Offset(x, y), 5.0, pointPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_BackgroundChartPainter oldDelegate) => true;
}
