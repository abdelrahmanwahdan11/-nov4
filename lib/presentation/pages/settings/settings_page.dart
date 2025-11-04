import 'package:flutter/material.dart';

import '../../../core/locale/localization_extension.dart';
import '../../../core/theme/theme_tokens.dart';
import '../../controllers/app_controller.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.controller});

  static const routeName = '/settings';

  final AppController controller;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const _presetColors = <Color>[
    ThemeTokens.seedPrimary,
    Color(0xFF0EA5E9),
    Color(0xFFF97316),
    Color(0xFF6366F1),
    Color(0xFFE11D48),
    Color(0xFF14B8A6),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('settings_title')),
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                context.tr('settings_theme_section'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...ThemeMode.values.map(
                (mode) => RadioListTile<ThemeMode>(
                  value: mode,
                  groupValue: controller.themeMode,
                  onChanged: (value) {
                    if (value != null) {
                      controller.setThemeMode(value);
                    }
                  },
                  title: Text(_labelForThemeMode(context, mode)),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                context.tr('settings_language_section'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<Locale>(
                value: controller.locale ?? const Locale('en'),
                items: const [
                  DropdownMenuItem(value: Locale('en'), child: Text('English')),
                  DropdownMenuItem(value: Locale('ar'), child: Text('العربية')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    controller.setLocale(value);
                  }
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                context.tr('settings_color_section'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _presetColors
                    .map(
                      (color) => _ColorChoice(
                        color: color,
                        selected: color.value == controller.primarySeed.value,
                        onTap: () => controller.setPrimarySeed(color),
                      ),
                    )
                    .toList(),
              ),
            ],
          );
        },
      ),
    );
  }

  String _labelForThemeMode(BuildContext context, ThemeMode mode) {
    return switch (mode) {
      ThemeMode.system => context.tr('settings_theme_system'),
      ThemeMode.light => context.tr('settings_theme_light'),
      ThemeMode.dark => context.tr('settings_theme_dark'),
    };
  }
}

class _ColorChoice extends StatelessWidget {
  const _ColorChoice({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? Theme.of(context).colorScheme.onPrimary : Colors.transparent,
            width: 3,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
      ),
    );
  }
}
