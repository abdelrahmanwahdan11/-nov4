import 'package:flutter/material.dart';
import 'package:greenly/core/icons/iconly.dart';
import 'package:greenly/core/state/simple_provider.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/routing/app_router.dart';
import '../controllers/session_controller.dart';

class AppScaffold extends StatefulWidget {
  const AppScaffold({super.key, required this.body, this.currentIndex = 0});

  final Widget body;
  final int currentIndex;

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.currentIndex;
  }

  void _navigate(int index) {
    if (_index == index) return;
    setState(() => _index = index);
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
        break;
      case 1:
        Navigator.of(context).pushReplacementNamed(AppRoutes.catalog);
        break;
      case 2:
        Navigator.of(context).pushReplacementNamed(AppRoutes.cart);
        break;
      case 3:
        final session = context.read<SessionController>();
        if (session.isGuest) {
          showModalBottomSheet(
            context: context,
            builder: (_) => Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context).translate('guestNotice'), style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pushNamed(AppRoutes.login),
                    child: Text(AppLocalizations.of(context).translate('onboardingLogin')),
                  ),
                ],
              ),
            ),
          );
        } else {
          Navigator.of(context).pushReplacementNamed(AppRoutes.profile);
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final items = [
      _navItem(IconlyLight.home, loc.translate('menuHome')),
      _navItem(IconlyLight.category, loc.translate('menuCatalog')),
      _navItem(IconlyLight.bag, loc.translate('menuCart')),
      _navItem(IconlyLight.profile, loc.translate('menuProfile')),
    ];
    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: widget.body,
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: _navigate,
          destinations: items,
        ),
      ),
    );
  }

  NavigationDestination _navItem(IconData icon, String label) {
    return NavigationDestination(icon: Icon(icon), label: label);
  }
}
