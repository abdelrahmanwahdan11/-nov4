import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../core/theme/theme_controller.dart';
import '../../controllers/tutorial_controller.dart';
import '../../widgets/app_scaffold.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _slowNetwork = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _slowNetwork = prefs.getBool(AppConstants.sharedPrefsSlowNetworkKey) ?? false;
    });
  }

  Future<void> _toggleSlow(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.sharedPrefsSlowNetworkKey, value);
    if (!mounted) return;
    setState(() => _slowNetwork = value);
  }

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    final localeController = context.watch<LocaleController>();
    final tutorialController = context.watch<TutorialController>();
    final loc = AppLocalizations.of(context);
    return AppScaffold(
      currentIndex: 3,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ListView(
            children: [
              Text(loc.translate('settingsTitle'), style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 16),
              ListTile(
                title: Text(loc.translate('settingsTheme')),
                trailing: DropdownButton<ThemeMode>(
                  value: themeController.themeMode,
                  items: [
                    DropdownMenuItem(value: ThemeMode.system, child: Text(loc.translate('themeSystem'))),
                    DropdownMenuItem(value: ThemeMode.light, child: Text(loc.translate('themeLight'))),
                    DropdownMenuItem(value: ThemeMode.dark, child: Text(loc.translate('themeDark'))),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      themeController.setThemeMode(value);
                    }
                  },
                ),
              ),
              const Divider(),
              Text(loc.translate('settingsPrimaryColor'), style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: AppConstants.primaryColorPalette
                    .map(
                      (color) => GestureDetector(
                        onTap: () => themeController.setSeedColor(color),
                        child: CircleAvatar(
                          backgroundColor: color,
                          radius: 20,
                          child: themeController.seedColor == color
                              ? const Icon(Icons.check, color: Colors.white)
                              : null,
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(loc.translate('settingsLanguage')),
                trailing: DropdownButton<Locale>(
                  value: localeController.locale,
                  items: AppConstants.supportedLocales
                      .map((locale) => DropdownMenuItem(value: locale, child: Text(locale.languageCode.toUpperCase())))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      localeController.setLocale(value);
                    }
                  },
                ),
              ),
              const Divider(),
              SwitchListTile(
                title: Text(loc.translate('slowNetworkSimulation')),
                value: _slowNetwork,
                onChanged: _toggleSlow,
              ),
              ListTile(
                title: Text(loc.translate('settingsTutorial')),
                trailing: OutlinedButton(
                  onPressed: tutorialController.reset,
                  child: Text(loc.translate('reset')),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  await themeController.resetDefaults();
                  await localeController.setLocale(AppConstants.defaultLocale);
                  await _toggleSlow(false);
                },
                child: Text(loc.translate('restoreDefaults')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
