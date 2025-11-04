import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../../core/locale/localization_extension.dart';
import '../../controllers/app_controller.dart';
import '../cart/cart_page.dart';
import '../menu/menu_page.dart';
import '../profile/profile_page.dart';
import '../search/search_page.dart';
import '../settings/settings_page.dart';
import '../../controllers/tutorial_controller.dart';

class HomeShellPage extends StatefulWidget {
  const HomeShellPage({super.key, required this.controller});

  static const routeName = '/home';

  final AppController controller;

  @override
  State<HomeShellPage> createState() => _HomeShellPageState();
}

class _HomeShellPageState extends State<HomeShellPage> {
  final ValueNotifier<int> _index = ValueNotifier<int>(0);
  TutorialController? _tutorialController;
  bool _tutorialStarted = false;
  bool _tutorialSettingsPushed = false;

  @override
  void dispose() {
    _tutorialController?.currentTarget.removeListener(_handleTutorialTarget);
    _index.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = TutorialScope.maybeOf(context);
    if (!identical(controller, _tutorialController)) {
      _tutorialController?.currentTarget.removeListener(_handleTutorialTarget);
      _tutorialController = controller;
      controller?.currentTarget.addListener(_handleTutorialTarget);
      _handleTutorialTarget();
    }
    if (!_tutorialStarted && controller != null) {
      _tutorialStarted = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        controller.startIfNeeded();
      });
    }
  }

  void _handleTutorialTarget() {
    final controller = _tutorialController;
    if (controller == null) {
      return;
    }
    final target = controller.currentTarget.value;
    if (target == null) {
      _tutorialSettingsPushed = false;
      return;
    }
    switch (target) {
      case TutorialTarget.searchBar:
        _index.value = 1;
        _tutorialSettingsPushed = false;
        break;
      case TutorialTarget.addToCart:
        _index.value = 0;
        _tutorialSettingsPushed = false;
        break;
      case TutorialTarget.darkToggle:
      case TutorialTarget.colorPicker:
        if (_tutorialSettingsPushed) {
          return;
        }
        _tutorialSettingsPushed = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) {
            return;
          }
          if (ModalRoute.of(context)?.settings.name != SettingsPage.routeName) {
            Navigator.of(context).pushNamed(SettingsPage.routeName);
          }
        });
        break;
    }
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
