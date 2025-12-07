import 'package:flutter/material.dart';
import '../constants/ui_constants.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const SectionTitle({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: UIConstants.mediumIconSize),
            const SizedBox(width: UIConstants.smallPadding),
            Text(
              title,
              style: const TextStyle(fontSize: UIConstants.titleFontSize),
            ),
          ],
        ),
        Text(
          subtitle,
          style: TextStyle(color: color, fontSize: UIConstants.bodyFontSize),
        ),
      ],
    );
  }
}
