import 'package:flutter/material.dart';
import '../../constants/ui_constants.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final VoidCallback? onTap;
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: iconColor ?? Theme.of(context).colorScheme.primary,
                  size: UIConstants.mediumIconSize,
                ),
                const SizedBox(width: UIConstants.smallPadding),
              ],
              Text(
                title,
                style: const TextStyle(
                  fontSize: UIConstants.titleFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: TextStyle(
                color: iconColor ?? Theme.of(context).colorScheme.primary,
                fontSize: UIConstants.bodyFontSize,
              ),
            ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
