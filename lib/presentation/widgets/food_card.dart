import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/theme_tokens.dart';
import '../../domain/models/food_item.dart';
import '../controllers/app_controller.dart';
import '../controllers/tutorial_controller.dart';
import 'skeleton_loader.dart';
import 'tutorial_overlay.dart';

class FoodCard extends StatelessWidget {
  const FoodCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onAdd,
    this.sizeVariant = FoodCardSizeVariant.medium,
    this.tutorialTarget,
    this.onToggleFavorite,
    this.isFavorite = false,
    this.favoriteTooltip,
  });

  final FoodItem item;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  final FoodCardSizeVariant sizeVariant;
  final TutorialTarget? tutorialTarget;
  final VoidCallback? onToggleFavorite;
  final bool isFavorite;
  final String? favoriteTooltip;

  @override
  Widget build(BuildContext context) {
    final appController = AppScope.of(context);
    return ValueListenableBuilder<ContentDensity>(
      valueListenable: appController.contentDensity,
      builder: (context, density, _) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final badgeStyle = theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onPrimary,
        );
        final width = sizeVariant == FoodCardSizeVariant.compact ? 160.0 : null;
        final height = sizeVariant == FoodCardSizeVariant.compact ? 240.0 : null;
        final radius = ThemeTokens.radiusForDensity(density);
        final contentPadding = ThemeTokens.cardPaddingForDensity(density);
        final badgeOffset = ThemeTokens.badgeOffsetForDensity(density);

        return Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
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
                              return SkeletonLoader(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
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
                        top: badgeOffset,
                        left: badgeOffset,
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
                      if (onToggleFavorite != null)
                        PositionedDirectional(
                          top: badgeOffset,
                          end: badgeOffset,
                          child: Material(
                            color: colorScheme.surface.withOpacity(0.85),
                            shape: const CircleBorder(),
                            child: IconButton(
                              onPressed: onToggleFavorite,
                              tooltip: favoriteTooltip,
                              icon: Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: isFavorite ? colorScheme.error : colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: contentPadding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: density == ContentDensity.compact ? 2 : 4),
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
                              _buildAddButton(),
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
      },
    );
  }

  Widget _buildAddButton() {
    Widget button = ElevatedButton(
      onPressed: onAdd,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: const Icon(Icons.add),
    );
    if (tutorialTarget != null) {
      button = TutorialTargetAnchor(target: tutorialTarget!, child: button);
    }
    return button;
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
    final appController = AppScope.of(context);
    return ValueListenableBuilder<ContentDensity>(
      valueListenable: appController.contentDensity,
      builder: (context, density, _) {
        final radius = ThemeTokens.radiusForDensity(density);
        final padding = ThemeTokens.cardPaddingForDensity(density);
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonLoader(
                height: 160,
                borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
              ),
              Padding(
                padding: padding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SkeletonLoader(width: 160, height: 20),
                    SizedBox(height: density == ContentDensity.compact ? 8 : 12),
                    const SkeletonLoader(width: 220, height: 16),
                    SizedBox(height: density == ContentDensity.compact ? 6 : 8),
                    const SkeletonLoader(width: 180, height: 16),
                    SizedBox(height: density == ContentDensity.compact ? 14 : 20),
                    const SkeletonLoader(width: 120, height: 24),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
