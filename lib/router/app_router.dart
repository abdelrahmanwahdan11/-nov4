import 'package:flutter/material.dart';

import '../app/app_controller.dart';
import '../core/i18n/app_localizations.dart';
import '../features/auth/sign_in_page.dart';
import '../features/home/home_shell.dart';
import '../features/onboarding/onboarding_story_page.dart';
import '../features/settings/settings_placeholder.dart';

class AppRouter {
  AppRouter({required AppController controller}) : _controller = controller;

  static const initialRoute = '/onboarding';

  final AppController _controller;

  List<NavigatorObserver> get observers => const [];

  Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/onboarding':
        return _material(settings, OnboardingStoryPage(controller: _controller));
      case '/auth/signin':
        return _material(settings, SignInPage(controller: _controller));
      case '/home':
        return _material(settings, HomeShell(controller: _controller));
      case '/settings':
        return _material(settings, SettingsPlaceholder(controller: _controller));
      default:
        return _material(
          settings,
          UnknownRouteScreen(name: settings.name ?? 'unknown'),
        );
    }
  }

  MaterialPageRoute<dynamic> _material(RouteSettings settings, Widget child) {
    return MaterialPageRoute<dynamic>(
      settings: settings,
      builder: (context) => child,
    );
  }
}

class UnknownRouteScreen extends StatelessWidget {
  const UnknownRouteScreen({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: Center(child: Text('Route not found: $name\n${l10n.translate('home_placeholder')}')),
    );
  }
}
