import 'package:flutter/material.dart';
import '../constants/ui_constants.dart';

class StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final String unit;

  const StatCard({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.unit,
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
          Row(
            children: [
              Icon(icon, color: color, size: UIConstants.mediumIconSize),
              const SizedBox(width: UIConstants.smallSpacing),
              Text(
                label,
                style: TextStyle(
                  fontSize: UIConstants.bodyFontSize,
                  color: UIConstants.getSecondaryText(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: UIConstants.displayFontSize,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: UIConstants.tinySpacing),
              Text(
                unit,
                style: const TextStyle(fontSize: UIConstants.subtitleFontSize),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
