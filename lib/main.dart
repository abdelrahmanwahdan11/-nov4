import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/locale/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'presentation/controllers/app_controller.dart';
import 'presentation/pages/splash/splash_page.dart';
import 'presentation/pages/home/home_shell_page.dart';
import 'presentation/pages/settings/settings_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appController = AppController();
  runApp(GreenBiteApp(controller: appController));
}

class GreenBiteApp extends StatelessWidget {
  const GreenBiteApp({super.key, required this.controller});

  final AppController controller;

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case SplashPage.routeName:
        return MaterialPageRoute<void>(
          builder: (_) => SplashPage(controller: controller),
          settings: settings,
        );
      case HomeShellPage.routeName:
        return MaterialPageRoute<void>(
          builder: (_) => HomeShellPage(controller: controller),
          settings: settings,
        );
      case SettingsPage.routeName:
        return MaterialPageRoute<void>(
          builder: (_) => SettingsPage(controller: controller),
          settings: settings,
        );
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final locale = controller.locale;

        return AppScope(
          controller: controller,
          child: MaterialApp(
            title: 'GreenBite',
            debugShowCheckedModeBanner: false,
            themeMode: controller.themeMode,
            theme: AppTheme.buildTheme(
              Brightness.light,
              primarySeed: controller.primarySeed,
            ),
            darkTheme: AppTheme.buildTheme(
              Brightness.dark,
              primarySeed: controller.primarySeed,
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
                    (supportedLocale) => supportedLocale.languageCode == candidate.languageCode,
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
        );
      },
    );
  }
}
