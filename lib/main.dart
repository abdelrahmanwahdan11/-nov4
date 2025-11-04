import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/locale/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'presentation/controllers/app_controller.dart';
import 'presentation/controllers/auth_controller.dart';
import 'presentation/controllers/cart_controller.dart';
import 'presentation/controllers/catalog_controller.dart';
import 'presentation/controllers/compare_controller.dart';
import 'data/local/cart_local_data_source.dart';
import 'data/local/food_local_data_source.dart';
import 'data/local/car_local_data_source.dart';
import 'domain/models/food_item.dart';
import 'presentation/pages/auth/forgot_password_page.dart';
import 'presentation/pages/auth/login_page.dart';
import 'presentation/pages/auth/register_page.dart';
import 'presentation/pages/catalog/catalog_page.dart';
import 'presentation/pages/home/home_shell_page.dart';
import 'presentation/pages/item/item_details_page.dart';
import 'presentation/pages/onboarding/onboarding_page.dart';
import 'presentation/pages/settings/settings_page.dart';
import 'presentation/pages/splash/splash_page.dart';
import 'presentation/pages/compare/compare_cars_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appController = AppController();
  final authController = AuthController(appController: appController);
  final cartController = CartController(
    catalogDataSource: FoodLocalDataSource(),
    localDataSource: CartLocalDataSource(),
  );
  await cartController.initialize();
  final compareController = CompareController(
    dataSource: CarLocalDataSource(),
  );
  await compareController.load();
  runApp(
    GreenBiteApp(
      appController: appController,
      authController: authController,
      cartController: cartController,
      compareController: compareController,
    ),
  );
}

class GreenBiteApp extends StatelessWidget {
  const GreenBiteApp({
    super.key,
    required this.appController,
    required this.authController,
    required this.cartController,
    required this.compareController,
  });

  final AppController appController;
  final AuthController authController;
  final CartController cartController;
  final CompareController compareController;

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case SplashPage.routeName:
        return MaterialPageRoute<void>(
          builder: (_) => SplashPage(
            controller: appController,
            authController: authController,
          ),
          settings: settings,
        );
      case OnboardingPage.routeName:
        return MaterialPageRoute<void>(
          builder: (_) => OnboardingPage(controller: appController),
          settings: settings,
        );
      case LoginPage.routeName:
        return MaterialPageRoute<void>(
          builder: (_) => LoginPage(
            appController: appController,
            authController: authController,
          ),
          settings: settings,
        );
      case RegisterPage.routeName:
        return MaterialPageRoute<void>(
          builder: (_) => RegisterPage(
            appController: appController,
            authController: authController,
          ),
          settings: settings,
        );
      case ForgotPasswordPage.routeName:
        return MaterialPageRoute<void>(
          builder: (_) => ForgotPasswordPage(authController: authController),
          settings: settings,
        );
      case HomeShellPage.routeName:
        return MaterialPageRoute<void>(
          builder: (_) => HomeShellPage(controller: appController),
          settings: settings,
        );
      case CatalogPage.routeName:
        return MaterialPageRoute<void>(
          builder: (_) => CatalogPage(
            controller: CatalogController(dataSource: FoodLocalDataSource()),
          ),
          settings: settings,
        );
      case ItemDetailsPage.routeName:
        final item = settings.arguments;
        if (item is! FoodItem) {
          return null;
        }
        return MaterialPageRoute<void>(
          builder: (_) => ItemDetailsPage(item: item),
          settings: settings,
        );
      case SettingsPage.routeName:
        return MaterialPageRoute<void>(
          builder: (_) => SettingsPage(controller: appController),
          settings: settings,
        );
      case CompareCarsPage.routeName:
        return MaterialPageRoute<void>(
          builder: (_) => const CompareCarsPage(),
          settings: settings,
        );
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appController,
      builder: (context, _) {
        final locale = appController.locale;

        return AppScope(
          controller: appController,
          child: AuthScope(
            controller: authController,
            child: CartScope(
              controller: cartController,
              child: CompareScope(
                controller: compareController,
                child: MaterialApp(
                  title: 'GreenBite',
                  debugShowCheckedModeBanner: false,
                  themeMode: appController.themeMode,
                  theme: AppTheme.buildTheme(
                    Brightness.light,
                    primarySeed: appController.primarySeed,
                  ),
                  darkTheme: AppTheme.buildTheme(
                    Brightness.dark,
                    primarySeed: appController.primarySeed,
                  ),
                  locale: locale,
                  supportedLocales: const [Locale('en'), Locale('ar')],
                  localizationsDelegates: const [
                    AppLocalizationsDelegate(),
                    GlobalWidgetsLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  localeListResolutionCallback: (locales, supported) {
                    if (locale != null) {
                      return locale;
                    }
                    if (locales != null && locales.isNotEmpty) {
                      for (final candidate in locales) {
                        final match = supported.firstWhere(
                          (supportedLocale) =>
                              supportedLocale.languageCode == candidate.languageCode,
                          orElse: () => supported.first,
                        );
                        if (match.languageCode == candidate.languageCode) {
                          return match;
                        }
                      }
                    }
                    return supported.first;
                  },
                  initialRoute: SplashPage.routeName,
                  onGenerateRoute: _onGenerateRoute,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
