import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/locale/localization_extension.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/local/food_local_data_source.dart';
import '../../../domain/models/food_item.dart';
import '../../controllers/app_controller.dart';
import '../../controllers/content_status.dart';
import '../../controllers/search_controller.dart';
import '../../widgets/content_state_view.dart';
import '../../controllers/tutorial_controller.dart';
import '../../widgets/tutorial_overlay.dart';
import '../item/item_details_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  SearchController? _searchController;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    final controller = _searchController;
    if (controller != null) {
      controller.dispose();
      unawaited(controller.disposeAsync());
    }
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _searchController ??= SearchController(
      dataSource: FoodLocalDataSource(),
      connectionOverride: AppScope.of(context).connectionOverride,
    )
      ..initialize();
  }

  void _onQueryChanged(String value) {
    final controller = _searchController;
    if (controller != null) {
      controller.search(value);
    }
  }

  void _openDetails(FoodItem item) {
    Navigator.of(context).pushNamed(ItemDetailsPage.routeName, arguments: item);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = _searchController;
    if (controller == null) {
      return const SizedBox.shrink();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('search_title')),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(72),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: TutorialTargetAnchor(
              target: TutorialTarget.searchBar,
              child: TextField(
                controller: _controller,
                onChanged: _onQueryChanged,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: context.tr('search_hint'),
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = ResponsiveBreakpoints.constrainedBodyWidth(constraints.maxWidth);
          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: ValueListenableBuilder<ContentStatus>(
                valueListenable: controller.status,
                builder: (context, status, _) {
                  if (status == ContentStatus.loading && controller.query.value.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (status == ContentStatus.offline || status == ContentStatus.error) {
                    final titleKey =
                        status == ContentStatus.offline ? 'state_offline_title' : 'state_error_title';
                    final messageKey = status == ContentStatus.offline
                        ? 'state_offline_message'
                        : controller.errorKey.value ?? 'state_error_message';
                    return ContentStateView(
                      icon: status == ContentStatus.offline ? Icons.wifi_off : Icons.warning_rounded,
                      title: context.tr(titleKey),
                      message: context.tr(messageKey),
                      primaryAction: FilledButton(
                        onPressed: () => controller.retry(),
                        child: Text(context.tr('state_try_again')),
                      ),
                    );
                  }
                  return ValueListenableBuilder<bool>(
                    valueListenable: controller.isLoading,
                    builder: (context, loading, _) {
                      return StreamBuilder<List<SearchResult>>(
                        stream: controller.resultsStream,
                        builder: (context, snapshot) {
                          final query = controller.query.value.trim();
                          final results = snapshot.data ?? <SearchResult>[];
                          if (query.isEmpty) {
                            return Center(
                              child: Text(
                                context.tr('search_empty'),
                                style: theme.textTheme.titleMedium,
                              ),
                            );
                          }
                          if (loading && results.isEmpty) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (results.isEmpty) {
                            return ContentStateView(
                              icon: Icons.search_off,
                              title: context.tr('search_no_results'),
                              message: context.tr('state_empty_search_message'),
                              primaryAction: TextButton(
                                onPressed: () {
                                  _controller.clear();
                                  controller.search('');
                                },
                                child: Text(context.tr('state_reset_search')),
                              ),
                            );
                          }
                          return ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: results.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final result = results[index];
                              final item = result.item;
                              return ListTile(
                                onTap: () => _openDetails(item),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                tileColor: theme.colorScheme.surfaceVariant.withOpacity(0.4),
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.network(
                                    item.imageUrl,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                title: RichText(
                                  text: TextSpan(
                                    style: theme.textTheme.titleMedium,
                                    children: _highlightText(
                                      item.name,
                                      query,
                                      theme.textTheme.titleMedium ??
                                          const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                      theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    RichText(
                                      text: TextSpan(
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                                        children: _highlightText(
                                          item.description,
                                          query,
                                          theme.textTheme.bodyMedium ?? const TextStyle(),
                                          theme.colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        ...item.tags.take(3).map((tag) => _buildTagChip(tag, query, theme)),
                                        Text(
                                          '${item.kcal} kcal • \\$${item.defaultSize.priceFor(item).toStringAsFixed(2)}',
                                          style: theme.textTheme.labelMedium,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatMatchedFields(result.matchedFields, context),
                                      style:
                                          theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary),
                                    ),
                                  ],
                                ),
                                trailing: const Icon(Icons.chevron_right),
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  List<TextSpan> _highlightText(String source, String query, TextStyle baseStyle, Color highlightColor) {
    if (query.isEmpty) {
      return [TextSpan(text: source, style: baseStyle)];
    }
    final matches = RegExp(RegExp.escape(query), caseSensitive: false).allMatches(source);
    if (matches.isEmpty) {
      return [TextSpan(text: source, style: baseStyle)];
    }
    int currentIndex = 0;
    final spans = <TextSpan>[];
    for (final match in matches) {
      if (match.start > currentIndex) {
        spans.add(TextSpan(text: source.substring(currentIndex, match.start), style: baseStyle));
      }
      spans.add(
        TextSpan(
          text: source.substring(match.start, match.end),
          style: baseStyle.copyWith(color: highlightColor, fontWeight: FontWeight.w700),
        ),
      );
      currentIndex = match.end;
    }
    if (currentIndex < source.length) {
      spans.add(TextSpan(text: source.substring(currentIndex), style: baseStyle));
    }
    return spans;
  }

  Widget _buildTagChip(String tag, String query, ThemeData theme) {
    final highlight = tag.toLowerCase().contains(query.toLowerCase());
    return Chip(
      label: Text(tag),
      backgroundColor: highlight
          ? theme.colorScheme.primary.withOpacity(0.12)
          : theme.colorScheme.surfaceVariant,
    );
  }

  String _formatMatchedFields(List<String> fields, BuildContext context) {
    if (fields.isEmpty) {
      return '';
    }
    final translated = fields.map((field) {
      switch (field) {
        case 'name':
          return context.tr('field_name');
        case 'description':
          return context.tr('field_description');
        case 'tags':
          return context.tr('field_tags');
        case 'kcal':
          return context.tr('field_kcal');
        case 'price':
          return context.tr('field_price');
        default:
          return field;
      }
    }).toList();
    return '${context.tr('matched_fields')}: ${translated.join(', ')}';
  }
}
