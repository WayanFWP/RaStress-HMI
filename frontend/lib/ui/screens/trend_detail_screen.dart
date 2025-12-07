import 'package:flutter/material.dart';
import '../../core/trend_service.dart';
import '../../core/websocket_services.dart';
import '../../core/trend_export_service.dart';
import '../widgets/shareable_trend_chart.dart';
import '../constants/ui_constants.dart';
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
  final GlobalKey _chartKey = GlobalKey();
  bool _isExporting = false;

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
    if (mounted) setState(() {});
  }

  void _onConnectionUpdate() {
    if (mounted) setState(() {});
  }

  Future<void> _shareToWhatsApp() async {
    final trendData = widget.trendService.trendData.value;

    if (trendData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No data available to share'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isExporting = true);

    try {
      // Show preview dialog with shareable chart
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _buildExportDialog(trendData),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sharing: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Widget _buildExportDialog(List<TrendDataPoint> trendData) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            // Preview with proper landscape scaling
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    UIConstants.smallBorderRadius,
                  ),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withOpacity(
                      UIConstants.mediumOpacity,
                    ),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    UIConstants.smallBorderRadius,
                  ),
                  child: SingleChildScrollView(
                    scrollDirection:
                        Axis.horizontal, // Allow horizontal scrolling
                    child: SingleChildScrollView(
                      scrollDirection:
                          Axis.vertical, // Allow vertical scrolling
                      child: RepaintBoundary(
                        key: _chartKey,
                        child: ShareableTrendChart(trendData: trendData),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: UIConstants.largeSpacing),
            // Info text
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: UIConstants.mediumPadding,
                vertical: UIConstants.smallPadding,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(
                  UIConstants.buttonBorderRadius,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.primary,
                    size: UIConstants.smallIconSize,
                  ),
                  const SizedBox(width: UIConstants.smallPadding),
                  Builder(
                    builder: (context) => Text(
                      'Landscape format • 1920x1080 • Scroll to preview',
                      style: TextStyle(
                        fontSize: UIConstants.smallFontSize,
                        color: UIConstants.getSecondaryText(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: UIConstants.mediumSpacing),
            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  label: const Text('Cancel'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    padding: const EdgeInsets.symmetric(
                      horizontal: UIConstants.largePadding,
                      vertical: UIConstants.mediumPadding,
                    ),
                  ),
                ),
                const SizedBox(width: UIConstants.mediumSpacing),
                ElevatedButton.icon(
                  onPressed: () async {
                    await TrendExportService.shareToWhatsApp(
                      _chartKey,
                      trendData,
                    );
                    Navigator.pop(context);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Opening share dialog...'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366), // WhatsApp green
                    padding: const EdgeInsets.symmetric(
                      horizontal: UIConstants.extraLargeSpacing + 8,
                      vertical: UIConstants.mediumPadding,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: UIConstants.mediumSpacing),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trendData = widget.trendService.trendData.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Vital Trends"),
        backgroundColor: Theme.of(context).colorScheme.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Share button
          IconButton(
            onPressed: _isExporting ? null : _shareToWhatsApp,
            icon: _isExporting
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.share),
            tooltip: 'Share to WhatsApp',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(UIConstants.screenPadding),
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

              // Breathing Rate Trend
              _buildTrendCard(
                title: "Breathing Rate",
                subtitle: "breaths/min",
                icon: Icons.air,
                color: const Color(0xFF2BE4DC),
                data: trendData,
                isHeartRate: false,
              ),
              const SizedBox(height: UIConstants.screenPadding),

              // Info text
              if (trendData.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(
                      UIConstants.extraLargeSpacing + 8,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.timeline,
                          size: UIConstants.extraLargeIconSize * 2,
                          color: Colors.white24,
                        ),
                        const SizedBox(height: UIConstants.mediumSpacing),
                        Text(
                          "Collecting data...\nTrends will appear after 3 seconds",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: UIConstants.getSecondaryText(context),
                            fontSize: UIConstants.bodyFontSize,
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

  Widget _buildTrendCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required List<TrendDataPoint> data,
    required bool isHeartRate,
  }) {
    double avgValue = 0;

    if (data.isNotEmpty) {
      final values = data
          .map((d) => isHeartRate ? d.heartRate : d.breathRate)
          .toList();
      avgValue = values.reduce((a, b) => a + b) / values.length;
    }

    return Container(
      padding: const EdgeInsets.all(UIConstants.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: UIConstants.mediumIconSize),
              const SizedBox(width: UIConstants.smallPadding),
              Text(
                title,
                style: const TextStyle(
                  fontSize: UIConstants.bodyFontSize + 1,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Text(
                data.isEmpty ? "--" : avgValue.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: UIConstants.titleFontSize + 2,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: UIConstants.tinySpacing),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: UIConstants.smallFontSize,
                  color: UIConstants.getSecondaryText(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: UIConstants.cardPadding),
          data.isEmpty
              ? SizedBox(
                  height: UIConstants.standardChartHeight - 40,
                  child: Center(
                    child: Text(
                      "Waiting for data...",
                      style: TextStyle(color: Colors.white38),
                    ),
                  ),
                )
              : _buildLineChartWithTimestamps(data, color, isHeartRate),
        ],
      ),
    );
  }

  Widget _buildLineChartWithTimestamps(
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

    final timeFormat = DateFormat('HH:mm:ss');

    return Column(
      children: [
        SizedBox(
          height: UIConstants.standardChartHeight - 40,
          child: CustomPaint(
            painter: _LineChartPainter(
              values: values,
              minValue: minValue,
              maxValue: maxValue,
              lineColor: color,
            ),
            size: const Size(
              double.infinity,
              UIConstants.standardChartHeight - 40,
            ),
          ),
        ),
        const SizedBox(height: UIConstants.mediumSpacing),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              timeFormat.format(data.first.timestamp),
              style: TextStyle(
                fontSize: UIConstants.captionFontSize,
                color: UIConstants.getSecondaryText(context),
              ),
            ),
            if (data.length > 2)
              Text(
                timeFormat.format(data[data.length ~/ 2].timestamp),
                style: TextStyle(
                  fontSize: UIConstants.captionFontSize,
                  color: UIConstants.getSecondaryText(context),
                ),
              ),
            Text(
              timeFormat.format(data.last.timestamp),
              style: TextStyle(
                fontSize: UIConstants.captionFontSize,
                color: UIConstants.getSecondaryText(context),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> values;
  final double minValue;
  final double maxValue;
  final Color lineColor;

  _LineChartPainter({
    required this.values,
    required this.minValue,
    required this.maxValue,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    const padding = 0.0;
    final width = size.width - padding * 2;
    final height = size.height - padding * 2;

    // Draw grid
    _drawGrid(canvas, size, padding);

    final range = maxValue - minValue;
    if (range == 0) return;

    // Draw filled area under line
    _drawFilledArea(canvas, size, width, height, padding, range);

    // Draw line
    _drawLine(canvas, size, width, height, padding, range);
  }

  void _drawGrid(Canvas canvas, Size size, double padding) {
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Horizontal grid lines (4 lines)
    for (int i = 1; i <= 4; i++) {
      final y = (size.height / 5) * i;
      canvas.drawLine(
        Offset(padding, y),
        Offset(size.width - padding, y),
        gridPaint,
      );
    }

    // Vertical grid lines (3 lines)
    for (int i = 1; i <= 3; i++) {
      final x = (size.width / 4) * i;
      canvas.drawLine(
        Offset(x, padding),
        Offset(x, size.height - padding),
        gridPaint,
      );
    }

    // Draw border
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    canvas.drawRect(
      Rect.fromLTWH(
        padding,
        padding,
        size.width - padding * 2,
        size.height - padding * 2,
      ),
      borderPaint,
    );
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
        colors: [lineColor.withOpacity(0.3), lineColor.withOpacity(0.05)],
      ).createShader(Rect.fromLTWH(padding, padding, width, height))
      ..style = PaintingStyle.fill;

    final fillPath = Path();
    fillPath.moveTo(padding, height + padding);

    for (int i = 0; i < values.length; i++) {
      final x = (i / (values.length - 1)) * width + padding;
      final normalizedValue = (values[i] - minValue) / range;
      final y = (1 - normalizedValue) * height + padding;
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
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final linePath = Path();

    for (int i = 0; i < values.length; i++) {
      final x = (i / (values.length - 1)) * width + padding;
      final normalizedValue = (values[i] - minValue) / range;
      final y = (1 - normalizedValue) * height + padding;

      if (i == 0) {
        linePath.moveTo(x, y);
      } else {
        linePath.lineTo(x, y);
      }
    }

    canvas.drawPath(linePath, linePaint);

    // Draw glow effect
    final glowPaint = Paint()
      ..color = lineColor.withOpacity(0.3)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    canvas.drawPath(linePath, glowPaint);

    // Draw data points
    final pointPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    for (int i = 0; i < values.length; i++) {
      final x = (i / (values.length - 1)) * width + padding;
      final normalizedValue = (values[i] - minValue) / range;
      final y = (1 - normalizedValue) * height + padding;

      canvas.drawCircle(Offset(x, y), 3, pointPaint);

      // Draw white center for points
      final centerPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), 1.5, centerPaint);
    }
  }

  @override
  bool shouldRepaint(_LineChartPainter oldDelegate) => true;
}
