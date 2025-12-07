import 'package:flutter/material.dart';
import 'dart:math' as math;

class WaveFormCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final String unit;
  final List<double> waveformData;
  final String yAxisLabel;
  final double minYValue;
  final double maxYValue;

  const WaveFormCard({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.unit,
    required this.waveformData,
    this.yAxisLabel = '',
    this.minYValue = 0.0,
    this.maxYValue = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with icon, label, and value
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  unit,
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Waveform chart with grid and axes
          SizedBox(
            height: 140,
            child: Row(
              children: [
                // Y-axis labels
                SizedBox(
                  width: 25,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        maxYValue.toStringAsFixed(0),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                      Text(
                        ((maxYValue + minYValue) / 2).toStringAsFixed(0),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                      Text(
                        minYValue.toStringAsFixed(0),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Waveform with grid
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: CustomPaint(
                          painter: _WaveFormPainter(waveformData, color),
                          size: const Size(double.infinity, double.infinity),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // X-axis timestamps
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "-6s",
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),
                          Text(
                            "-3s",
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),
                          Text(
                            "now",
                            style: TextStyle(
                              fontSize: 10,
                              color: color.withOpacity(0.8),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Y-axis label
          if (yAxisLabel.isNotEmpty) ...[
            const SizedBox(height: 8),
            Center(
              child: Text(
                yAxisLabel,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.4),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _WaveFormPainter extends CustomPainter {
  final List<double> data;
  final Color color;

  _WaveFormPainter(this.data, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    const padding = 1.0;
    final width = size.width - padding * 2;
    final height = size.height - padding * 2;

    // Draw grid
    _drawGrid(canvas, size, width, height, padding);

    if (data.isEmpty) return;

    // Draw filled area under waveform
    _drawFilledArea(canvas, size, width, height, padding);

    // Draw waveform line
    _drawWaveformLine(canvas, size, width, height, padding);
  }

  void _drawGrid(
    Canvas canvas,
    Size size,
    double width,
    double height,
    double padding,
  ) {
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Horizontal grid lines (4 lines)
    for (int i = 1; i <= 4; i++) {
      final y = (height / 5) * i + padding;
      canvas.drawLine(
        Offset(padding, y),
        Offset(width + padding, y),
        gridPaint,
      );
    }

    // Vertical grid lines (3 lines)
    for (int i = 1; i <= 3; i++) {
      final x = (width / 4) * i + padding;
      canvas.drawLine(
        Offset(x, padding),
        Offset(x, height + padding),
        gridPaint,
      );
    }

    // Draw border
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    canvas.drawRect(
      Rect.fromLTWH(padding, padding, width, height),
      borderPaint,
    );
  }

  void _drawFilledArea(
    Canvas canvas,
    Size size,
    double width,
    double height,
    double padding,
  ) {
    if (data.isEmpty) return;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withOpacity(0.3), color.withOpacity(0.05)],
      ).createShader(Rect.fromLTWH(padding, padding, width, height))
      ..style = PaintingStyle.fill;

    final fillPath = Path();
    fillPath.moveTo(padding, height + padding);

    for (int i = 0; i < data.length; i++) {
      double x = (i / (data.length - 1)) * width + padding;
      double y = (1 - data[i]) * height + padding;
      fillPath.lineTo(x, y);
    }

    fillPath.lineTo(width + padding, height + padding);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
  }

  void _drawWaveformLine(
    Canvas canvas,
    Size size,
    double width,
    double height,
    double padding,
  ) {
    if (data.isEmpty) return;

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final linePath = Path();

    for (int i = 0; i < data.length; i++) {
      double x = (i / (data.length - 1)) * width + padding;
      double y = (1 - data[i]) * height + padding;

      if (i == 0) {
        linePath.moveTo(x, y);
      } else {
        linePath.lineTo(x, y);
      }
    }

    canvas.drawPath(linePath, linePaint);

    // Draw glow effect
    final glowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    canvas.drawPath(linePath, glowPaint);
  }

  @override
  bool shouldRepaint(_WaveFormPainter oldDelegate) => true;
}
