import 'package:flutter/material.dart';

import '../../controllers/app_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/greenbite_logo.dart';
import '../auth/login_page.dart';
import '../home/home_shell_page.dart';
import '../onboarding/onboarding_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({
    super.key,
    required this.controller,
    required this.authController,
  });

  static const routeName = '/splash';

  final AppController controller;
  final AuthController authController;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await widget.controller.initialize();
    await widget.authController.initialize();
    if (!mounted) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        return;
      }
      final controller = widget.controller;
      final authController = widget.authController;
      final nextRoute = !controller.seenOnboarding
          ? OnboardingPage.routeName
          : (authController.isAuthenticated || controller.isGuest)
              ? HomeShellPage.routeName
              : LoginPage.routeName;
      Navigator.of(context).pushReplacementNamed(nextRoute);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(),
        child: Center(
          child: FadeTransition(
            opacity: _animationController.drive(CurveTween(curve: Curves.easeInOut)),
            child: const GreenBiteLogo(),
          ),
        ),
      ),
    );
  }
}
