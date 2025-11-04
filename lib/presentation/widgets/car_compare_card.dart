import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../domain/models/car.dart';

class CarCompareCard extends StatelessWidget {
  const CarCompareCard({
    super.key,
    required this.car,
    required this.isSelected,
    required this.onToggle,
    required this.onPreview,
    required this.primaryActionLabel,
    required this.previewTooltip,
  });

  final Car car;
  final bool isSelected;
  final VoidCallback onToggle;
  final VoidCallback onPreview;
  final String primaryActionLabel;
  final String previewTooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final borderColor = isSelected ? colorScheme.primary : colorScheme.outlineVariant;

    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1.4),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.04),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: Image.network(
                  car.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: colorScheme.surfaceVariant.withOpacity(0.3),
                      alignment: Alignment.center,
                      child: Icon(Icons.directions_car, color: colorScheme.onSurfaceVariant),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              car.displayName,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              '${car.year}',
              style: theme.textTheme.labelMedium?.copyWith(color: theme.textTheme.bodySmall?.color),
            ),
            const Spacer(),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildChip(context, car.specs['range'] ?? ''),
                _buildChip(context, car.specs['battery'] ?? ''),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: onToggle,
                    child: Text(primaryActionLabel),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: onPreview,
                  icon: const Icon(Icons.threed_rotation),
                  tooltip: previewTooltip,
                ),
              ],
            ),
          ],
        ),
      ).animate().scale(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutBack,
          ),
    );
  }

  Widget _buildChip(BuildContext context, String label) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.primary),
      ),
    );
  }
}
