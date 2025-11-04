import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../../core/locale/localization_extension.dart';
import '../../controllers/app_controller.dart';
import '../cart/cart_page.dart';
import '../menu/menu_page.dart';
import '../profile/profile_page.dart';
import '../search/search_page.dart';

class HomeShellPage extends StatefulWidget {
  const HomeShellPage({super.key, required this.controller});

  static const routeName = '/home';

  final AppController controller;

  @override
  State<HomeShellPage> createState() => _HomeShellPageState();
}

class _HomeShellPageState extends State<HomeShellPage> {
  final ValueNotifier<int> _index = ValueNotifier<int>(0);

  @override
  void dispose() {
    _index.dispose();
    super.dispose();
  }

  List<Widget> _buildPages() => const [
        MenuPage(),
        SearchPage(),
        CartPage(),
        ProfilePage(),
      ];

  NavigationDestination _buildDestination(IconData icon, String label) {
    return NavigationDestination(
      icon: Icon(icon),
      selectedIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
      label: label,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final pages = _buildPages();
        final labels = [
          context.tr('nav_menu'),
          context.tr('nav_search'),
          context.tr('nav_cart'),
          context.tr('nav_profile'),
        ];

        return Scaffold(
          body: ValueListenableBuilder<int>(
            valueListenable: _index,
            builder: (context, value, child) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: pages[value],
              );
            },
          ),
          bottomNavigationBar: ValueListenableBuilder<int>(
            valueListenable: _index,
            builder: (context, value, child) {
              return NavigationBar(
                selectedIndex: value,
                onDestinationSelected: (index) => _index.value = index,
                destinations: [
                  _buildDestination(IconlyBold.home, labels[0]),
                  _buildDestination(IconlyBold.search, labels[1]),
                  _buildDestination(IconlyBold.buy, labels[2]),
                  _buildDestination(IconlyBold.profile, labels[3]),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
