import 'package:flutter/material.dart';

import '../../ui/features/auth/forgot_password_screen.dart';
import '../../ui/features/auth/login_screen.dart';
import '../../ui/features/auth/register_screen.dart';
import '../../ui/features/cart/cart_screen.dart';
import '../../ui/features/catalog/catalog_screen.dart';
import '../../ui/features/compare/compare_cars_screen.dart';
import '../../ui/features/details/item_details_screen.dart';
import '../../ui/features/favorites/favorites_screen.dart';
import '../../ui/features/home/home_screen.dart';
import '../../ui/features/onboarding/onboarding_story_screen.dart';
import '../../ui/features/profile/profile_screen.dart';
import '../../ui/features/settings/settings_screen.dart';
import '../../ui/features/splash/splash_screen.dart';
import '../../ui/features/tutorial/tutorial_screen.dart';
import '../../ui/features/viewer/car_3d_viewer_screen.dart';

class AppRoutes {
  const AppRoutes._();

  static const splash = '/';
  static const onboarding = '/onboarding';
  static const home = '/home';
  static const favorites = '/favorites';
  static const catalog = '/catalog';
  static const cart = '/cart';
  static const profile = '/profile';
  static const settings = '/settings';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const itemDetails = '/item-details';
  static const compareCars = '/compare-cars';
  static const carViewer = '/car-viewer';
  static const tutorial = '/tutorial';
}

Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  final builder = _routeBuilders[settings.name];
  if (builder == null) {
    return null;
  }

  final transition = _routeTransitions[settings.name] ?? _TransitionStyle.sharedAxis;

  return PageRouteBuilder<dynamic>(
    settings: settings,
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 240),
    pageBuilder: (context, animation, secondaryAnimation) => builder(context, settings),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic);
      switch (transition) {
        case _TransitionStyle.fade:
          return FadeTransition(opacity: curvedAnimation, child: child);
        case _TransitionStyle.slideUp:
          final offset = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(curvedAnimation);
          return FadeTransition(
            opacity: curvedAnimation,
            child: SlideTransition(position: offset, child: child),
          );
        case _TransitionStyle.sharedAxis:
        default:
          final scale = Tween<double>(begin: 0.92, end: 1).animate(curvedAnimation);
          return FadeTransition(
            opacity: curvedAnimation,
            child: ScaleTransition(scale: scale, child: child),
          );
      }
    },
  );
}

enum _TransitionStyle { fade, sharedAxis, slideUp }

typedef _RouteBuilder = Widget Function(BuildContext, RouteSettings);

final Map<String, _RouteBuilder> _routeBuilders = {
  AppRoutes.splash: (_, __) => const SplashScreen(),
  AppRoutes.onboarding: (_, __) => const OnboardingStoryScreen(),
  AppRoutes.home: (_, __) => const HomeScreen(),
  AppRoutes.favorites: (_, __) => const FavoritesScreen(),
  AppRoutes.catalog: (_, __) => const CatalogScreen(),
  AppRoutes.cart: (_, __) => const CartScreen(),
  AppRoutes.profile: (_, __) => const ProfileScreen(),
  AppRoutes.settings: (_, __) => const SettingsScreen(),
  AppRoutes.login: (_, __) => const LoginScreen(),
  AppRoutes.register: (_, __) => const RegisterScreen(),
  AppRoutes.forgotPassword: (_, __) => const ForgotPasswordScreen(),
  AppRoutes.itemDetails: (_, settings) =>
      ItemDetailsScreen(itemId: settings.arguments as String),
  AppRoutes.compareCars: (_, __) => const CompareCarsScreen(),
  AppRoutes.carViewer: (_, settings) =>
      Car3DViewerScreen(carId: settings.arguments as String?),
  AppRoutes.tutorial: (_, __) => const TutorialScreen(),
};

final Map<String, _TransitionStyle> _routeTransitions = {
  AppRoutes.splash: _TransitionStyle.fade,
  AppRoutes.onboarding: _TransitionStyle.sharedAxis,
  AppRoutes.home: _TransitionStyle.sharedAxis,
  AppRoutes.favorites: _TransitionStyle.sharedAxis,
  AppRoutes.profile: _TransitionStyle.sharedAxis,
  AppRoutes.settings: _TransitionStyle.slideUp,
  AppRoutes.login: _TransitionStyle.slideUp,
  AppRoutes.register: _TransitionStyle.slideUp,
  AppRoutes.forgotPassword: _TransitionStyle.slideUp,
  AppRoutes.itemDetails: _TransitionStyle.sharedAxis,
  AppRoutes.compareCars: _TransitionStyle.sharedAxis,
  AppRoutes.carViewer: _TransitionStyle.fade,
  AppRoutes.tutorial: _TransitionStyle.fade,
};
