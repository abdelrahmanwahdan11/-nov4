import 'package:flutter/material.dart';

import '../../core/locale/localization_extension.dart';
import '../../domain/models/in_app_message.dart';
import '../controllers/in_app_messaging_controller.dart';

typedef InAppBannerActionCallback = void Function(
  InAppBannerDefinition banner,
  String? route,
);

class InAppBannerStrip extends StatelessWidget {
  const InAppBannerStrip({
    super.key,
    required this.controller,
    required this.surface,
    this.padding,
    this.onAction,
  });

  final InAppMessagingController controller;
  final MessageSurface surface;
  final EdgeInsetsGeometry? padding;
  final InAppBannerActionCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<InAppBannerDefinition>>(
      valueListenable: controller.bannersFor(surface),
      builder: (context, banners, _) {
        if (banners.isEmpty) {
          return const SizedBox.shrink();
        }
        final effectivePadding = padding ?? const EdgeInsets.symmetric(horizontal: 16);
        final children = <Widget>[];
        for (final banner in banners) {
          children
            ..add(
              _InAppBannerCard(
                banner: banner,
                onDismissed: () => controller.dismissBanner(banner.id),
                onAction: () {
                  final route = controller.handleBannerAction(banner.id);
                  onAction?.call(banner, route);
                },
              ),
            )
            ..add(const SizedBox(height: 12));
        }
        children.removeLast();
        return Padding(
          padding: effectivePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        );
      },
    );
  }
}

class _InAppBannerCard extends StatelessWidget {
  const _InAppBannerCard({
    required this.banner,
    required this.onDismissed,
    required this.onAction,
  });

  final InAppBannerDefinition banner;
  final VoidCallback onDismissed;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final palette = _tonePalette(colorScheme, banner.tone);
    final textTheme = theme.textTheme;
    final actionLabel = banner.actionLabelKey != null ? context.tr(banner.actionLabelKey!) : null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette.accent.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(palette.icon, color: palette.accent, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr(banner.titleKey),
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: palette.foreground,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  context.tr(banner.messageKey),
                  style: textTheme.bodyMedium?.copyWith(color: palette.foreground.withOpacity(0.85)),
                ),
                if (actionLabel != null) ...[
                  const SizedBox(height: 12),
                  FilledButton.tonal(
                    onPressed: onAction,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Text(actionLabel),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: onDismissed,
            icon: const Icon(Icons.close_rounded),
            tooltip: context.tr('banner_close'),
          ),
        ],
      ),
    );
  }

  _BannerPalette _tonePalette(ColorScheme scheme, InAppBannerTone tone) {
    switch (tone) {
      case InAppBannerTone.positive:
        return _BannerPalette(
          background: scheme.secondaryContainer,
          foreground: scheme.onSecondaryContainer,
          accent: scheme.secondary,
          icon: Icons.eco_rounded,
        );
      case InAppBannerTone.warning:
        return _BannerPalette(
          background: scheme.errorContainer,
          foreground: scheme.onErrorContainer,
          accent: scheme.error,
          icon: Icons.warning_amber_rounded,
        );
      case InAppBannerTone.info:
      default:
        return _BannerPalette(
          background: scheme.primaryContainer,
          foreground: scheme.onPrimaryContainer,
          accent: scheme.primary,
          icon: Icons.local_fire_department_rounded,
        );
    }
  }
}

class _BannerPalette {
  const _BannerPalette({
    required this.background,
    required this.foreground,
    required this.accent,
    required this.icon,
  });

  final Color background;
  final Color foreground;
  final Color accent;
  final IconData icon;
}
