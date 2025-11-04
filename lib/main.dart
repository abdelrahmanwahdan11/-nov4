import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/localization/app_localizations.dart';
import 'core/routing/app_router.dart';
import 'core/state/app_store.dart';
import 'core/state/simple_provider.dart';
import 'core/storage/app_preferences.dart';
import 'ui/controllers/auth_controller.dart';
import 'ui/controllers/cart_controller.dart';
import 'ui/controllers/session_controller.dart';
import 'ui/controllers/tutorial_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await AppPreferences.getInstance();
  runApp(GreenlyApp(prefs: prefs));
}

class GreenlyApp extends StatefulWidget {
  const GreenlyApp({super.key, required this.prefs});

  final AppPreferences prefs;

  @override
  State<GreenlyApp> createState() => _GreenlyAppState();
}

class _GreenlyAppState extends State<GreenlyApp> {
  late final AppStore _store;

  @override
  void initState() {
    super.initState();
    _store = AppStore(widget.prefs);
  }

  @override
  void dispose() {
    _store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppStoreScope(
      store: _store,
      child: ChangeNotifierProvider(
        create: (_) => SessionController(widget.prefs),
        child: ChangeNotifierProvider(
          create: (_) => AuthController(),
          child: ChangeNotifierProvider(
            create: (_) => CartController(),
            child: ChangeNotifierProvider(
              create: (_) => TutorialController(widget.prefs),
              child: AnimatedBuilder(
                animation: _store,
                builder: (context, _) {
                  return MaterialApp(
                    debugShowCheckedModeBanner: false,
                    title: 'Greenly',
                    locale: _store.locale,
                    supportedLocales: AppLocalizations.supportedLocales,
                    localizationsDelegates: const [
                      AppLocalizations.delegate,
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                    ],
                    themeMode: _store.themeMode,
                    theme: _store.buildTheme(Brightness.light),
                    darkTheme: _store.buildTheme(Brightness.dark),
                    onGenerateRoute: onGenerateRoute,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
