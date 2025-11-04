import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/locale/localization_extension.dart';
import '../../controllers/app_controller.dart';
import '../auth/login_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key, required this.controller});

  static const routeName = '/onboarding';

  final AppController controller;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late final PageController _pageController;
  late final ValueNotifier<int> _pageIndex;
  Timer? _autoPlayTimer;

  List<_OnboardingSlide> get _slides => const [
        _OnboardingSlide(
          assetUrl:
              'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=900&q=80',
          titleKey: 'onboarding_title_1',
          bodyKey: 'onboarding_body_1',
        ),
        _OnboardingSlide(
          assetUrl:
              'https://images.unsplash.com/photo-1525755662778-989d0524087e?auto=format&fit=crop&w=900&q=80',
          titleKey: 'onboarding_title_2',
          bodyKey: 'onboarding_body_2',
        ),
        _OnboardingSlide(
          assetUrl:
              'https://images.unsplash.com/photo-1496417263034-38ec4f0b665a?auto=format&fit=crop&w=900&q=80',
          titleKey: 'onboarding_title_3',
          bodyKey: 'onboarding_body_3',
        ),
      ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageIndex = ValueNotifier<int>(0);
    _scheduleAutoPlay();
  }

  void _scheduleAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!_pageController.hasClients) {
        return;
      }
      final nextPage = (_pageIndex.value + 1) % _slides.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> _completeOnboarding() async {
    await widget.controller.setSeenOnboarding(true);
    if (!mounted) {
      return;
    }
    Navigator.of(context).pushReplacementNamed(LoginPage.routeName);
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    _pageIndex.dispose();
    super.dispose();
  }

  Widget _buildIndicator(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _pageIndex,
      builder: (context, value, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_slides.length, (index) {
            final isActive = index == value;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 8,
              width: isActive ? 24 : 8,
              decoration: BoxDecoration(
                color: isActive
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.primary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
            );
          }),
        ).animate(key: ValueKey(value)).scale(duration: const Duration(milliseconds: 350));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final slides = _slides;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _completeOnboarding,
                child: Text(context.tr('onboarding_skip')),
              ),
            ).paddingSymmetric(horizontal: 16),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  _pageIndex.value = index;
                  _scheduleAutoPlay();
                },
                itemCount: slides.length,
                itemBuilder: (context, index) {
                  final slide = slides[index];
                  return _OnboardingCard(slide: slide);
                },
              ),
            ),
            const SizedBox(height: 12),
            _buildIndicator(context),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
              child: ValueListenableBuilder<int>(
                valueListenable: _pageIndex,
                builder: (context, value, _) {
                  final isLast = value == slides.length - 1;
                  return FilledButton(
                    onPressed: isLast
                        ? _completeOnboarding
                        : () => _pageController.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            ),
                    child: Text(
                      context.tr(
                        isLast ? 'onboarding_get_started' : 'onboarding_next',
                      ),
                    ),
                  ).animate().fadeIn(duration: const Duration(milliseconds: 300)).slideY(
                        begin: 0.3,
                        end: 0,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOut,
                      );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingCard extends StatelessWidget {
  const _OnboardingCard({required this.slide});

  final _OnboardingSlide slide;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.network(
                slide.assetUrl,
                fit: BoxFit.cover,
                width: double.infinity,
              ).animate().fadeIn(duration: const Duration(milliseconds: 500)),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            context.tr(slide.titleKey),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ).animate().fadeIn(duration: const Duration(milliseconds: 400)).slideY(
                begin: 0.3,
                end: 0,
                duration: const Duration(milliseconds: 400),
              ),
          const SizedBox(height: 16),
          Text(
            context.tr(slide.bodyKey),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ).animate().fadeIn(duration: const Duration(milliseconds: 400)).slideY(
                begin: 0.2,
                end: 0,
                duration: const Duration(milliseconds: 400),
              ),
        ],
      ),
    );
  }
}

class _OnboardingSlide {
  const _OnboardingSlide({
    required this.assetUrl,
    required this.titleKey,
    required this.bodyKey,
  });

  final String assetUrl;
  final String titleKey;
  final String bodyKey;
}

extension _PaddingX on Widget {
  Widget paddingSymmetric({double horizontal = 0, double vertical = 0}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
      child: this,
    );
  }
}
