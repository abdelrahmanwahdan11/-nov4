import 'package:flutter/material.dart';

class QuickActionCard extends StatelessWidget {
  const QuickActionCard({
    super.key,
    required this.id,
    required this.child,
    required this.onFavorite,
    required this.onAddToCart,
    required this.favoriteLabel,
    required this.addLabel,
    this.isFavorite = false,
  });

  final String id;
  final Widget child;
  final VoidCallback onFavorite;
  final VoidCallback onAddToCart;
  final String favoriteLabel;
  final String addLabel;
  final bool isFavorite;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Dismissible(
        key: ValueKey<String>('quick_action_$id'),
        direction: DismissDirection.horizontal,
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            onFavorite();
        } else if (direction == DismissDirection.endToStart) {
          onAddToCart();
        }
        return false;
      },
      background: _ActionBackground(
        alignment: AlignmentDirectional.centerStart,
        color: isFavorite ? colorScheme.errorContainer : colorScheme.primaryContainer,
        foreground: isFavorite ? colorScheme.onErrorContainer : colorScheme.onPrimaryContainer,
        icon: isFavorite ? Icons.favorite : Icons.favorite_border,
        label: favoriteLabel,
      ),
      secondaryBackground: _ActionBackground(
        alignment: AlignmentDirectional.centerEnd,
        color: colorScheme.secondaryContainer,
        foreground: colorScheme.onSecondaryContainer,
        icon: Icons.add_shopping_cart,
        label: addLabel,
      ),
      child: child,
    ),
    );
  }
}

class _ActionBackground extends StatelessWidget {
  const _ActionBackground({
    required this.alignment,
    required this.color,
    required this.foreground,
    required this.icon,
    required this.label,
  });

  final AlignmentGeometry alignment;
  final Color color;
  final Color foreground;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
      ),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: foreground),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(color: foreground, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
