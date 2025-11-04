import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';
import '../../main.dart';

class TransactionItem extends StatelessWidget {
  const TransactionItem({required this.model, super.key});

  final TransactionModel model;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final amountColor = model.amount >= 0 ? colorScheme.tertiary : colorScheme.error;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppTokens.spacing.xl, vertical: AppTokens.spacing.sm),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant,
              borderRadius: AppTokens.radius.md,
            ),
            child: Icon(model.iconData, color: colorScheme.onSurface.withOpacity(0.7)),
          ),
          SizedBox(width: AppTokens.spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(model.title, style: textTheme.bodyLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                SizedBox(height: AppTokens.spacing.xs),
                Text(model.subtitle, style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.6))),
              ],
            ),
          ),
          SizedBox(width: AppTokens.spacing.md),
          Text(
            model.amount >= 0 ? '+\u0024${model.amount.toStringAsFixed(2)}' : '-\u0024${model.amount.abs().toStringAsFixed(2)}',
            style: textTheme.bodyLarge?.copyWith(color: amountColor),
          ),
        ],
      ),
    );
  }
}
