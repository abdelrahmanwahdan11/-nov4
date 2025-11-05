import 'package:flutter/material.dart';

import '../../app/app_controller.dart';
import '../../core/i18n/app_localizations.dart';
import '../../core/theme/tokens.dart';

class SettingsPlaceholder extends StatelessWidget {
  const SettingsPlaceholder({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.translate('settings'))),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.translate('theme'), style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.md),
            SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.system, label: Text('System')),
                ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
              ],
              selected: {controller.themeMode},
              onSelectionChanged: (value) => controller.setThemeMode(value.first),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(l10n.translate('language'), style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.md),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'en', label: Text('English')),
                ButtonSegment(value: 'ar', label: Text('العربية')),
              ],
              selected: {controller.locale.languageCode},
              onSelectionChanged: (value) => controller.setLocale(Locale(value.first)),
            ),
          ],
        ),
      ),
    );
  }
}
