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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(UIConstants.screenPadding),
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
                stressLevelService: widget.stressLevelService,
              ),

              const SizedBox(height: UIConstants.largeSpacing),

              // Compact Vital Averages Card - Tappable
              _buildVitalTrendsCard(
                context,
                trendData,
                avgHeartRate,
                avgBreathRate,
              ),

              const SizedBox(height: UIConstants.extraLargeSpacing),

              // Info text when no data
              if (trendData.isEmpty) _buildNoDataInfo(),
              
              // Add some bottom padding for safe scrolling
              const SizedBox(height: UIConstants.extraLargeSpacing),
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

  /// Build vital trends summary card
  Widget _buildVitalTrendsCard(
    BuildContext context,
    List<TrendDataPoint> trendData,
    double avgHeartRate,
    double avgBreathRate,
  ) {
    return GestureDetector(
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
        padding: const EdgeInsets.all(UIConstants.cardPadding),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(UIConstants.cardBorderRadius),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(
              UIConstants.mediumOpacity,
            ),
            width: UIConstants.mediumBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Vital Trends Summary",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Theme.of(context).colorScheme.primary,
                  size: UIConstants.smallIconSize,
                ),
              ],
            ),
            const SizedBox(height: UIConstants.cardPadding),

            // Heart Rate Average
            _buildVitalRow(
              context,
              Icons.favorite,
              Colors.redAccent,
              "Heart Rate",
              trendData.isEmpty ? "--" : avgHeartRate.toStringAsFixed(1),
              "BPM",
              trendData.isEmpty,
            ),
            const SizedBox(height: UIConstants.largeSpacing),

            // Breathing Rate Average
            _buildVitalRow(
              context,
              Icons.air,
              const Color(0xFF2BE4DC),
              "Breathing Rate",
              trendData.isEmpty ? "--" : avgBreathRate.toStringAsFixed(1),
              "breaths/min",
              trendData.isEmpty,
            ),
            const SizedBox(height: UIConstants.largeSpacing),

            // Hint to tap
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.touch_app,
                    color: UIConstants.getSecondaryText(context).withOpacity(0.5),
                    size: UIConstants.smallIconSize,
                  ),
                  const SizedBox(width: UIConstants.smallSpacing),
                  Text(
                    "Tap to view detailed trends",
                    style: TextStyle(
                      fontSize: UIConstants.captionFontSize,
                      color: UIConstants.getSecondaryText(context).withOpacity(0.5),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build a single vital sign row
  Widget _buildVitalRow(
    BuildContext context,
    IconData icon,
    Color color,
    String label,
    String value,
    String unit,
    bool isEmpty,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: UIConstants.largeIconSize),
        const SizedBox(width: UIConstants.mediumSpacing),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: UIConstants.bodyFontSize,
                color: UIConstants.getSecondaryText(context),
              ),
            ),
            const SizedBox(height: UIConstants.tinySpacing),
            Text(
              isEmpty ? "$value $unit" : "$value $unit",
              style: TextStyle(
                fontSize: UIConstants.displayFontSize - 8,
                color: isEmpty 
                    ? UIConstants.getSecondaryText(context).withOpacity(0.3)
                    : color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build no data information widget
  Widget _buildNoDataInfo() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.cardPadding * 1.5),
        child: Column(
          children: [
            Icon(
              Icons.timeline,
              size: UIConstants.extraLargeIconSize * 2,
              color: UIConstants.getSecondaryText(context).withOpacity(0.3),
            ),
            const SizedBox(height: UIConstants.largeSpacing),
            Text(
              "Collecting data...\nAverages will appear after 3 seconds",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: UIConstants.getSecondaryText(context),
                fontSize: UIConstants.bodyFontSize,
              ),
            ),
          ],
        ),
      ),
    );
  }
}