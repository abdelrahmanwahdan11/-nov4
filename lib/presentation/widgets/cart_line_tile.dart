import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../../core/locale/localization_extension.dart';
import '../../domain/models/food_item.dart';
import '../controllers/cart_controller.dart';

class CartLineTile extends StatelessWidget {
  const CartLineTile({
    super.key,
    required this.entry,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  final CartEntry entry;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final item = entry.item;
    final line = entry.line;
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CartItemThumbnail(item: item),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${item.weight} g • ${item.kcal} kcal',
                        style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: context.tr('cart_remove'),
                  onPressed: onRemove,
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('cart_line_each'),
                        style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\\$${line.unitPrice.toStringAsFixed(2)}',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        context.tr('cart_line_total'),
                        style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\\$${entry.lineTotal.toStringAsFixed(2)}',
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                _QuantityStepper(
                  quantity: line.qty,
                  onIncrement: onIncrement,
                  onDecrement: onDecrement,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CartItemThumbnail extends StatelessWidget {
  const _CartItemThumbnail({required this.item});

  final FoodItem item;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: AspectRatio(
        aspectRatio: 1,
        child: Image.network(
          item.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, _, __) {
            return Container(
              color: Theme.of(context).colorScheme.surfaceVariant,
              alignment: Alignment.center,
              child: const Icon(Icons.restaurant_outlined),
            );
          },
        ),
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.6),
        borderRadius: BorderRadius.circular(32),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onDecrement,
            icon: const Icon(Icons.remove_rounded),
            tooltip: context.tr('cart_stepper_decrease'),
          ),
          CartQuantityBadge(quantity: quantity),
          IconButton(
            onPressed: onIncrement,
            icon: const Icon(Icons.add_rounded),
            tooltip: context.tr('cart_stepper_increase'),
          ),
        ],
      ),
    );
  }
}

class CartQuantityBadge extends StatefulWidget {
  const CartQuantityBadge({super.key, required this.quantity});

  final int quantity;

  @override
  State<CartQuantityBadge> createState() => _CartQuantityBadgeState();
}

class _CartQuantityBadgeState extends State<CartQuantityBadge> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController.unbounded(vsync: this);

  @override
  void initState() {
    super.initState();
    _trigger();
  }

  @override
  void didUpdateWidget(CartQuantityBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.quantity != oldWidget.quantity) {
      _controller.value = 0;
      _trigger();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  SpringSimulation _simulation() {
    return SpringSimulation(
      const SpringDescription(mass: 1, stiffness: 180, damping: 14),
      0,
      1,
      0,
    );
  }

  Future<void> _trigger() async {
    await _controller.animateWith(_simulation());
    if (mounted) {
      _controller.value = 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final value = _controller.value.clamp(0.0, 1.0);
        final scale = 1 + (1 - value) * 0.18;
        return Transform.scale(scale: scale, child: child);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(
          '${widget.quantity}',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
