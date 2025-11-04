import 'package:flutter/material.dart';

import '../../../core/locale/localization_extension.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  final ValueNotifier<List<String>> _results = ValueNotifier<List<String>>(<String>[]);

  @override
  void dispose() {
    _controller.dispose();
    _results.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    final query = value.trim();
    if (query.isEmpty) {
      _results.value = const <String>[];
      return;
    }
    _results.value = List<String>.generate(5, (index) => '$query #${index + 1}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('search_title')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              onChanged: _onQueryChanged,
              decoration: InputDecoration(
                hintText: context.tr('search_hint'),
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ValueListenableBuilder<List<String>>(
                valueListenable: _results,
                builder: (context, items, _) {
                  if (items.isEmpty) {
                    return Center(
                      child: Text(context.tr('search_empty')),
                    );
                  }
                  return ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) => ListTile(
                      title: Text(items[index]),
                      subtitle: Text(context.tr('search_result_placeholder')),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
