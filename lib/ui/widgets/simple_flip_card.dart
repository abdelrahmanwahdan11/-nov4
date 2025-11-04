import 'package:flutter/material.dart';

class FlipCard extends StatefulWidget {
  const FlipCard({
    super.key,
    required this.front,
    required this.back,
    this.flipOnTouch = true,
    this.duration = const Duration(milliseconds: 400),
  });

  final Widget front;
  final Widget back;
  final bool flipOnTouch;
  final Duration duration;

  @override
  State<FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  bool _showFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleCard() {
    if (_showFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() {
      _showFront = !_showFront;
    });
  }

  @override
  Widget build(BuildContext context) {
    final child = AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final angle = _animation.value * 3.141592653589793;
        final isUnder = angle > 1.5708;
        final displayChild = isUnder ? widget.back : widget.front;
        final adjustedAngle = isUnder ? angle - 3.141592653589793 : angle;
        return Transform(
          transform: Matrix4.rotationY(adjustedAngle),
          alignment: Alignment.center,
          child: displayChild,
        );
      },
    );

    if (!widget.flipOnTouch) {
      return child;
    }

    return GestureDetector(
      onTap: _toggleCard,
      child: child,
    );
  }
}
