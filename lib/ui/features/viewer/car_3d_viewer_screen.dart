import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../data/models/car_item.dart';
import '../../../data/repositories_local/car_repository_local.dart';

class Car3DViewerScreen extends StatefulWidget {
  const Car3DViewerScreen({super.key, this.carId});

  final String? carId;

  @override
  State<Car3DViewerScreen> createState() => _Car3DViewerScreenState();
}

class _Car3DViewerScreenState extends State<Car3DViewerScreen> {
  final CarRepositoryLocal _repository = CarRepositoryLocal();
  final TransformationController _transformController = TransformationController();
  late final Flutter3DController _controller;

  CarItem? _car;
  bool _loading = true;
  bool _autoRotate = false;
  bool _lightOn = true;
  double _zoom = 1.0;

  @override
  void initState() {
    super.initState();
    _controller = Flutter3DController();
    _load();
  }

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (widget.carId != null) {
      final car = await _repository.getById(widget.carId!);
      setState(() {
        _car = car;
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  void _resetView() {
    _controller.reset();
    _transformController.value = Matrix4.identity();
    setState(() {
      _autoRotate = false;
      _zoom = 1.0;
    });
  }

  void _toggleAutoRotate() {
    setState(() {
      _autoRotate = !_autoRotate;
    });
    if (_autoRotate) {
      _controller.startAutoRotate();
    } else {
      _controller.stopAutoRotate();
    }
  }

  void _updateZoom(double value) {
    setState(() => _zoom = value);
    _transformController.value = Matrix4.identity()..scale(value);
  }

  void _toggleLight() {
    setState(() => _lightOn = !_lightOn);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_car?.nameEn ?? loc.translate('viewerTitle')),
      ),
      body: _loading
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 12),
                  Text(loc.translate('viewerLoading')),
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: RepaintBoundary(
                      child: InteractiveViewer(
                        transformationController: _transformController,
                        minScale: 0.6,
                        maxScale: 2.5,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
                            boxShadow: [
                              if (_lightOn)
                                BoxShadow(
                                  color: theme.colorScheme.primary.withOpacity(0.15),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: _car?.model3DUrl != null
                                ? Flutter3DViewer(
                                    controller: _controller,
                                    src: _car!.model3DUrl!,
                                  )
                                : _PlaceholderCube(
                                    label: loc.translate('viewerPlaceholder'),
                                    isLit: _lightOn,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(loc.translate('viewerControls'), style: theme.textTheme.titleMedium),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Tooltip(
                            message: loc.translate('viewerReset'),
                            child: IconButton(onPressed: _resetView, icon: const Icon(Icons.refresh)),
                          ),
                          Tooltip(
                            message: _autoRotate ? loc.translate('viewerPause') : loc.translate('viewerRotate'),
                            child: IconButton(
                              onPressed: _toggleAutoRotate,
                              icon: Icon(_autoRotate ? Icons.pause : Icons.play_arrow),
                            ),
                          ),
                          Tooltip(
                            message: loc.translate('viewerLighting'),
                            child: IconButton(
                              onPressed: _toggleLight,
                              icon: Icon(_lightOn ? Icons.light_mode : Icons.lightbulb_outline),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(loc.translate('viewerZoom')),
                      Slider(
                        value: _zoom,
                        onChanged: _updateZoom,
                        min: 0.6,
                        max: 2.0,
                      ),
                      const SizedBox(height: 8),
                      if (_car?.model3DUrl == null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            loc.translate('viewerNoModel'),
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      Text(
                        loc.translate('viewerPanHint'),
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _PlaceholderCube extends StatelessWidget {
  const _PlaceholderCube({required this.label, required this.isLit});

  final String label;
  final bool isLit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isLit
              ? [theme.colorScheme.primary.withOpacity(0.6), theme.colorScheme.primaryContainer.withOpacity(0.6)]
              : [theme.colorScheme.surfaceVariant, theme.colorScheme.surface],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.view_in_ar, size: 64, color: theme.colorScheme.onSurface.withOpacity(0.7)),
            const SizedBox(height: 12),
            Text(label, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
