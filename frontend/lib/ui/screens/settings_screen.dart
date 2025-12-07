import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/settings_service.dart';
import '../themes/app_theme.dart';

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
            padding: const EdgeInsets.all(18),
            children: [
              // Theme Selection
              _buildSection(
                context,
                title: "Theme",
                icon: Icons.palette,
                child: _buildThemeSelector(context, settings),
              ),
              const SizedBox(height: 24),

              // Font Size
              _buildSection(
                context,
                title: "Font Size",
                icon: Icons.format_size,
                child: _buildFontSizeSelector(context, settings),
              ),
              const SizedBox(height: 24),

              // Accessibility
              _buildSection(
                context,
                title: "Accessibility",
                icon: Icons.accessibility_new,
                child: Column(
                  children: [
                    _buildDyslexicToggle(context, settings),
                    const SizedBox(height: 16),
                    _buildColorBlindSelector(context, settings),
                  ],
                ),
              ),
              const SizedBox(height: 24),

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
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
        const SizedBox(height: 12),
        _buildThemeOption(
          context,
          settings,
          AppThemeMode.dark,
          "Dark Monochrome",
          "Pure black and white theme",
          Colors.white,
          Icons.contrast,
        ),
        const SizedBox(height: 12),
        _buildThemeOption(
          context,
          settings,
          AppThemeMode.light,
          "Light",
          "Clean and bright theme",
          const Color(0xFF00BFA5),
          Icons.light_mode,
        ),
        const SizedBox(height: 12),
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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.white24,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: accentColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 12, color: Colors.white60),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
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
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: InkWell(
          onTap: () => settings.setFontSize(size),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.white24,
                width: isSelected ? 2 : 1,
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
                const SizedBox(height: 8),
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.white60),
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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                "Uses OpenDyslexic font for better readability",
                style: TextStyle(
                  fontSize: 12,
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
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<ColorBlindMode>(
          value: settings.colorBlindMode,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white24),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
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
                Icons.preview,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                "Preview",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "Heart Rate: 72 BPM",
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "This is how text will appear with your current settings.",
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
