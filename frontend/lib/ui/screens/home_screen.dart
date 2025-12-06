import 'package:flutter/material.dart';
import '../../core/trend_service.dart';
import '../../core/websocket_services.dart';
import 'trend_detail_screen.dart';

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

    // Calculate averages
    double avgHeartRate = 0;
    double avgBreathRate = 0;

    if (trendData.isNotEmpty) {
      final heartRates = trendData.map((d) => d.heartRate).toList();
      final breathRates = trendData.map((d) => d.breathRate).toList();
      avgHeartRate = heartRates.reduce((a, b) => a + b) / heartRates.length;
      avgBreathRate = breathRates.reduce((a, b) => a + b) / breathRates.length;
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Dashboard",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  // Connection Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isReceivingData ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isReceivingData ? Colors.green : Colors.red,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isReceivingData ? Icons.circle : Icons.circle,
                          color: isReceivingData ? Colors.green : Colors.red,
                          size: 8,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isReceivingData ? "Live" : "No Data",
                          style: TextStyle(
                            color: isReceivingData ? Colors.green : Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Compact Vital Averages Card - Tappable
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TrendDetailScreen(
                        trendService: widget.trendService,
                        webSocketService: widget.webSocketService,
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF151B2D),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0xFF2BE4DC).withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Vital Trends Summary",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: const Color(0xFF2BE4DC),
                            size: 18,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Heart Rate Average
                      Row(
                        children: [
                          Icon(Icons.favorite, color: Colors.redAccent, size: 24),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Heart Rate",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 4),
                              trendData.isEmpty
                                  ? const Text(
                                      "-- BPM",
                                      style: TextStyle(
                                        fontSize: 24,
                                        color: Colors.white38,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : Text(
                                      "${avgHeartRate.toStringAsFixed(1)} BPM",
                                      style: const TextStyle(
                                        fontSize: 24,
                                        color: Colors.redAccent,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Breathing Rate Average
                      Row(
                        children: [
                          Icon(Icons.air, color: const Color(0xFF2BE4DC), size: 24),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Breathing Rate",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 4),
                              trendData.isEmpty
                                  ? const Text(
                                      "-- breaths/min",
                                      style: TextStyle(
                                        fontSize: 24,
                                        color: Colors.white38,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : Text(
                                      "${avgBreathRate.toStringAsFixed(1)} breaths/min",
                                      style: const TextStyle(
                                        fontSize: 24,
                                        color: Color(0xFF2BE4DC),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Hint to tap
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.touch_app,
                              color: Colors.white38,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Tap to view detailed trends",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white38,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Info text when no data
              if (trendData.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(Icons.timeline, size: 64, color: Colors.white24),
                        const SizedBox(height: 16),
                        Text(
                          "Collecting data...\nAverages will appear after 3 seconds",
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
}