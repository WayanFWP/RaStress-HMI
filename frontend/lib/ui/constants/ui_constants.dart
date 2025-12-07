import 'package:flutter/material.dart';

/// UI-specific constants for consistent styling
class UIConstants {
  UIConstants._();

  // Padding & Spacing
  static const double screenPadding = 18.0;
  static const double cardPadding = 20.0;
  static const double smallPadding = 8.0;
  static const double mediumPadding = 16.0;
  static const double largePadding = 24.0;

  // Border Radius
  static const double cardBorderRadius = 18.0;
  static const double smallBorderRadius = 12.0;
  static const double buttonBorderRadius = 8.0;

  // Spacing
  static const double tinySpacing = 4.0;
  static const double smallSpacing = 6.0;
  static const double mediumSpacing = 12.0;
  static const double largeSpacing = 16.0;
  static const double extraLargeSpacing = 24.0;

  // Icon Sizes
  static const double smallIconSize = 16.0;
  static const double mediumIconSize = 20.0;
  static const double largeIconSize = 24.0;
  static const double extraLargeIconSize = 32.0;

  // Font Sizes
  static const double captionFontSize = 11.0;
  static const double smallFontSize = 12.0;
  static const double bodyFontSize = 14.0;
  static const double subtitleFontSize = 16.0;
  static const double titleFontSize = 18.0;
  static const double largeTitleFontSize = 28.0;
  static const double displayFontSize = 32.0;

  // Border Widths
  static const double thinBorder = 1.0;
  static const double mediumBorder = 1.5;
  static const double thickBorder = 2.0;

  // Chart Heights
  static const double miniChartHeight = 80.0;
  static const double standardChartHeight = 160.0;
  static const double largeChartHeight = 200.0;

  // Status Badge Sizes
  static const double statusBadgeIconSize = 8.0;
  static const double statusBadgePaddingH = 12.0;
  static const double statusBadgePaddingV = 6.0;

  // Opacity Values
  static const double lightOpacity = 0.15;
  static const double mediumOpacity = 0.3;
  static const double heavyOpacity = 0.5;

  // Helper method to get card background color based on theme
  static Color getCardBackground(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  // Helper method to get secondary text color based on theme
  static Color getSecondaryText(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? Colors.white70 : Colors.black54;
  }

  // Helper method to get divider color based on theme
  static Color getDividerColor(BuildContext context) {
    return Theme.of(context).dividerColor;
  }
}
