import 'package:flutter/material.dart';

class Flutter3DController {
  void reset() {}
  void startAutoRotate() {}
  void stopAutoRotate() {}
}

class Flutter3DViewer extends StatelessWidget {
  const Flutter3DViewer({
    super.key,
    required this.controller,
    required this.src,
  });

  final Flutter3DController controller;
  final String src;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceVariant,
      alignment: Alignment.center,
      child: Text(
        '3D preview unavailable',
        style: Theme.of(context).textTheme.bodyMedium,
        textAlign: TextAlign.center,
      ),
    );
  }
}
