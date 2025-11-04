import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../domain/models/food_item.dart';
import 'skeleton_loader.dart';

class FoodCard extends StatelessWidget {
  const FoodCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onAdd,
    this.sizeVariant = FoodCardSizeVariant.medium,
  });

  final FoodItem item;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  final FoodCardSizeVariant sizeVariant;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final badgeStyle = theme.textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.w600,
      color: theme.colorScheme.onPrimary,
    );
    final colorScheme = theme.colorScheme;

    final width = sizeVariant == FoodCardSizeVariant.compact ? 160.0 : null;
    final height = sizeVariant == FoodCardSizeVariant.compact ? 240.0 : null;

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: width,
          height: height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 4 / 3,
                    child: Hero(
                      tag: 'food_${item.id}',
                      child: Image.network(
                        item.imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }
                          return const SkeletonLoader(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: colorScheme.surfaceVariant,
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.image_not_supported,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Wrap(
                      spacing: 8,
                      children: [
                        if (item.isNew)
                          _Badge(
                            label: 'New',
                            background: colorScheme.primary,
                            style: badgeStyle,
                          ),
                        if (item.isVegan)
                          _Badge(
                            label: 'Vegan',
                            background: colorScheme.tertiary,
                            style: badgeStyle,
                          ),
                        if (item.isLowCalorie)
                          _Badge(
                            label: 'Low kcal',
                            background: colorScheme.secondary,
                            style: badgeStyle,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Text(
                            '\\$${item.price.toStringAsFixed(2)}',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: onAdd,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            child: const Icon(Icons.add),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 380.ms, curve: Curves.easeOut)
        .moveY(begin: 30, end: 0, curve: Curves.easeOut);
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.background, required this.style});

  final String label;
  final Color background;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(label, style: style),
      ),
    );
  }
}

enum FoodCardSizeVariant { compact, medium }

class FoodCardSkeleton extends StatelessWidget {
  const FoodCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          SkeletonLoader(
            height: 160,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader(width: 160, height: 20),
                SizedBox(height: 12),
                SkeletonLoader(width: 220, height: 16),
                SizedBox(height: 8),
                SkeletonLoader(width: 180, height: 16),
                SizedBox(height: 20),
                SkeletonLoader(width: 120, height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
