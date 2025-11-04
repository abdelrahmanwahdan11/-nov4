import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/routing/app_router.dart';
import '../../controllers/session_controller.dart';

class OnboardingStoryScreen extends StatefulWidget {
  const OnboardingStoryScreen({super.key});

  @override
  State<OnboardingStoryScreen> createState() => _OnboardingStoryScreenState();
}

class _OnboardingStoryScreenState extends State<OnboardingStoryScreen> {
  final PageController _controller = PageController();
  late Timer _timer;
  int _currentIndex = 0;

  final List<String> _messages = const [
    'onboardingMsg1',
    'onboardingMsg2',
    'onboardingMsg3',
    'onboardingMsg4',
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      final next = (_currentIndex + 1) % _messages.length;
      if (!mounted) return;
      _controller.animateToPage(next, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _setCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.sharedPrefsFirstRunKey, true);
  }

  void _finish() {
    _setCompleted();
    context.read<SessionController>().setGuest(false);
    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  void _guest() {
    _setCompleted();
    context.read<SessionController>().setGuest(true);
    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  const Spacer(),
                  TextButton(
                    onPressed: _finish,
                    child: Text(loc.translate('onboardingSkip')),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (index) => setState(() => _currentIndex = index),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 240,
                        child: Image.network(
                          'https://picsum.photos/seed/onboarding$index/600/400',
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          loc.translate(_messages[index]),
                          style: theme.textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _messages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 6,
                    width: _currentIndex == index ? 24 : 8,
                    decoration: BoxDecoration(
                      color: _currentIndex == index ? theme.colorScheme.primary : theme.colorScheme.primary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pushNamed(AppRoutes.register),
                          child: Text(loc.translate('onboardingCreateAccount')),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pushNamed(AppRoutes.login),
                          child: Text(loc.translate('onboardingLogin')),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _guest,
                    child: Text(loc.translate('onboardingGuest')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final next = (_currentIndex + 1).clamp(0, _messages.length - 1);
          if (next == _currentIndex) {
            _finish();
          } else {
            _controller.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
          }
        },
        label: Text(loc.translate('onboardingNext')),
      ),
    );
  }
}
