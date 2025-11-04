import 'package:flutter/material.dart';

import 'skeleton_base.dart';

class SkeletonList extends StatelessWidget {
  const SkeletonList({super.key, this.count = 6, this.height = 80});

  final int count;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (_, __) => SkeletonBase(height: height),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: count,
    );
  }
}
