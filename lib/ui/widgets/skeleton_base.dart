import 'package:flutter/material.dart';

class SkeletonBase extends StatefulWidget {
  const SkeletonBase({super.key, this.height, this.width, this.borderRadius = 12});

  final double? height;
  final double? width;
  final double borderRadius;

  @override
  State<SkeletonBase> createState() => _SkeletonBaseState();
}

class _SkeletonBaseState extends State<SkeletonBase> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Colors.grey.shade300, Colors.grey.shade100, Colors.grey.shade300],
              stops: [0, _controller.value, 1],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: Container(
            height: widget.height,
            width: widget.width,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
          ),
        );
      },
    );
  }
}
