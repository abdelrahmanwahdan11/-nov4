import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/i18n/app_localizations.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/tokens.dart';
import '../router/app_router.dart';
import 'app_controller.dart';
import 'app_scope.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final controller = await AppController.initialize(prefs);

  runApp(
    AppScope(
      notifier: controller,
      child: _AynaApp(controller: controller),
    ),
  );
}

class _AynaApp extends StatefulWidget {
  const _AynaApp({required this.controller});

  final AppController controller;

  @override
  State<_AynaApp> createState() => _AynaAppState();
}

class _AynaAppState extends State<_AynaApp> {
  late final AppRouter _router = AppRouter(controller: widget.controller);

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final locale = controller.locale;
        final seed = controller.primaryColor;

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Ayna Catalog & Compare',
          theme: AppTheme.light(locale: locale, seed: seed),
          darkTheme: AppTheme.dark(locale: locale, seed: seed),
          themeMode: controller.themeMode,
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          builder: (context, child) {
            final textDirection = locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr;
            return Directionality(textDirection: textDirection, child: child ?? const SizedBox.shrink());
          },
          initialRoute: AppRouter.initialRoute,
          onGenerateRoute: _router.onGenerateRoute,
          navigatorObservers: _router.observers,
        );
      },
    );
  }
}
