import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ayna_catalog/app/app_controller.dart';
import 'package:ayna_catalog/app/app_scope.dart';
import 'package:ayna_catalog/core/i18n/app_localizations.dart';
import 'package:ayna_catalog/core/theme/app_theme.dart';
import 'package:ayna_catalog/router/app_router.dart';

const int _phaseGatePrevious = 9;
const int _phaseGateCurrent = 10;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _configureDebugLogger();

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final int? storedPhase = prefs.getInt(AppController.buildPhaseKey);
  if (storedPhase != _phaseGatePrevious) {
    final String mismatchMessage =
        'Phase progression mismatch: expected $_phaseGatePrevious but found ${storedPhase ?? 'unset'}.';
    throw StateError(mismatchMessage);
  }

  final AppController controller = await AppController.initialize(prefs);
  controller.markPhaseProgress(_phaseGateCurrent);
  assert(() {
    debugPrint('[Ayna][Phase] advanced to $_phaseGateCurrent');
    return true;
  }());

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

void _configureDebugLogger() {
  assert(() {
    final Stopwatch startupTimer = Stopwatch()..start();
    final WidgetsBinding binding = WidgetsBinding.instance;
    binding.addPostFrameCallback((_) {
      startupTimer.stop();
      debugPrint('[Ayna][Startup] first frame in ${startupTimer.elapsedMilliseconds}ms');
    });
    binding.addTimingsCallback((List<FrameTiming> timings) {
      for (final FrameTiming frameTiming in timings) {
        debugPrint(
          '[Ayna][FrameTiming] build=${frameTiming.buildDuration.inMilliseconds}ms '
          'raster=${frameTiming.rasterDuration.inMilliseconds}ms',
        );
      }
    });
    return true;
  }());
}
