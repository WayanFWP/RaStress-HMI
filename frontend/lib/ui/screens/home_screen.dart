import 'package:flutter/material.dart';
import '../../core/trend_service.dart';
import '../../core/websocket_services.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  final TrendService trendService;
  final WebSocketService webSocketService;

  const HomeScreen({
    super.key,
    required this.trendService,
    required this.webSocketService,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    widget.trendService.trendData.addListener(_onTrendUpdate);
  }

  @override
  void dispose() {
    widget.trendService.trendData.removeListener(_onTrendUpdate);
    super.dispose();
  }

  void _onTrendUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final trendData = widget.trendService.trendData.value;
    final isReceivingData = widget.webSocketService.isReceivingData.value;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                "Vital Trends",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "Last 3 minutes",
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 24),

              // Connection Status
              _buildConnectionStatus(isReceivingData),
              const SizedBox(height: 24),

              // Heart Rate Trend
              _buildTrendCard(
                title: "Heart Rate",
                subtitle: "BPM",
                icon: Icons.favorite,
                color: Colors.redAccent,
                data: trendData,
                isHeartRate: true,
              ),
              const SizedBox(height: 20),

              // Breathing Rate Trend
              _buildTrendCard(
                title: "Breathing Rate",
                subtitle: "breaths/min",
                icon: Icons.air,
                color: const Color(0xFF2BE4DC),
                data: trendData,
                isHeartRate: false,
              ),
              const SizedBox(height: 20),

              // Info text
              if (trendData.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.timeline,
                          size: 64,
                          color: Colors.white24,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Collecting data...\nTrends will appear after 5 seconds",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 14,
                          ),
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

  Widget _buildConnectionStatus(bool isReceiving) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151B2D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isReceiving ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isReceiving ? Icons.check_circle : Icons.error,
            color: isReceiving ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            isReceiving ? "Receiving data" : "No data received",
            style: TextStyle(
              color: isReceiving ? Colors.green : Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
      final values = data.map((d) => isHeartRate ? d.heartRate : d.breathRate).toList();
      avgValue = values.reduce((a, b) => a + b) / values.length;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF151B2D),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon, label and average value
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Avg",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white54,
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        avgValue.toInt().toString(),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Bar chart with timestamps
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
              : _buildBarChartWithTimestamps(data, color, isHeartRate),
        ],
      ),
    );
  }

  Widget _buildBarChartWithTimestamps(List<TrendDataPoint> data, Color color, bool isHeartRate) {
    if (data.isEmpty) return const SizedBox();

    final values = data.map((d) => isHeartRate ? d.heartRate : d.breathRate).toList();
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final range = maxValue - minValue;

    // Time formatter
    final timeFormat = DateFormat('HH:mm:ss');

    return Column(
      children: [
        // Bar chart
        SizedBox(
          height: 100,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(data.length, (index) {
              final value = values[index];
              final normalizedHeight = range > 0 ? ((value - minValue) / range) : 0.5;
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
        ),
        const SizedBox(height: 12),
        
        // Timestamps - Fixed horizontal layout
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // First timestamp (left)
            Text(
              timeFormat.format(data.first.timestamp),
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white54,
              ),
            ),
            // Middle timestamp (center) - only if we have enough data
            if (data.length > 2)
              Text(
                timeFormat.format(data[data.length ~/ 2].timestamp),
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white54,
                ),
              ),
            // Last timestamp (right)
            Text(
              timeFormat.format(data.last.timestamp),
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white54,
              ),
            ),
          ],
        ),
      ],
    );
  }
}