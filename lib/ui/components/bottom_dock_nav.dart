import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/theme/tokens.dart';

class BottomDockNav extends StatelessWidget {
  const BottomDockNav({required this.currentIndex, required this.onIndexChanged, super.key});

  final int currentIndex;
  final ValueChanged<int> onIndexChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final items = const [
      IconlyLight.home,
      IconlyLight.chart,
      IconlyBold.plus,
      IconlyLight.wallet,
      IconlyLight.profile,
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(AppTokens.spacing.lg, 0, AppTokens.spacing.lg, AppTokens.spacing.lg),
      child: ClipRRect(
        borderRadius: AppTokens.radius.xl,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.surface.withOpacity(0.94),
              borderRadius: AppTokens.radius.xl,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  offset: const Offset(0, 8),
                  blurRadius: 24,
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppTokens.spacing.lg, vertical: AppTokens.spacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (int i = 0; i < items.length; i++)
                    _DockItem(
                      icon: items[i],
                      active: currentIndex == i,
                      onTap: () => onIndexChanged(i),
                      isCenter: i == 2,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DockItem extends StatefulWidget {
  const _DockItem({
    required this.icon,
    required this.active,
    required this.onTap,
    this.isCenter = false,
  });

  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  final bool isCenter;

  @override
  State<_DockItem> createState() => _DockItemState();
}

class _DockItemState extends State<_DockItem> {
  bool _pressed = false;

  void _setPressed(bool value) {
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconColor = widget.active ? colorScheme.onSurface : colorScheme.onSurface.withOpacity(0.45);
    final size = widget.isCenter ? 52.0 : 44.0;

    return AnimatedScale(
      scale: _pressed ? 0.92 : 1,
      duration: AppTokens.motion.fast,
      curve: AppTokens.motion.curve,
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => _setPressed(true),
        onTapCancel: () => _setPressed(false),
        onTapUp: (_) => _setPressed(false),
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: size,
          width: size,
          decoration: BoxDecoration(
            color: widget.active ? colorScheme.primary.withOpacity(0.18) : Colors.transparent,
            borderRadius: AppTokens.radius.md,
          ),
          child: Icon(widget.icon, color: iconColor, size: widget.isCenter ? 26 : 22),
        ),
      ),
    );
  }
}
