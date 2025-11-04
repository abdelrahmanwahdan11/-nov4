import 'package:flutter/material.dart';
import 'package:greenly/core/state/simple_provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/state/app_store.dart';
import '../../../core/storage/app_preferences.dart';
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
    final prefs = await AppPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _slowNetwork = prefs.getBool(AppConstants.sharedPrefsSlowNetworkKey) ?? false;
    });
  }

  Future<void> _toggleSlow(bool value) async {
    final prefs = await AppPreferences.getInstance();
    await prefs.setBool(AppConstants.sharedPrefsSlowNetworkKey, value);
    if (!mounted) return;
    setState(() => _slowNetwork = value);
  }

  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);
    final tutorialController = context.watch<TutorialController>();
    final loc = AppLocalizations.of(context);
    return AppScaffold(
      initialIndex: 2,
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
                  value: store.themeMode,
                  items: [
                    DropdownMenuItem(value: ThemeMode.system, child: Text(loc.translate('themeSystem'))),
                    DropdownMenuItem(value: ThemeMode.light, child: Text(loc.translate('themeLight'))),
                    DropdownMenuItem(value: ThemeMode.dark, child: Text(loc.translate('themeDark'))),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      store.setThemeMode(value);
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
                        onTap: () => store.setSeedColor(color),
                        child: CircleAvatar(
                          backgroundColor: color,
                          radius: 20,
                          child: store.seedColor == color
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
                  value: store.locale,
                  items: AppConstants.supportedLocales
                      .map((locale) => DropdownMenuItem(value: locale, child: Text(locale.languageCode.toUpperCase())))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      store.setLocale(value);
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
                  await store.resetDefaults();
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
