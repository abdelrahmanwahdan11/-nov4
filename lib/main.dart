import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/locale/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'presentation/controllers/app_controller.dart';
import 'presentation/controllers/auth_controller.dart';
import 'presentation/controllers/cart_controller.dart';
import 'presentation/controllers/catalog_controller.dart';
import 'presentation/controllers/meal_table_compare_controller.dart';
import 'presentation/controllers/tutorial_controller.dart';
import 'presentation/controllers/favorites_controller.dart';
import 'presentation/controllers/recently_viewed_controller.dart';
import 'presentation/controllers/meal_planner_controller.dart';
import 'data/local/cart_local_data_source.dart';
import 'data/local/food_local_data_source.dart';
import 'data/local/meal_table_local_data_source.dart';
import 'data/local/catalog_presets_local_data_source.dart';
import 'data/local/favorites_local_data_source.dart';
import 'data/local/recently_viewed_local_data_source.dart';
import 'data/local/meal_plan_local_data_source.dart';
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
import 'presentation/pages/compare/compare_meal_tables_page.dart';
import 'presentation/pages/meal_planner/meal_planner_page.dart';
import 'presentation/widgets/tutorial_overlay.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final foodDataSource = FoodLocalDataSource();
  final appController = AppController();
  final authController = AuthController(appController: appController);
  final cartController = CartController(
    catalogDataSource: foodDataSource,
    localDataSource: CartLocalDataSource(),
  );
  await cartController.initialize();
  final favoritesController = FavoritesController(
    dataSource: foodDataSource,
    localDataSource: FavoritesLocalDataSource(),
  );
  await favoritesController.initialize();
  final recentlyViewedController = RecentlyViewedController(
    dataSource: foodDataSource,
    localDataSource: RecentlyViewedLocalDataSource(),
  );
  await recentlyViewedController.initialize();
  final compareController = MealTableCompareController(
    dataSource: MealTableLocalDataSource(),
  );
  await compareController.load();
  final tutorialController = TutorialController(appController: appController);
  final catalogPresetsDataSource = CatalogPresetsLocalDataSource();
  final mealPlannerController = MealPlannerController(
    dataSource: foodDataSource,
    localDataSource: MealPlanLocalDataSource(),
  );
  await mealPlannerController.initialize();
  runApp(
    GreenBiteApp(
      appController: appController,
      authController: authController,
      cartController: cartController,
      compareController: compareController,
      tutorialController: tutorialController,
      favoritesController: favoritesController,
      recentlyViewedController: recentlyViewedController,
      foodDataSource: foodDataSource,
      catalogPresetsDataSource: catalogPresetsDataSource,
      mealPlannerController: mealPlannerController,
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
    required this.tutorialController,
    required this.favoritesController,
    required this.recentlyViewedController,
    required this.foodDataSource,
    required this.catalogPresetsDataSource,
    required this.mealPlannerController,
  });

  final AppController appController;
  final AuthController authController;
  final CartController cartController;
  final MealTableCompareController compareController;
  final TutorialController tutorialController;
  final FavoritesController favoritesController;
  final RecentlyViewedController recentlyViewedController;
  final FoodLocalDataSource foodDataSource;
  final CatalogPresetsLocalDataSource catalogPresetsDataSource;
  final MealPlannerController mealPlannerController;

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
            controller: CatalogController(
              dataSource: foodDataSource,
              connectionOverride: appController.connectionOverride,
              layoutMode: appController.catalogGridMode,
              onLayoutModeChanged: appController.setCatalogGridMode,
              sortOption: appController.catalogSortOption,
              onSortOptionChanged: appController.setCatalogSortOption,
              presetsDataSource: catalogPresetsDataSource,
            ),
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
      case CompareMealTablesPage.routeName:
        return MaterialPageRoute<void>(
          builder: (_) => const CompareMealTablesPage(),
          settings: settings,
        );
      case MealPlannerPage.routeName:
        return MaterialPageRoute<void>(
          builder: (_) => const MealPlannerPage(),
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
              child: FavoritesScope(
                controller: favoritesController,
                child: RecentlyViewedScope(
                  controller: recentlyViewedController,
                  child: MealTableCompareScope(
                    controller: compareController,
                    child: TutorialScope(
                      controller: tutorialController,
                      child: MealPlannerScope(
                        controller: mealPlannerController,
                        child: MaterialApp(
                          title: 'GreenBite',
                          debugShowCheckedModeBanner: false,
                          themeMode: appController.themeMode,
                          theme: AppTheme.buildTheme(
                            Brightness.light,
                            primarySeed: appController.primarySeed,
                            density: appController.contentDensity.value,
                          ),
                          darkTheme: AppTheme.buildTheme(
                            Brightness.dark,
                            primarySeed: appController.primarySeed,
                            density: appController.contentDensity.value,
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
                          builder: (context, child) {
                            if (child == null) {
                              return const SizedBox.shrink();
                            }
                            return TutorialOverlay(child: child);
                          },
                          initialRoute: SplashPage.routeName,
                          onGenerateRoute: _onGenerateRoute,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ),
        );
      },
    );
  }
}
