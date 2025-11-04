import 'package:flutter/material.dart';

import '../../controllers/app_controller.dart';
import '../../widgets/greenbite_logo.dart';
import '../home/home_shell_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key, required this.controller});

  static const routeName = '/splash';

  final AppController controller;

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
    if (!mounted) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.controller.firstRun) {
        await widget.controller.markFirstRunComplete();
      }
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushReplacementNamed(HomeShellPage.routeName);
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
