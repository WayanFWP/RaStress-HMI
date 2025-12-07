import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/settings_service.dart';
import '../themes/app_theme.dart';
import '../constants/ui_constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: Consumer<SettingsService>(
        builder: (context, settings, child) {
          return ListView(
            padding: const EdgeInsets.all(UIConstants.screenPadding),
            children: [
              // Theme Selection
              _buildSection(
                context,
                title: "Theme",
                icon: Icons.palette,
                child: _buildThemeSelector(context, settings),
              ),
              const SizedBox(height: UIConstants.extraLargeSpacing),

              // Font Size
              _buildSection(
                context,
                title: "Font Size",
                icon: Icons.format_size,
                child: _buildFontSizeSelector(context, settings),
              ),
              const SizedBox(height: UIConstants.extraLargeSpacing),

              // Accessibility
              _buildSection(
                context,
                title: "Accessibility",
                icon: Icons.accessibility_new,
                child: Column(
                  children: [
                    _buildDyslexicToggle(context, settings),
                    const SizedBox(height: UIConstants.mediumPadding),
                    _buildColorBlindSelector(context, settings),
                  ],
                ),
              ),
              const SizedBox(height: UIConstants.extraLargeSpacing),

              // Preview Card
              _buildPreviewCard(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: UIConstants.mediumIconSize,
              ),
              const SizedBox(width: UIConstants.smallPadding),
              Text(
                title,
                style: const TextStyle(
                  fontSize: UIConstants.titleFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: UIConstants.mediumPadding),
          child,
        ],
      ),
    );
  }

  Widget _buildThemeSelector(BuildContext context, SettingsService settings) {
    return Column(
      children: [
        _buildThemeOption(
          context,
          settings,
          AppThemeMode.neon,
          "Neon",
          "Vibrant cyan and purple theme",
          const Color(0xFF2BE4DC),
          Icons.flash_on,
        ),
        const SizedBox(height: UIConstants.mediumSpacing),
        _buildThemeOption(
          context,
          settings,
          AppThemeMode.dark,
          "Dark Monochrome",
          "Pure black and white theme",
          Colors.white,
          Icons.contrast,
        ),

        const SizedBox(height: UIConstants.mediumSpacing),
        _buildThemeOption(
          context,
          settings,
          AppThemeMode.nightOwl,
          "Night Owl",
          "Blue and purple night theme",
          const Color(0xFF82AAFF),
          Icons.nightlight_round,
        ),
      ],
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    SettingsService settings,
    AppThemeMode mode,
    String title,
    String description,
    Color accentColor,
    IconData icon,
  ) {
    final isSelected = settings.themeMode == mode;

    return InkWell(
      onTap: () => settings.setThemeMode(mode),
      borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
      child: Container(
        padding: const EdgeInsets.all(UIConstants.mediumPadding),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(
                  context,
                ).colorScheme.primary.withOpacity(UIConstants.lightOpacity)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.white24,
            width: isSelected
                ? UIConstants.thickBorder
                : UIConstants.thinBorder,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(UIConstants.mediumSpacing),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(UIConstants.mediumOpacity - 0.1),
                borderRadius: BorderRadius.circular(
                  UIConstants.buttonBorderRadius,
                ),
              ),
              child: Icon(
                icon,
                color: accentColor,
                size: UIConstants.largeIconSize,
              ),
            ),
            const SizedBox(width: UIConstants.mediumPadding),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: UIConstants.subtitleFontSize,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                  ),
                  const SizedBox(height: UIConstants.tinySpacing),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: UIConstants.smallFontSize,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
                size: UIConstants.largeIconSize,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFontSizeSelector(
    BuildContext context,
    SettingsService settings,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildFontSizeButton(context, settings, FontSize.small, "Small", "A"),
        _buildFontSizeButton(context, settings, FontSize.medium, "Medium", "A"),
        _buildFontSizeButton(context, settings, FontSize.large, "Large", "A"),
      ],
    );
  }

  Widget _buildFontSizeButton(
    BuildContext context,
    SettingsService settings,
    FontSize size,
    String label,
    String sample,
  ) {
    final isSelected = settings.fontSize == size;
    final fontSize = size == FontSize.small
        ? 16.0
        : (size == FontSize.medium ? 20.0 : 24.0);

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: UIConstants.tinySpacing,
        ),
        child: InkWell(
          onTap: () => settings.setFontSize(size),
          borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: UIConstants.cardPadding,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(UIConstants.lightOpacity)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(
                UIConstants.smallBorderRadius,
              ),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.white24,
                width: isSelected
                    ? UIConstants.thickBorder
                    : UIConstants.thinBorder,
              ),
            ),
            child: Column(
              children: [
                Text(
                  sample,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                ),
                const SizedBox(height: UIConstants.smallPadding),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: UIConstants.smallFontSize,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDyslexicToggle(BuildContext context, SettingsService settings) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Dyslexic-Friendly Font",
                style: TextStyle(
                  fontSize: UIConstants.subtitleFontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: UIConstants.tinySpacing),
              Text(
                "Uses OpenDyslexic font for better readability",
                style: TextStyle(
                  fontSize: UIConstants.smallFontSize,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: settings.isDyslexic,
          onChanged: (value) => settings.setDyslexicMode(value),
          activeColor: Theme.of(context).colorScheme.primary,
        ),
      ],
    );
  }

  Widget _buildColorBlindSelector(
    BuildContext context,
    SettingsService settings,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Color Blind Mode",
          style: TextStyle(
            fontSize: UIConstants.subtitleFontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: UIConstants.mediumSpacing),
        DropdownButtonFormField<ColorBlindMode>(
          value: settings.colorBlindMode,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                UIConstants.smallBorderRadius,
              ),
              borderSide: BorderSide(color: Colors.white24),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: UIConstants.mediumPadding,
              vertical: UIConstants.mediumSpacing,
            ),
          ),
          dropdownColor: Theme.of(context).colorScheme.surface,
          items: [
            DropdownMenuItem(value: ColorBlindMode.none, child: Text("None")),
            DropdownMenuItem(
              value: ColorBlindMode.protanopia,
              child: Text("Protanopia (Red-Blind)"),
            ),
            DropdownMenuItem(
              value: ColorBlindMode.deuteranopia,
              child: Text("Deuteranopia (Green-Blind)"),
            ),
            DropdownMenuItem(
              value: ColorBlindMode.tritanopia,
              child: Text("Tritanopia (Blue-Blind)"),
            ),
          ],
          onChanged: (value) {
            if (value != null) settings.setColorBlindMode(value);
          },
        ),
      ],
    );
  }

  Widget _buildPreviewCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(UIConstants.cardPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(UIConstants.cardBorderRadius),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.primary.withOpacity(UIConstants.mediumOpacity),
          width: UIConstants.thinBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.preview,
                color: Theme.of(context).colorScheme.primary,
                size: UIConstants.mediumIconSize,
              ),
              const SizedBox(width: UIConstants.smallPadding),
              Text(
                "Preview",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: UIConstants.mediumPadding),
          Text(
            "Heart Rate: 72 BPM",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: UIConstants.smallPadding),
          Text(
            "This is how text will appear with your current settings.",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
