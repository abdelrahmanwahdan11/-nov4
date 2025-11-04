import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_constants.dart';
import 'core/localization/app_localizations.dart';
import 'core/localization/locale_controller.dart';
import 'core/routing/app_router.dart';
import 'core/theme/theme_controller.dart';
import 'ui/controllers/auth_controller.dart';
import 'ui/controllers/cart_controller.dart';
import 'ui/controllers/session_controller.dart';
import 'ui/controllers/tutorial_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(GreenlyApp(prefs: prefs));
}

class GreenlyApp extends StatelessWidget {
  const GreenlyApp({super.key, required this.prefs});

  final SharedPreferences prefs;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController(prefs)),
        ChangeNotifierProvider(create: (_) => LocaleController(prefs)),
        ChangeNotifierProvider(create: (_) => SessionController(prefs)),
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => CartController()),
        ChangeNotifierProvider(create: (_) => TutorialController(prefs)),
      ],
      child: Consumer2<ThemeController, LocaleController>(
        builder: (context, themeController, localeController, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Greenly',
            locale: localeController.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            themeMode: themeController.themeMode,
            theme: themeController.buildTheme(Brightness.light, localeController.locale),
            darkTheme: themeController.buildTheme(Brightness.dark, localeController.locale),
            onGenerateRoute: onGenerateRoute,
          );
        },
      ),
    );
  }
}
