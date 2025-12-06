import 'package:flutter/material.dart';
import '../../core/trend_service.dart';
import '../../core/websocket_services.dart';
import 'package:intl/intl.dart';

class TrendDetailScreen extends StatefulWidget {
  final TrendService trendService;
  final WebSocketService webSocketService;

  const TrendDetailScreen({
    super.key,
    required this.trendService,
    required this.webSocketService,
  });

  @override
  State<TrendDetailScreen> createState() => _TrendDetailScreenState();
}

class _TrendDetailScreenState extends State<TrendDetailScreen> {
  @override
  void initState() {
    super.initState();
    widget.trendService.trendData.addListener(_onTrendUpdate);
    widget.webSocketService.isReceivingData.addListener(_onConnectionUpdate);
  }

  @override
  void dispose() {
    widget.trendService.trendData.removeListener(_onTrendUpdate);
    widget.webSocketService.isReceivingData.removeListener(_onConnectionUpdate);
    super.dispose();
  }

  void _onTrendUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onConnectionUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final trendData = widget.trendService.trendData.value;
    final isReceivingData = widget.webSocketService.isReceivingData.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Vital Trends"),
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
            children: [
              // Heart Rate Trend
              _buildTrendCard(
                title: "Heart Rate",
                subtitle: "BPM",
                icon: Icons.favorite,
                color: Colors.redAccent,
                data: trendData,
                isHeartRate: true,
              ),
              const SizedBox(height: 18),

              // Breathing Rate Trend
              _buildTrendCard(
                title: "Breathing Rate",
                subtitle: "breaths/min",
                icon: Icons.air,
                color: const Color(0xFF2BE4DC),
                data: trendData,
                isHeartRate: false,
              ),
              const SizedBox(height: 18),

              // Info text
              if (trendData.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(Icons.timeline, size: 64, color: Colors.white24),
                        const SizedBox(height: 16),
                        Text(
                          "Collecting data...\nTrends will appear after 3 seconds",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white54, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrendCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required List<TrendDataPoint> data,
    required bool isHeartRate,
  }) {
    // Calculate average value
    double avgValue = 0;

    if (data.isNotEmpty) {
      final values = data
          .map((d) => isHeartRate ? d.heartRate : d.breathRate)
          .toList();
      avgValue = values.reduce((a, b) => a + b) / values.length;
    }

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon, label and average value (with padding)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Text(
                  data.isEmpty ? "--" : avgValue.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 20,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.white54),
                ),
              ],
            ),
          ),

          data.isEmpty
              ? SizedBox(
                  height: 120,
                  child: Center(
                    child: Text(
                      "Waiting for data...",
                      style: TextStyle(color: Colors.white38),
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                  child: _buildBarChartWithTimestamps(data, color, isHeartRate),
                ),
        ],
      ),
    );
  }

  Widget _buildBarChartWithTimestamps(
    List<TrendDataPoint> data,
    Color color,
    bool isHeartRate,
  ) {
    if (data.isEmpty) return const SizedBox();

    final values = data
        .map((d) => isHeartRate ? d.heartRate : d.breathRate)
        .toList();
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final range = maxValue - minValue;

    // Time formatter
    final timeFormat = DateFormat('HH:mm:ss');

    return Column(
      children: [
        // Bar chart with grid background
        SizedBox(
          height: 100,
          child: Stack(
            children: [
              // Background grid lines
              CustomPaint(
                painter: _GridPainter(),
                size: const Size(double.infinity, 100),
              ),

              // Bar chart on top
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(data.length, (index) {
                  final value = values[index];
                  final normalizedHeight = range > 0
                      ? ((value - minValue) / range)
                      : 0.5;
                  final height = (normalizedHeight * 80 + 20).clamp(8.0, 100.0);

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1.5),
                      child: Container(
                        height: height,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Timestamps - Fixed horizontal layout
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // First timestamp (left)
            Text(
              timeFormat.format(data.first.timestamp),
              style: const TextStyle(fontSize: 11, color: Colors.white54),
            ),
            // Middle timestamp (center) - only if we have enough data
            if (data.length > 2)
              Text(
                timeFormat.format(data[data.length ~/ 2].timestamp),
                style: const TextStyle(fontSize: 11, color: Colors.white54),
              ),
            // Last timestamp (right)
            Text(
              timeFormat.format(data.last.timestamp),
              style: const TextStyle(fontSize: 11, color: Colors.white54),
            ),
          ],
        ),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw 4 horizontal lines (dividing the chart into 5 sections)
    for (int i = 1; i <= 4; i++) {
      final y = (size.height / 5) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}