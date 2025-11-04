import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/theme_tokens.dart';
import '../controllers/app_controller.dart';

class ManualFlipCard extends StatefulWidget {
  const ManualFlipCard({
    super.key,
    required this.front,
    required this.back,
    this.duration = const Duration(milliseconds: 550),
  });

  final Widget front;
  final Widget back;
  final Duration duration;

  @override
  State<ManualFlipCard> createState() => _ManualFlipCardState();
}

class _ManualFlipCardState extends State<ManualFlipCard> {
  bool _isFront = true;

  void _toggle() {
    setState(() {
      _isFront = !_isFront;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: AnimatedSwitcher(
        duration: widget.duration,
        transitionBuilder: (child, animation) {
          final rotate = Tween<double>(begin: math.pi, end: 0).animate(animation);
          return AnimatedBuilder(
            animation: rotate,
            child: child,
            builder: (context, child) {
              final isUnder = (child?.key != ValueKey<bool>(_isFront));
              final tilt = ((animation.value - 0.5).abs() - 0.5) * 0.003;
              final value = rotate.value;
              return Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(isUnder ? -value : value)
                  ..setEntry(3, 0, tilt),
                alignment: Alignment.center,
                child: child,
              );
            },
          );
        },
        layoutBuilder: (currentChild, previousChildren) {
          return Stack(
            alignment: Alignment.center,
            children: <Widget>[...previousChildren, if (currentChild != null) currentChild],
          );
        },
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        child: _isFront
            ? _FlipSide(key: const ValueKey<bool>(true), child: widget.front)
            : _FlipSide(key: const ValueKey<bool>(false), child: widget.back),
      ),
    );
  }
}

class _FlipSide extends StatelessWidget {
  const _FlipSide({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final appController = AppScope.of(context);
    return ValueListenableBuilder<ContentDensity>(
      valueListenable: appController.contentDensity,
      builder: (context, density, _) {
        final radius = ThemeTokens.radiusForDensity(density);
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                offset: const Offset(0, 8),
                blurRadius: 20,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: child,
          ),
        );
      },
    );
  }
}
