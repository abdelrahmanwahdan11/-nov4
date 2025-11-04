import 'package:flutter/material.dart';

import '../../../core/locale/localization_extension.dart';
import '../cart/cart_page.dart';
import '../catalog/catalog_page.dart';
import '../settings/settings_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.tr('profile_title')),
          actions: [
            IconButton(
              tooltip: context.tr('profile_open_settings'),
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => Navigator.of(context).pushNamed(SettingsPage.routeName),
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(
                icon: const Icon(Icons.favorite_border),
                text: context.tr('profile_section_favorites'),
              ),
              Tab(
                icon: const Icon(Icons.location_on_outlined),
                text: context.tr('profile_section_addresses'),
              ),
              Tab(
                icon: const Icon(Icons.receipt_long_outlined),
                text: context.tr('profile_section_orders'),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ProfilePlaceholder(
              icon: Icons.favorite_outline,
              title: context.tr('profile_guest_title'),
              description: context.tr('profile_favorites_placeholder'),
              primaryActionLabel: context.tr('profile_action_browse_menu'),
              onPrimaryTap: () => Navigator.of(context).pushNamed(CatalogPage.routeName),
            ),
            _ProfilePlaceholder(
              icon: Icons.location_on_outlined,
              title: context.tr('profile_addresses_title'),
              description: context.tr('profile_addresses_placeholder'),
              primaryActionLabel: context.tr('profile_action_add_address'),
              onPrimaryTap: () => Navigator.of(context).pushNamed(SettingsPage.routeName),
              secondaryHint: context.tr('profile_addresses_hint'),
            ),
            _ProfilePlaceholder(
              icon: Icons.receipt_long_outlined,
              title: context.tr('profile_orders_title'),
              description: context.tr('profile_orders_placeholder'),
              primaryActionLabel: context.tr('profile_action_review_orders'),
              onPrimaryTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const CartPage(),
                ),
              ),
              secondaryHint: context.tr('profile_orders_hint'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfilePlaceholder extends StatelessWidget {
  const _ProfilePlaceholder({
    required this.icon,
    required this.title,
    required this.description,
    required this.primaryActionLabel,
    required this.onPrimaryTap,
    this.secondaryHint,
  });

  final IconData icon;
  final String title;
  final String description;
  final String primaryActionLabel;
  final VoidCallback onPrimaryTap;
  final String? secondaryHint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final shouldUseCenteredLayout = constraints.maxWidth > 480;
        final content = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(32),
              ),
              child: Icon(
                icon,
                size: 48,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (secondaryHint != null) ...[
              const SizedBox(height: 8),
              Text(
                secondaryHint!,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onPrimaryTap,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: Text(primaryActionLabel),
            ),
          ],
        );

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            vertical: shouldUseCenteredLayout ? 64 : 32,
            horizontal: shouldUseCenteredLayout ? 48 : 24,
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
                elevation: shouldUseCenteredLayout ? 3 : 0,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: content,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
