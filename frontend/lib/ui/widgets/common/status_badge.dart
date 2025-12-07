import 'package:flutter/material.dart';
import '../../constants/ui_constants.dart';

class StatusBadge extends StatelessWidget {
  final bool isActive;
  final String activeText;
  final String inactiveText;
  final Color? activeColor;
  final Color? inactiveColor;

  const StatusBadge({
    super.key,
    required this.isActive,
    this.activeText = "Live",
    this.inactiveText = "No Data",
    this.activeColor = Colors.green,
    this.inactiveColor = Colors.red,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? activeColor! : inactiveColor!;
    final text = isActive ? activeText : inactiveText;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: UIConstants.statusBadgePaddingH,
        vertical: UIConstants.statusBadgePaddingV,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(UIConstants.mediumOpacity),
        borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
        border: Border.all(color: color, width: UIConstants.thinBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.circle,
            color: color,
            size: UIConstants.statusBadgeIconSize,
          ),
          const SizedBox(width: UIConstants.smallSpacing),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: UIConstants.smallFontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
