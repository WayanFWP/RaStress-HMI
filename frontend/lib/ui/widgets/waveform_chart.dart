import 'package:flutter/material.dart';
import 'dart:math';

class WaveformChart extends StatelessWidget {
  final List<double> data;
  final Color color;

  const WaveformChart({
    super.key,
    required this.data,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _WaveformPainter(data, color),
      size: const Size(double.infinity, 160),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final List<double> data;
  final Color color;

  _WaveformPainter(this.data, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const padding = 6.0;
    final width = size.width - padding * 2;
    final height = size.height - padding * 2;

    if (data.isEmpty) return;

    final path = Path();
    for (int i = 0; i < data.length; i++) {
      double x = (i / (data.length - 1)) * width + padding;
      double y = (1 - data[i]) * height + padding;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => true;
}
