import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';

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
  CarItem? _car;
  bool _loading = true;
  late Flutter3DController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Flutter3DController();
    _load();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_car?.nameEn ?? '3D Viewer')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: _car?.model3DUrl != null
                      ? Flutter3DViewer(
                          controller: _controller,
                          src: _car!.model3DUrl!,
                        )
                      : Center(
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              border: Border.all(color: Theme.of(context).colorScheme.primary),
                            ),
                            child: const Center(child: Text('3D model placeholder')),
                          ),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(onPressed: () => _controller.reset(), icon: const Icon(Icons.refresh)),
                      IconButton(onPressed: () => _controller.startAutoRotate(), icon: const Icon(Icons.play_arrow)),
                      IconButton(onPressed: () => _controller.stopAutoRotate(), icon: const Icon(Icons.pause)),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
