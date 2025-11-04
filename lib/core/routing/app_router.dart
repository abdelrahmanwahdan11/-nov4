import 'package:flutter/material.dart';

import '../../ui/features/auth/forgot_password_screen.dart';
import '../../ui/features/auth/login_screen.dart';
import '../../ui/features/auth/register_screen.dart';
import '../../ui/features/cart/cart_screen.dart';
import '../../ui/features/catalog/catalog_screen.dart';
import '../../ui/features/compare/compare_cars_screen.dart';
import '../../ui/features/details/item_details_screen.dart';
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
  switch (settings.name) {
    case AppRoutes.splash:
      return MaterialPageRoute(builder: (_) => const SplashScreen());
    case AppRoutes.onboarding:
      return MaterialPageRoute(builder: (_) => const OnboardingStoryScreen());
    case AppRoutes.home:
      return MaterialPageRoute(builder: (_) => const HomeScreen());
    case AppRoutes.catalog:
      return MaterialPageRoute(builder: (_) => const CatalogScreen());
    case AppRoutes.cart:
      return MaterialPageRoute(builder: (_) => const CartScreen());
    case AppRoutes.profile:
      return MaterialPageRoute(builder: (_) => const ProfileScreen());
    case AppRoutes.settings:
      return MaterialPageRoute(builder: (_) => const SettingsScreen());
    case AppRoutes.login:
      return MaterialPageRoute(builder: (_) => const LoginScreen());
    case AppRoutes.register:
      return MaterialPageRoute(builder: (_) => const RegisterScreen());
    case AppRoutes.forgotPassword:
      return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
    case AppRoutes.itemDetails:
      return MaterialPageRoute(builder: (_) => ItemDetailsScreen(itemId: settings.arguments as String));
    case AppRoutes.compareCars:
      return MaterialPageRoute(builder: (_) => const CompareCarsScreen());
    case AppRoutes.carViewer:
      return MaterialPageRoute(builder: (_) => Car3DViewerScreen(carId: settings.arguments as String?));
    case AppRoutes.tutorial:
      return MaterialPageRoute(builder: (_) => const TutorialScreen());
    default:
      return null;
  }
}
