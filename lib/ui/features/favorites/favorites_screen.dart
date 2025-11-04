import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../widgets/app_scaffold.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return AppScaffold(
      initialIndex: 1,
      body: SafeArea(
        child: Center(
          child: Text(
            loc.translate('menuFavorites'),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
      ),
    );
  }
}
