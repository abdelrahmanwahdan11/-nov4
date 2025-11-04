import 'package:flutter/material.dart';

import '../../../core/theme/tokens.dart';

class PillSelector extends StatelessWidget {
  const PillSelector({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppTokens.spacing.lg,
        vertical: AppTokens.spacing.xs,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.58),
        borderRadius: AppTokens.radius.lg,
        border: Border.all(color: colorScheme.outline.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundImage: const NetworkImage('https://flagcdn.com/w40/us.png'),
          ),
          SizedBox(width: AppTokens.spacing.xs),
          Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface)),
        ],
      ),
    );
  }
}
