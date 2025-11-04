import 'package:flutter/material.dart';

import '../../core/locale/localization_extension.dart';
import '../../domain/models/in_app_message.dart';
import '../controllers/in_app_messaging_controller.dart';

typedef ContextualNudgeActionCallback = void Function(
  InAppNudgeDefinition nudge,
  String? route,
);

typedef ContextualNudgeDismissCallback = void Function(InAppNudgeDefinition nudge);

class ContextualNudgeOverlay extends StatelessWidget {
  const ContextualNudgeOverlay({
    super.key,
    required this.controller,
    required this.surface,
    required this.isEnabled,
    required this.additionalBottomPadding,
    required this.onAction,
    this.onDismiss,
  });

  final InAppMessagingController controller;
  final MessageSurface surface;
  final bool isEnabled;
  final double additionalBottomPadding;
  final ContextualNudgeActionCallback onAction;
  final ContextualNudgeDismissCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    if (!isEnabled) {
      return const SizedBox.shrink();
    }
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = additionalBottomPadding + mediaQuery.padding.bottom;
    return ValueListenableBuilder<InAppNudgeDefinition?>(
      valueListenable: controller.nudgeFor(surface),
      builder: (context, nudge, _) {
        return IgnorePointer(
          ignoring: nudge == null,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 240),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: nudge == null
                ? const SizedBox.shrink()
                : Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPadding),
                      child: _ContextualNudgeCard(
                        key: ValueKey<String>(nudge.id),
                        nudge: nudge,
                        onAction: () {
                          final route = controller.handleNudgeAction(nudge.id);
                          onAction(nudge, route);
                        },
                        onDismiss: () {
                          controller.dismissNudge(nudge.id);
                          onDismiss?.call(nudge);
                        },
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }
}

class _ContextualNudgeCard extends StatelessWidget {
  const _ContextualNudgeCard({
    super.key,
    required this.nudge,
    required this.onAction,
    required this.onDismiss,
  });

  final InAppNudgeDefinition nudge;
  final VoidCallback onAction;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final actionLabel = nudge.actionLabelKey != null ? context.tr(nudge.actionLabelKey!) : null;

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(28),
      color: colorScheme.surface,
      shadowColor: colorScheme.shadow.withOpacity(0.12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.auto_awesome_rounded, color: colorScheme.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr(nudge.titleKey),
                        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        context.tr(nudge.messageKey),
                        style: textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onDismiss,
                  icon: const Icon(Icons.close_rounded),
                  tooltip: context.tr('nudge_dismiss'),
                ),
              ],
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                child: Text(actionLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
