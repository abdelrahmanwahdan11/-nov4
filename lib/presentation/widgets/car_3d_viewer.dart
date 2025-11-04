import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';

class Car3DViewer extends StatefulWidget {
  const Car3DViewer({
    super.key,
    required this.assetPath,
    required this.onReset,
  });

  final String assetPath;
  final VoidCallback onReset;

  @override
  State<Car3DViewer> createState() => _Car3DViewerState();
}

class _Car3DViewerState extends State<Car3DViewer> {
  late final Flutter3DController _controller;
  double _rotation = 0;
  double _zoom = 1;
  double _lastScale = 1;

  @override
  void initState() {
    super.initState();
    _controller = Flutter3DController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleHorizontalDrag(DragUpdateDetails details) {
    setState(() {
      _rotation += details.delta.dx * 0.01;
      (_controller as dynamic).setModelRotation(y: _rotation);
    });
  }

  void _handleScale(double scale) {
    setState(() {
      _zoom = (_zoom * scale).clamp(0.6, 2.4);
      (_controller as dynamic).setModelScale(scale: _zoom);
    });
  }

  void _reset() {
    setState(() {
      _rotation = 0;
      _zoom = 1;
      _lastScale = 1;
    });
    (_controller as dynamic).reset();
    widget.onReset();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        children: [
          ColoredBox(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.28),
            child: GestureDetector(
              onHorizontalDragUpdate: _handleHorizontalDrag,
              onScaleStart: (details) {
                _lastScale = 1;
              },
              onScaleUpdate: (details) {
                if (details.scale == 1) {
                  return;
                }
                final delta = details.scale / _lastScale;
                _lastScale = details.scale;
                if (delta == 0) {
                  return;
                }
                _handleScale(delta);
              },
              onDoubleTap: _reset,
              child: Flutter3DViewer.asset(
                src: widget.assetPath,
                controller: _controller,
              ),
            ),
          ),
          Positioned(
            right: 16,
            top: 16,
            child: Column(
              children: [
                _ZoomButton(icon: Icons.zoom_in, onPressed: () => _handleScale(1.1)),
                const SizedBox(height: 12),
                _ZoomButton(icon: Icons.zoom_out, onPressed: () => _handleScale(0.9)),
                const SizedBox(height: 12),
                _ZoomButton(icon: Icons.refresh, onPressed: _reset),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ZoomButton extends StatelessWidget {
  const _ZoomButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black45,
      shape: const CircleBorder(),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
      ),
    );
  }
}
