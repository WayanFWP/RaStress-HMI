import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/stress_level_service.dart';
import '../screens/stress_detail_screen.dart';

class CircularStressIndicator extends StatefulWidget {
  final StressLevelData? stressData;
  final VitalsSnapshot? vitalsSnapshot;
  final bool isReceivingData;
  final StressLevelService stressLevelService;

  const CircularStressIndicator({
    super.key,
    required this.stressData,
    required this.vitalsSnapshot,
    required this.isReceivingData,
    required this.stressLevelService,
  });

  @override
  State<CircularStressIndicator> createState() =>
      _CircularStressIndicatorState();
}

class _CircularStressIndicatorState extends State<CircularStressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _animationController.forward();
  }

  @override
  void didUpdateWidget(CircularStressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stressData?.level != widget.stressData?.level) {
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Default values
    Color levelColor = Colors.grey;
    IconData levelIcon = Icons.psychology;
    String levelLabel = "Analyzing...";
    String description = "Collecting data to analyze stress levels";
    double progressValue = 0.0;

    if (widget.stressData != null && widget.isReceivingData) {
      switch (widget.stressData!.level) {
        case StressLevel.relaxed:
          levelColor = Colors.green;
          levelIcon = Icons.spa;
          levelLabel = "Relaxed";
          description = "Your vitals indicate a calm and relaxed state";
          progressValue = 0.33;
          break;
        case StressLevel.normal:
          levelColor = Colors.orange;
          levelIcon = Icons.self_improvement;
          levelLabel = "Normal";
          description = "Your vitals are within normal range";
          progressValue = 0.66;
          break;
        case StressLevel.highStress:
          levelColor = Colors.red;
          levelIcon = Icons.warning_amber_rounded;
          levelLabel = "High Stress";
          description = "Elevated heart rate and breathing detected";
          progressValue = 1.0;
          break;
      }
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StressDetailScreen(
              stressLevelService: widget.stressLevelService,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color:  Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: levelColor.withOpacity(0.3), width: 2),
        ),
        child: Row(
          children: [
            // Circular Progress Ring
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(120, 120),
                  painter: _CircularProgressPainter(
                    progress: progressValue * _animation.value,
                    color: levelColor,
                    backgroundColor: levelColor.withOpacity(0.1),
                  ),
                  child: SizedBox(
                    width: 120,
                    height: 120,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: levelColor.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(levelIcon, color: levelColor, size: 40),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 24),

            // Text Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Stress Level",
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    levelLabel,
                    style: TextStyle(
                      fontSize: 28,
                      color: levelColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 12, color: Colors.white54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  _CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 12.0;

    // Draw background ring
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius - strokeWidth / 2, backgroundPaint);

    // Draw progress ring
    final progressPaint = Paint()
      ..shader = LinearGradient(
        colors: [color, color.withOpacity(0.7)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
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

    // Add glow effect
    if (progress > 0) {
      final glowPaint = Paint()
        ..color = color.withOpacity(0.3)
        ..strokeWidth = strokeWidth + 4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        sweepAngle,
        false,
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
