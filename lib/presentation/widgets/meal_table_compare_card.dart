import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../domain/models/meal_table.dart';

class MealTableCompareCard extends StatelessWidget {
  const MealTableCompareCard({
    required this.table,
    required this.isSelected,
    required this.onToggle,
    required this.onPreview,
    required this.primaryActionLabel,
    required this.previewTooltip,
    super.key,
  });

  final MealTable table;
  final bool isSelected;
  final VoidCallback onToggle;
  final VoidCallback onPreview;
  final String primaryActionLabel;
  final String previewTooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(24),
      elevation: 0,
      child: InkWell(
        onTap: onPreview,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected ? colorScheme.primary : colorScheme.surfaceVariant.withOpacity(0.4),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 4 / 3,
                      child: Image.network(
                        table.imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Tooltip(
                        message: previewTooltip,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.45),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(6),
                            child: Icon(Icons.visibility, size: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        table.displayName,
                        style: theme.textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        table.region,
                        style: theme.textTheme.labelMedium,
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.builder(
                          itemCount: table.highlights.length,
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final highlight = table.highlights[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.circle, size: 8, color: colorScheme.primary.withOpacity(0.8)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      highlight,
                                      style: theme.textTheme.bodySmall,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            table.stats['signature_drink'] ?? '',
                            style: theme.textTheme.labelSmall,
                          ),
                          FilledButton.tonal(
                            onPressed: onToggle,
                            style: FilledButton.styleFrom(
                              foregroundColor: isSelected
                                  ? colorScheme.onPrimary
                                  : colorScheme.primary,
                              backgroundColor:
                                  isSelected ? colorScheme.primary : colorScheme.primaryContainer,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              shape: const StadiumBorder(),
                            ),
                            child: Text(primaryActionLabel),
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
    ).animate().fadeIn(duration: const Duration(milliseconds: 220));
  }
}
