import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/locale/localization_extension.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = List<int>.generate(6, (index) => index);
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          centerTitle: false,
          title: Text(context.tr('menu_title')),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final delay = Duration(milliseconds: 120 * index);
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text('${context.tr('sample_item')} #${items[index] + 1}'),
                    subtitle: Text(context.tr('menu_placeholder_desc')),
                    trailing: ElevatedButton(
                      onPressed: () {},
                      child: Text(context.tr('action_add_cart')),
                    ),
                  ),
                )
                    .animate(delay: delay)
                    .fadeIn(duration: 400.ms)
                    .moveY(begin: 30, end: 0, curve: Curves.easeOut);
              },
              childCount: items.length,
            ),
          ),
        ),
      ],
    );
  }
}
