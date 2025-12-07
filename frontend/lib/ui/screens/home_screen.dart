import 'package:flutter/material.dart';
import '../../core/trend_service.dart';
import '../../core/websocket_services.dart';
import '../../core/stress_level_service.dart';
import '../../core/range_profile_analyzer.dart';
import '../constants/ui_constants.dart';
import '../widgets/circular_stress_indicator.dart';
import '../widgets/common/status_badge.dart';
import '../widgets/common/alert_card.dart';
import 'trend_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final TrendService trendService;
  final WebSocketService webSocketService;
  final StressLevelService stressLevelService;

  const HomeScreen({
    super.key,
    required this.trendService,
    required this.webSocketService,
    required this.stressLevelService,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _hasMultipleSources = false;
  int _sourceCount = 0;

  @override
  void initState() {
    super.initState();
    widget.trendService.trendData.addListener(_onTrendUpdate);
    widget.stressLevelService.currentStressLevel.addListener(_onStressUpdate);
    widget.webSocketService.latestData.addListener(_onDataUpdate);
  }

  @override
  void dispose() {
    widget.trendService.trendData.removeListener(_onTrendUpdate);
    widget.stressLevelService.currentStressLevel.removeListener(
      _onStressUpdate,
    );
    widget.webSocketService.latestData.removeListener(_onDataUpdate);
    super.dispose();
  }

  void _onTrendUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onStressUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onDataUpdate() {
    final data = widget.webSocketService.latestData.value;
    if (data != null && data.rangeProfile.isNotEmpty) {
      final hasMultiple = RangeProfileAnalyzer.hasMultipleSources(
        data.rangeProfile,
      );
      final count = RangeProfileAnalyzer.getSourceCount(data.rangeProfile);

      if (_hasMultipleSources != hasMultiple || _sourceCount != count) {
        if (mounted) {
          setState(() {
            _hasMultipleSources = hasMultiple;
            _sourceCount = count;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final trendData = widget.trendService.trendData.value;
    final isReceivingData = widget.webSocketService.isReceivingData.value;
    final stressData = widget.stressLevelService.currentStressLevel.value;

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
              _buildHeader(isReceivingData),
              const SizedBox(height: UIConstants.extraLargeSpacing),

              // Multiple Sources Warning (if detected)
              if (_hasMultipleSources && isReceivingData)
                _buildMultipleSourcesWarning(),

              // Circular Stress Level Indicator Card
              CircularStressIndicator(
                stressData: stressData,
                vitalsSnapshot: widget.stressLevelService.currentVitals.value,
                isReceivingData: isReceivingData,
                stressLevelService: widget.stressLevelService, // Add this line
              ),

              const SizedBox(height: 16),

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
                          Icon(
                            Icons.favorite,
                            color: Colors.redAccent,
                            size: 24,
                          ),
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
                          Icon(
                            Icons.air,
                            color: const Color(0xFF2BE4DC),
                            size: 24,
                          ),
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

  /// Build header with title and status badge
  Widget _buildHeader(bool isReceivingData) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Dashboard",
          style: TextStyle(
            fontSize: UIConstants.largeTitleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        StatusBadge(isActive: isReceivingData),
      ],
    );
  }

  /// Build multiple sources warning alert
  Widget _buildMultipleSourcesWarning() {
    return AlertCard(
      icon: Icons.warning_amber_rounded,
      color: Colors.orange,
      title: "Multiple Sources Detected",
      message:
          "Multiple breathing sources detected — stand alone for accurate measurements.",
      badge: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: UIConstants.smallPadding,
          vertical: UIConstants.tinySpacing,
        ),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(UIConstants.mediumOpacity),
          borderRadius: BorderRadius.circular(UIConstants.buttonBorderRadius),
        ),
        child: Text(
          "$_sourceCount targets",
          style: const TextStyle(
            fontSize: UIConstants.captionFontSize,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
      ),
    );
  }
}
