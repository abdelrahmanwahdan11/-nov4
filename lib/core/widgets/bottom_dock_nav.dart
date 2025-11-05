import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../theme/tokens.dart';
import 'glass_container.dart';

class BottomDockNav extends StatelessWidget {
  const BottomDockNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.of(Theme.of(context).brightness);

    final items = <_DockItem>[
      _DockItem(icon: IconlyLight.home, labelKey: 'home'),
      _DockItem(icon: IconlyLight.category, labelKey: 'catalog'),
      _DockItem(icon: IconlyLight.paper_plus, labelKey: 'compare'),
      _DockItem(icon: IconlyLight.setting, labelKey: 'settings'),
    ];

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: GlassContainer(
        borderRadius: AppRadii.xlAll,
        backgroundColor: palette.surface.withOpacity(0.94),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < items.length; i++)
                _BottomDockItem(
                  item: items[i],
                  selected: i == currentIndex,
                  onTap: () => onTap(i),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomDockItem extends StatelessWidget {
  const _BottomDockItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _DockItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.of(Theme.of(context).brightness);
    final colorScheme = Theme.of(context).colorScheme;
    final iconColor = selected ? colorScheme.primary : palette.icon;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        curve: AppMotion.standard,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: selected ? colorScheme.primary.withOpacity(0.15) : Colors.transparent,
          borderRadius: AppRadii.lgAll,
        ),
        child: Icon(item.icon, color: iconColor),
      ),
    );
  }
}

class _DockItem {
  const _DockItem({required this.icon, required this.labelKey});

  final IconData icon;
  final String labelKey;
}
