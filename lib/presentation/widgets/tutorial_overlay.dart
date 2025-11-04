import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/locale/localization_extension.dart';
import '../controllers/tutorial_controller.dart';

class TutorialOverlay extends StatefulWidget {
  const TutorialOverlay({super.key, required this.child});

  final Widget child;

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay>
    with SingleTickerProviderStateMixin {
  final GlobalKey _overlayKey = GlobalKey();
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Rect? _rectFor(TutorialController controller, TutorialTarget target) {
    final anchorKey = controller.anchorOf(target);
    if (anchorKey == null) {
      return null;
    }
    final anchorContext = anchorKey.currentContext;
    final overlayContext = _overlayKey.currentContext;
    if (anchorContext == null || overlayContext == null) {
      return null;
    }
    final renderObject = anchorContext.findRenderObject();
    final overlayObject = overlayContext.findRenderObject();
    if (renderObject is! RenderBox || overlayObject is! RenderBox) {
      return null;
    }
    final offset =
        renderObject.localToGlobal(Offset.zero, ancestor: overlayObject);
    final size = renderObject.size;
    return Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height);
  }

  @override
  Widget build(BuildContext context) {
    final tutorial = TutorialScope.maybeOf(context);
    if (tutorial == null) {
      return widget.child;
    }

    return Stack(
      key: _overlayKey,
      children: [
        widget.child,
        AnimatedBuilder(
          animation: tutorial,
          builder: (context, _) {
            return ValueListenableBuilder<TutorialTarget?>(
              valueListenable: tutorial.currentTarget,
              builder: (context, target, __) {
                final bool isActive = tutorial.isActive && target != null;
                if (!isActive) {
                  if (_pulseController.isAnimating) {
                    _pulseController.stop();
                  }
                  return const SizedBox.shrink();
                }
                if (!_pulseController.isAnimating) {
                  _pulseController.repeat(reverse: true);
                }
                final rect = _rectFor(tutorial, target!);
                return AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, __) {
                    return _TutorialOverlayLayer(
                      rect: rect,
                      target: target,
                      controller: tutorial,
                      pulseValue: _pulseController.value,
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _TutorialOverlayLayer extends StatelessWidget {
  const _TutorialOverlayLayer({
    required this.rect,
    required this.target,
    required this.controller,
    required this.pulseValue,
  });

  final Rect? rect;
  final TutorialTarget target;
  final TutorialController controller;
  final double pulseValue;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    final padding = mediaQuery.padding;
    final Rect highlightRect = rect ??
        Rect.fromCenter(
          center: Offset(size.width / 2, size.height / 2),
          width: math.min(size.width * 0.6, 240),
          height: 140,
        );
    final bool placeAbove = highlightRect.center.dy > size.height / 2;
    final double tooltipWidth = math.min(size.width - 32, 320);
    const double estimatedHeight = 190;

    double top;
    if (placeAbove) {
      top = highlightRect.top - 16 - estimatedHeight;
      top = math.max(top, padding.top + 16);
    } else {
      top = highlightRect.bottom + 16;
      final double limit = size.height - estimatedHeight - 16;
      if (top > limit) {
        top = math.max(padding.top + 16, limit);
      }
    }
    final double left = math.max(
      16,
      math.min(
        highlightRect.center.dx - tooltipWidth / 2,
        size.width - tooltipWidth - 16,
      ),
    );

    final int totalSteps = controller.sequence.length;
    final int targetIndex = controller.sequence.indexOf(target);
    final int currentIndex = (targetIndex >= 0 ? targetIndex : 0) + 1;
    final String progressTemplate = context.tr('tutorial_progress');
    final String progress = progressTemplate
        .replaceAll('{current}', currentIndex.toString())
        .replaceAll('{total}', totalSteps.toString());
    final bool isLastStep = currentIndex >= totalSteps;

    return Positioned.fill(
      child: Stack(
        children: [
          GestureDetector(
            onTap: controller.next,
            behavior: HitTestBehavior.opaque,
            child: CustomPaint(
              painter: _TutorialHighlightPainter(
                rect: highlightRect,
                pulseValue: pulseValue,
              ),
            ),
          ),
          Positioned(
            top: math.max(padding.top + 12, 0),
            right: 16,
            child: TextButton(
              onPressed: controller.skip,
              child: Text(context.tr('tutorial_skip')),
            ),
          ),
          Positioned(
            top: top,
            left: left,
            width: tooltipWidth,
            child: _TutorialTooltip(
              title: _titleForTarget(context, target),
              description: _descriptionForTarget(context, target),
              progress: progress,
              isLastStep: isLastStep,
              onNext: controller.next,
            ),
          ),
        ],
      ),
    );
  }

  String _titleForTarget(BuildContext context, TutorialTarget target) {
    switch (target) {
      case TutorialTarget.searchBar:
        return context.tr('tutorial_search_title');
      case TutorialTarget.addToCart:
        return context.tr('tutorial_add_title');
      case TutorialTarget.darkToggle:
        return context.tr('tutorial_dark_title');
      case TutorialTarget.colorPicker:
        return context.tr('tutorial_color_title');
    }
  }

  String _descriptionForTarget(BuildContext context, TutorialTarget target) {
    switch (target) {
      case TutorialTarget.searchBar:
        return context.tr('tutorial_search_body');
      case TutorialTarget.addToCart:
        return context.tr('tutorial_add_body');
      case TutorialTarget.darkToggle:
        return context.tr('tutorial_dark_body');
      case TutorialTarget.colorPicker:
        return context.tr('tutorial_color_body');
    }
  }
}

class _TutorialTooltip extends StatelessWidget {
  const _TutorialTooltip({
    required this.title,
    required this.description,
    required this.progress,
    required this.isLastStep,
    required this.onNext,
  });

  final String title;
  final String description;
  final String progress;
  final bool isLastStep;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              progress,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: FilledButton(
                onPressed: onNext,
                child: Text(
                  isLastStep
                      ? context.tr('tutorial_done')
                      : context.tr('tutorial_next'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TutorialHighlightPainter extends CustomPainter {
  const _TutorialHighlightPainter({
    required this.rect,
    required this.pulseValue,
  });

  final Rect rect;
  final double pulseValue;

  @override
  void paint(Canvas canvas, Size size) {
    final overlayPath = Path()..addRect(Offset.zero & size);
    final double padding = 20 + 6 * (1 - pulseValue);
    final RRect highlight = RRect.fromRectAndRadius(
      rect.inflate(padding),
      const Radius.circular(32),
    );
    final highlightPath = Path()..addRRect(highlight);

    final Paint dimPaint = Paint()..color = Colors.black.withOpacity(0.65);
    final Path dimmed =
        Path.combine(PathOperation.difference, overlayPath, highlightPath);
    canvas.drawPath(dimmed, dimPaint);

    final Paint borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5 + pulseValue * 2
      ..color = Colors.white.withOpacity(0.45 + (1 - pulseValue) * 0.25);
    canvas.drawRRect(highlight, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _TutorialHighlightPainter oldDelegate) {
    return oldDelegate.rect != rect ||
        oldDelegate.pulseValue != pulseValue;
  }
}

class TutorialTargetAnchor extends StatefulWidget {
  const TutorialTargetAnchor({
    super.key,
    required this.target,
    required this.child,
  });

  final TutorialTarget target;
  final Widget child;

  @override
  State<TutorialTargetAnchor> createState() => _TutorialTargetAnchorState();
}

class _TutorialTargetAnchorState extends State<TutorialTargetAnchor> {
  final GlobalKey _anchorKey = GlobalKey();
  TutorialController? _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _registerAnchor();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newController = TutorialScope.maybeOf(context);
    if (!identical(newController, _controller)) {
      _unregisterAnchor();
      _controller = newController;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _registerAnchor();
      });
    }
  }

  @override
  void didUpdateWidget(covariant TutorialTargetAnchor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.target != widget.target) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _unregisterAnchor(target: oldWidget.target);
        _registerAnchor();
      });
    }
  }

  void _registerAnchor() {
    final controller = _controller;
    if (!mounted || controller == null) {
      return;
    }
    controller.registerAnchor(widget.target, _anchorKey);
  }

  void _unregisterAnchor({TutorialTarget? target}) {
    final controller = _controller;
    if (controller == null) {
      return;
    }
    controller.unregisterAnchor(target ?? widget.target, _anchorKey);
  }

  @override
  void dispose() {
    _unregisterAnchor();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: _anchorKey,
      child: widget.child,
    );
  }
}
