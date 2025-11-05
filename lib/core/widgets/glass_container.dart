import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/tokens.dart';

class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = AppRadii.lgAll,
    this.padding,
    this.backgroundColor,
    this.borderColor,
    this.blurSigma = 16,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final double blurSigma;

  @override
  Widget build(BuildContext context) {
    final palette = AppColors.of(Theme.of(context).brightness);
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          decoration: BoxDecoration(
            color: (backgroundColor ?? palette.surface.withOpacity(0.9)),
            borderRadius: borderRadius,
            border: Border.all(color: borderColor ?? palette.border.withOpacity(0.6)),
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
