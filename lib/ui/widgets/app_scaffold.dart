import 'package:flutter/material.dart';
import 'package:greenly/core/icons/iconly.dart';
import 'package:greenly/core/state/simple_provider.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/routing/app_router.dart';
import '../controllers/session_controller.dart';

class AppScaffold extends StatefulWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.initialIndex = 0,
    this.showNavigation = true,
  });

  final Widget body;
  final int initialIndex;
  final bool showNavigation;

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
  }

  @override
  void didUpdateWidget(covariant AppScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialIndex != oldWidget.initialIndex) {
      _index = widget.initialIndex;
    }
  }

  void _navigate(int index) {
    if (_index == index) return;
    final route = switch (index) {
      0 => AppRoutes.home,
      1 => AppRoutes.favorites,
      _ => AppRoutes.profile,
    };

    if (ModalRoute.of(context)?.settings.name == route) {
      return;
    }

    if (index == 2) {
      final session = context.read<SessionController>();
      if (session.isGuest) {
        _showGuestPrompt();
        return;
      }
    }

    setState(() => _index = index);
    Navigator.of(context).pushReplacementNamed(route);
  }

  void _showGuestPrompt() {
    final loc = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(loc.translate('guestNotice'), style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pushNamed(AppRoutes.login),
              child: Text(loc.translate('onboardingLogin')),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final navigationBar = widget.showNavigation
        ? NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: _navigate,
            destinations: [
              _navItem(IconlyLight.home, loc.translate('menuHome')),
              _navItem(Icons.favorite_border, loc.translate('menuFavorites')),
              _navItem(IconlyLight.profile, loc.translate('menuProfile')),
            ],
          )
        : null;

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: widget.body,
        bottomNavigationBar: navigationBar,
      ),
    );
  }

  NavigationDestination _navItem(IconData icon, String label) {
    return NavigationDestination(icon: Icon(icon), label: label);
  }
}
