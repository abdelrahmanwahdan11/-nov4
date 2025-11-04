import 'package:flutter/material.dart';

import '../../../core/locale/localization_extension.dart';
import '../settings/settings_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('profile_title')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(context.tr('profile_guest_title')),
            subtitle: Text(context.tr('profile_guest_subtitle')),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(context.tr('profile_settings')),
            onTap: () => Navigator.of(context).pushNamed(SettingsPage.routeName),
          ),
        ],
      ),
    );
  }
}
