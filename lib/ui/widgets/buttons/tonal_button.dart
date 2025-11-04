import 'package:flutter/material.dart';
import '../../../core/theme/tokens.dart';

class TonalButton extends StatefulWidget {
  const TonalButton({required this.label, required this.onPressed, super.key}) : icon = null;

  const TonalButton.icon({required IconData this.icon, required this.label, required this.onPressed, super.key});

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  State<TonalButton> createState() => _TonalButtonState();
}

class _TonalButtonState extends State<TonalButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AnimatedScale(
      scale: _pressed ? 0.98 : 1,
      duration: AppTokens.motion.fast,
      curve: AppTokens.motion.curve,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: AppTokens.radius.md,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: AppTokens.radius.md,
            onTap: widget.onPressed,
            onHighlightChanged: _setPressed,
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: AppTokens.spacing.sm,
                horizontal: AppTokens.spacing.xl,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, color: colorScheme.primary, size: 20),
                    SizedBox(width: AppTokens.spacing.sm),
                  ],
                  Text(widget.label, style: textTheme.labelLarge?.copyWith(color: colorScheme.primary)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
