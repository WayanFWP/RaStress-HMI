import 'package:flutter/material.dart';
import '../constants/ui_constants.dart';

class StatCardWithWaveform extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final String unit;
  final List<double> waveformData;

  const StatCardWithWaveform({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.unit,
    required this.waveformData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(UIConstants.cardPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(UIConstants.cardBorderRadius),
        border: Border.all(
          color: color.withOpacity(.4),
          width: UIConstants.mediumBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Single row with icon, label, and value
          Row(
            children: [
              Icon(icon, color: color, size: UIConstants.mediumIconSize),
              const SizedBox(width: UIConstants.smallPadding),
              Text(
                label,
                style: TextStyle(
                  fontSize: UIConstants.bodyFontSize,
                  color: UIConstants.getSecondaryText(context),
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 32,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  unit,
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Waveform chart
          SizedBox(
            height: 80,
            child: CustomPaint(
              painter: _MiniWaveformPainter(waveformData, color),
              size: const Size(double.infinity, 80),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniWaveformPainter extends CustomPainter {
  final List<double> data;
  final Color color;

  _MiniWaveformPainter(this.data, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    // Draw waveform line
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw filled area under waveform
    final fillPaint = Paint()
      ..color = color.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    const padding = 4.0;
    final width = size.width - padding * 2;
    final height = size.height - padding * 2;

    // Create line path
    final linePath = Path();

    // Create fill path
    final fillPath = Path();
    fillPath.moveTo(padding, size.height - padding);

    for (int i = 0; i < data.length; i++) {
      double x = (i / (data.length - 1)) * width + padding;
      double y = (1 - data[i]) * height + padding;

      if (i == 0) {
        linePath.moveTo(x, y);
        fillPath.lineTo(x, y);
      } else {
        linePath.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    // Close fill path
    fillPath.lineTo(width + padding, size.height - padding);
    fillPath.close();

    // Draw fill first, then line
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(_) => true;
}
