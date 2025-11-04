import 'package:flutter/material.dart';

class RefreshWrapper extends StatelessWidget {
  const RefreshWrapper({super.key, required this.onRefresh, required this.child});

  final Future<void> Function() onRefresh;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: child,
    );
  }
}
