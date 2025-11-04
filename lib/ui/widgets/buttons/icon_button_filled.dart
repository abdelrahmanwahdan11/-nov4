import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/theme/tokens.dart';

class IconButtonFilled extends StatefulWidget {
  const IconButtonFilled({required this.icon, required this.onPressed, super.key});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  State<IconButtonFilled> createState() => _IconButtonFilledState();
}

class _IconButtonFilledState extends State<IconButtonFilled> {
  bool _pressed = false;

  void _setPressed(bool value) {
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AnimatedScale(
      scale: _pressed ? 0.94 : 1,
      duration: AppTokens.motion.fast,
      curve: AppTokens.motion.curve,
      child: ClipRRect(
        borderRadius: AppTokens.radius.md,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.12),
              borderRadius: AppTokens.radius.md,
              border: Border.all(color: colorScheme.primary.withOpacity(0.4)),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onPressed,
                onHighlightChanged: _setPressed,
                borderRadius: AppTokens.radius.md,
                child: SizedBox(
                  height: 48,
                  width: 48,
                  child: Icon(widget.icon, color: colorScheme.primary, size: 22),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
