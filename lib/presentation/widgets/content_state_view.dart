import 'package:flutter/material.dart';

class ContentStateView extends StatelessWidget {
  const ContentStateView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.primaryAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? primaryAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 56,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              if (primaryAction != null) ...[
                const SizedBox(height: 20),
                primaryAction!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
