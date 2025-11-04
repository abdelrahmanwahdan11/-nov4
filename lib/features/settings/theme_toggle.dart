import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/theme/tokens.dart';
import '../../main.dart';

class ThemeModeToggle extends StatelessWidget {
  const ThemeModeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.themeMode;
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: AppTokens.radius.lg,
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outline.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          _ThemeRow(
            icon: IconlyLight.sun,
            label: 'Light',
            selected: themeMode == ThemeMode.light,
            onTap: () => context.updateThemeMode(ThemeMode.light),
          ),
          Divider(height: 1, color: colorScheme.outline.withOpacity(0.2)),
          _ThemeRow(
            icon: IconlyLight.moon,
            label: 'Dark',
            selected: themeMode == ThemeMode.dark,
            onTap: () => context.updateThemeMode(ThemeMode.dark),
          ),
          Divider(height: 1, color: colorScheme.outline.withOpacity(0.2)),
          _ThemeRow(
            icon: IconlyLight.setting,
            label: 'System',
            selected: themeMode == ThemeMode.system,
            onTap: () => context.updateThemeMode(ThemeMode.system),
          ),
        ],
      ),
    );
  }
}

class _ThemeRow extends StatelessWidget {
  const _ThemeRow({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppTokens.spacing.lg,
          vertical: AppTokens.spacing.md,
        ),
        child: Row(
          children: [
            Icon(icon, color: colorScheme.onSurface.withOpacity(0.7)),
            SizedBox(width: AppTokens.spacing.md),
            Expanded(child: Text(label, style: textTheme.bodyLarge)),
            AnimatedContainer(
              duration: AppTokens.motion.fast,
              curve: AppTokens.motion.curve,
              height: 24,
              width: 24,
              decoration: BoxDecoration(
                color: selected ? colorScheme.primary : Colors.transparent,
                border: Border.all(color: colorScheme.outline.withOpacity(0.4)),
                borderRadius: AppTokens.radius.sm,
              ),
              child: selected
                  ? Icon(IconlyBold.tick_square, color: colorScheme.onPrimary, size: 16)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
