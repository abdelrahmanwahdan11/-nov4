import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/theme/tokens.dart';
import 'buttons/pill_selector.dart';
import 'buttons/primary_button.dart';
import 'buttons/tonal_button.dart';
import 'buttons/icon_button_filled.dart';

class HeaderGradientContainer extends StatefulWidget {
  const HeaderGradientContainer({
    required this.balance,
    required this.subtitle,
    required this.onAddMoney,
    required this.onSendMoney,
    super.key,
  });

  final double balance;
  final String subtitle;
  final VoidCallback onAddMoney;
  final VoidCallback onSendMoney;

  @override
  State<HeaderGradientContainer> createState() => _HeaderGradientContainerState();
}

class _HeaderGradientContainerState extends State<HeaderGradientContainer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _reveal;
  bool _obscured = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: AppTokens.motion.fast);
    _reveal = CurvedAnimation(parent: _controller, curve: AppTokens.motion.curve);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleEye() {
    setState(() {
      _obscured = !_obscured;
      if (_obscured) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final gradient = Theme.of(context).brightness == Brightness.dark
        ? AppTokens.gradients.headerDark
        : AppTokens.gradients.headerLight;

    return ClipRRect(
      borderRadius: AppTokens.radius.lg,
      child: Container(
        decoration: BoxDecoration(gradient: gradient),
        padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const PillSelector(label: 'USD Account'),
                SizedBox(width: AppTokens.spacing.md),
                _IconButtonGhost(icon: IconlyLight.show, onTap: _toggleEye),
                SizedBox(width: AppTokens.spacing.sm),
                _IconButtonGhost(icon: IconlyLight.more_circle, onTap: () {}),
              ],
            ),
            SizedBox(height: AppTokens.spacing.md),
            AnimatedBuilder(
              animation: _reveal,
              builder: (context, child) {
                final obscuredValue = '•••••••';
                final balanceText = _obscured
                    ? obscuredValue
                    : '\$${widget.balance.toStringAsFixed(2)}';
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: AppTokens.motion.fast,
                      style: textTheme.displayLarge!.copyWith(color: colors.onSurface),
                      child: Text(balanceText),
                    ),
                    SizedBox(height: AppTokens.spacing.xs),
                    Text(widget.subtitle, style: textTheme.bodySmall?.copyWith(color: colors.onSurface.withOpacity(0.6))),
                  ],
                );
              },
            ),
            SizedBox(height: AppTokens.spacing.lg),
            Row(
              children: [
                Expanded(
                  child: PrimaryButton.icon(
                    icon: IconlyBold.plus,
                    label: 'Add Money',
                    onPressed: widget.onAddMoney,
                  ),
                ),
                SizedBox(width: AppTokens.spacing.md),
                Expanded(
                  child: TonalButton.icon(
                    icon: IconlyLight.send,
                    label: 'Send Money',
                    onPressed: widget.onSendMoney,
                  ),
                ),
                SizedBox(width: AppTokens.spacing.md),
                IconButtonFilled(icon: IconlyLight.more_square, onPressed: () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _IconButtonGhost extends StatefulWidget {
  const _IconButtonGhost({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_IconButtonGhost> createState() => _IconButtonGhostState();
}

class _IconButtonGhostState extends State<_IconButtonGhost> {
  bool _pressed = false;

  void _onChanged(bool pressed) {
    setState(() => _pressed = pressed);
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.7);
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _onChanged(true),
      onTapCancel: () => _onChanged(false),
      onTapUp: (_) => _onChanged(false),
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        duration: AppTokens.motion.fast,
        scale: _pressed ? 0.95 : 1,
        child: Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.32),
            borderRadius: AppTokens.radius.md,
            border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.4)),
          ),
          child: Icon(widget.icon, color: iconColor),
        ),
      ),
    );
  }
}
