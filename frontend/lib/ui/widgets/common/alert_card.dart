import 'package:flutter/material.dart';
import '../../constants/ui_constants.dart';

class AlertCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  final String message;
  final Widget? badge;

  const AlertCard({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    this.subtitle,
    required this.message,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: UIConstants.largeSpacing),
      padding: const EdgeInsets.all(UIConstants.largeSpacing),
      decoration: BoxDecoration(
        color: color.withOpacity(UIConstants.lightOpacity),
        borderRadius: BorderRadius.circular(UIConstants.cardBorderRadius),
        border: Border.all(color: color, width: UIConstants.thickBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(UIConstants.smallPadding),
            decoration: BoxDecoration(
              color: color.withOpacity(UIConstants.mediumOpacity),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: UIConstants.largeIconSize),
          ),
          const SizedBox(width: UIConstants.largeSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: UIConstants.subtitleFontSize,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    if (badge != null) ...[
                      const SizedBox(width: UIConstants.smallPadding),
                      badge!,
                    ],
                  ],
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: UIConstants.tinySpacing),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: UIConstants.captionFontSize,
                      color: UIConstants.getSecondaryText(context),
                    ),
                  ),
                ],
                const SizedBox(height: UIConstants.smallSpacing),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: UIConstants.bodyFontSize,
                    color: UIConstants.getSecondaryText(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
