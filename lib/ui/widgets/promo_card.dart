
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/theme/tokens.dart';
import 'glass/glass_container.dart';

class PromoCard extends StatefulWidget {
  const PromoCard({required this.onDismissed, super.key});

  final VoidCallback onDismissed;

  @override
  State<PromoCard> createState() => _PromoCardState();
}

class _PromoCardState extends State<PromoCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: AppTokens.motion.normal);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDismiss() {
    if (_dismissed) return;
    setState(() => _dismissed = true);
    _controller.forward().then((_) => widget.onDismissed());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SizeTransition(
      sizeFactor: Tween<double>(begin: 1, end: 0).animate(CurvedAnimation(parent: _controller, curve: AppTokens.motion.curve)),
      axisAlignment: -1,
      child: FadeTransition(
        opacity: Tween<double>(begin: 1, end: 0).animate(_controller),
        child: CustomPaint(
          painter: _DashedBorderPainter(color: colorScheme.outline),
          child: GlassContainer(
            borderRadius: AppTokens.radius.lg,
            padding: EdgeInsets.all(AppTokens.spacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.14),
                    borderRadius: AppTokens.radius.md,
                  ),
                  padding: EdgeInsets.all(AppTokens.spacing.sm),
                  child: Icon(IconlyBold.wallet, color: colorScheme.primary, size: 24),
                ),
                SizedBox(width: AppTokens.spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Get $600!', style: textTheme.titleLarge),
                      SizedBox(height: AppTokens.spacing.xs),
                      Text(
                        "Tell your friends about us. We'll thank you with up to $600.",
                        style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.72)),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: _handleDismiss,
                  child: Container(
                    height: 32,
                    width: 32,
                    decoration: BoxDecoration(
                      borderRadius: AppTokens.radius.sm,
                      color: colorScheme.surface.withOpacity(0.5),
                    ),
                    child: Icon(IconlyLight.close_square, size: 18, color: colorScheme.onSurface.withOpacity(0.6)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..color = color.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    const dashWidth = 6.0;
    const dashSpace = 6.0;
    final rrect = RRect.fromRectAndRadius(rect.deflate(1), const Radius.circular(20));
    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) => oldDelegate.color != color;
}
