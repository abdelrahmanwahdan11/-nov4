import 'package:flutter/material.dart';

import '../../app/app_controller.dart';
import '../../core/i18n/app_localizations.dart';
import '../../core/widgets/bottom_dock_nav.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/theme/tokens.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.controller});

  final AppController controller;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final pages = [
      _PlaceholderSection(title: l10n.translate('home_placeholder')),
      _PlaceholderSection(title: l10n.translate('catalog_placeholder')),
      _PlaceholderSection(title: l10n.translate('compare_placeholder')),
      _SettingsQuickAccess(controller: widget.controller, title: l10n.translate('settings_placeholder')),
    ];

    return Scaffold(
      extendBody: true,
      body: SafeArea(child: pages[_index]),
      bottomNavigationBar: BottomDockNav(
        currentIndex: _index,
        onTap: (value) => setState(() => _index = value),
      ),
    );
  }
}

class _PlaceholderSection extends StatelessWidget {
  const _PlaceholderSection({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GlassContainer(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Text(title, style: Theme.of(context).textTheme.headlineSmall),
      ),
    );
  }
}

class _SettingsQuickAccess extends StatelessWidget {
  const _SettingsQuickAccess({
    required this.controller,
    required this.title,
  });

  final AppController controller;
  final String title;

  @override
  Widget build(BuildContext context) {
    final themeMode = controller.themeMode;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.lg),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(value: ThemeMode.system, label: Text('System')),
              ButtonSegment(value: ThemeMode.light, label: Text('Light')),
              ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
            ],
            selected: {themeMode},
            onSelectionChanged: (value) => controller.setThemeMode(value.first),
          ),
        ],
      ),
    );
  }
}
