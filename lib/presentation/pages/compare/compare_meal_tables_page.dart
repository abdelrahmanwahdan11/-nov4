import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/locale/localization_extension.dart';
import '../../../domain/models/meal_table.dart';
import '../../controllers/meal_table_compare_controller.dart';
import '../../widgets/meal_table_compare_card.dart';

class CompareMealTablesPage extends StatefulWidget {
  const CompareMealTablesPage({super.key});

  static const routeName = '/compare/tables';

  @override
  State<CompareMealTablesPage> createState() => _CompareMealTablesPageState();
}

class _CompareMealTablesPageState extends State<CompareMealTablesPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  MealTableCompareController? _controller;
  bool _requestedLoad = false;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller ??= MealTableCompareScope.of(context);
    if (!_requestedLoad) {
      _requestedLoad = true;
      _controller?.load();
    }
  }

  void _onSearchChanged(String value) {
    _controller?.updateSearch(value);
  }

  void _toggleMealType(String mealType) {
    _controller?.toggleMealType(mealType);
  }

  void _toggleRegion(String region) {
    _controller?.toggleRegion(region);
  }

  void _toggleTable(MealTable table) {
    _controller?.toggleSelection(table);
  }

  void _setFocus(MealTable table) {
    _controller?.setFocus(table);
  }

  Widget _buildSearchField(BuildContext context) {
    return TextField(
      controller: _searchController,
      focusNode: _searchFocus,
      decoration: InputDecoration(
        hintText: context.tr('compare_tables_search_hint'),
        prefixIcon: const Icon(Icons.search),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
      ),
      textInputAction: TextInputAction.search,
      onChanged: _onSearchChanged,
    );
  }

  Widget _buildFilterChips(
    BuildContext context,
    List<String> values,
    Set<String> active,
    void Function(String value) onToggle,
  ) {
    if (values.isEmpty) {
      return const SizedBox.shrink();
    }
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: values
          .map(
            (value) => FilterChip(
              label: Text(value),
              selected: active.contains(value),
              onSelected: (_) => onToggle(value),
            ),
          )
          .toList(),
    );
  }

  Widget _buildSelectionHeader(BuildContext context, List<MealTable> selected) {
    if (selected.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(
          context.tr('compare_tables_selection_empty'),
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.tr('compare_tables_selected_title'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              context.tr('compare_tables_selected_hint'),
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: selected
              .map(
                (table) => GestureDetector(
                  onTap: () => _setFocus(table),
                  child: Chip(
                    avatar: CircleAvatar(
                      backgroundImage: NetworkImage(table.imageUrl),
                      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                    ),
                    label: Text(table.displayName),
                    deleteIcon: const Icon(Icons.close),
                    onDeleted: () => _toggleTable(table),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildStatTable(BuildContext context, MealTableCompareController controller) {
    return ValueListenableBuilder<List<MealTable>>(
      valueListenable: controller.selectedTables,
      builder: (context, selected, _) {
        if (selected.length < 2) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              context.tr('compare_tables_specs_placeholder'),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          );
        }
        final statKeys = controller.buildStatKeys();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('compare_tables_specs_title'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(12),
              child: Table(
                columnWidths: const <int, TableColumnWidth>{
                  0: IntrinsicColumnWidth(),
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  TableRow(
                    children: [
                      const SizedBox.shrink(),
                      ...selected.map(
                        (table) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                          child: Text(
                            table.displayName,
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ),
                      ),
                    ],
                  ),
                  ...statKeys.map((stat) {
                    final highlight = controller.hasDifference(stat);
                    final rowColor = highlight
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.08)
                        : Colors.transparent;
                    final label = context.tr('compare_tables_stat_$stat');
                    return TableRow(
                      decoration: BoxDecoration(color: rowColor),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          child: Text(
                            label,
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        ...selected.map(
                          (table) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                            child: Text(table.stats[stat] ?? '-'),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ).animate().fadeIn(duration: const Duration(milliseconds: 320)),
          ],
        );
      },
    );
  }

  Widget _buildFocusCard(BuildContext context, MealTableCompareController controller) {
    return ValueListenableBuilder<MealTable?>(
      valueListenable: controller.focusTable,
      builder: (context, table, _) {
        if (table == null) {
          return Container(
            height: 220,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(24),
            ),
            alignment: Alignment.center,
            child: Text(context.tr('compare_tables_focus_placeholder')),
          );
        }
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          child: Container(
            key: ValueKey<String>(table.id),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              image: DecorationImage(
                image: NetworkImage(table.imageUrl),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.25),
                  BlendMode.darken,
                ),
              ),
            ),
            padding: const EdgeInsets.all(20),
            height: 260,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  table.displayName,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  table.description,
                  style:
                      Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                ),
                const Spacer(),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: table.highlights
                      .map(
                        (dish) => Chip(
                          label: Text(dish),
                          backgroundColor: Colors.white.withOpacity(0.85),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(duration: const Duration(milliseconds: 240));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('compare_tables_title')),
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return ValueListenableBuilder<bool>(
            valueListenable: controller.isLoading,
            builder: (context, isLoading, child) {
              return CustomScrollView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                      child: _buildSearchField(context),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ValueListenableBuilder<List<String>>(
                            valueListenable: controller.availableMealTypes,
                            builder: (context, mealTypes, _) {
                              if (mealTypes.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              return ValueListenableBuilder<Set<String>>(
                                valueListenable: controller.activeMealTypes,
                                builder: (context, active, __) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        context.tr('compare_tables_filter_meal_type'),
                                        style: theme.textTheme.titleSmall,
                                      ),
                                      const SizedBox(height: 12),
                                      _buildFilterChips(context, mealTypes, active, _toggleMealType),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          ValueListenableBuilder<List<String>>(
                            valueListenable: controller.availableRegions,
                            builder: (context, regions, _) {
                              if (regions.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              return ValueListenableBuilder<Set<String>>(
                                valueListenable: controller.activeRegions,
                                builder: (context, active, __) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        context.tr('compare_tables_filter_region'),
                                        style: theme.textTheme.titleSmall,
                                      ),
                                      const SizedBox(height: 12),
                                      _buildFilterChips(context, regions, active, _toggleRegion),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: ValueListenableBuilder<List<MealTable>>(
                        valueListenable: controller.selectedTables,
                        builder: (context, selected, _) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSelectionHeader(context, selected),
                              const SizedBox(height: 16),
                              _buildFocusCard(context, controller),
                              const SizedBox(height: 24),
                              _buildStatTable(context, controller),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  if (isLoading)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                        ),
                      ),
                    )
                  else
                    ValueListenableBuilder<List<MealTable>>(
                      valueListenable: controller.filteredTables,
                      builder: (context, tables, _) {
                        if (tables.isEmpty) {
                          return SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Text(
                                context.tr('compare_tables_empty'),
                                style: theme.textTheme.bodyLarge,
                              ),
                            ),
                          );
                        }
                        return SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                          sliver: SliverToBoxAdapter(
                            child: ValueListenableBuilder<List<MealTable>>(
                              valueListenable: controller.selectedTables,
                              builder: (context, selectedTables, __) {
                                return GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 16,
                                    crossAxisSpacing: 16,
                                    childAspectRatio: 0.78,
                                  ),
                                  itemCount: tables.length,
                                  itemBuilder: (context, index) {
                                    final table = tables[index];
                                    final isSelected =
                                        selectedTables.any((item) => item.id == table.id);
                                    final actionLabel = isSelected
                                        ? context.tr('compare_tables_remove')
                                        : context.tr('compare_tables_add');
                                    return MealTableCompareCard(
                                      table: table,
                                      isSelected: isSelected,
                                      onToggle: () {
                                        _toggleTable(table);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              '${context.tr('compare_tables_snackbar')} ${table.displayName}',
                                            ),
                                            duration: const Duration(seconds: 2),
                                          ),
                                        );
                                      },
                                      onPreview: () => _setFocus(table),
                                      primaryActionLabel: actionLabel,
                                      previewTooltip: context.tr('compare_tables_preview_tooltip'),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
