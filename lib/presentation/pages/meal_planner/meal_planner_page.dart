import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/locale/localization_extension.dart';
import '../../../domain/models/food_item.dart';
import '../../../domain/models/meal_plan.dart';
import '../../controllers/meal_planner_controller.dart';

class MealPlannerPage extends StatefulWidget {
  const MealPlannerPage({super.key});

  static const String routeName = '/meal-planner';

  @override
  State<MealPlannerPage> createState() => _MealPlannerPageState();
}

class _MealPlannerPageState extends State<MealPlannerPage> {
  MealPlannerController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = MealPlannerScope.of(context);
    if (!identical(controller, _controller)) {
      _controller = controller;
      if (!controller.isInitialized) {
        controller.initialize();
      }
    }
  }

  Future<void> _confirmReset() async {
    final controller = _controller;
    if (controller == null || controller.isEmpty) {
      return;
    }
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(context.tr('meal_planner_reset_title')),
          content: Text(context.tr('meal_planner_reset_message')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(context.tr('meal_planner_reset_cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(context.tr('meal_planner_reset_confirm')),
            ),
          ],
        );
      },
    );
    if (shouldReset == true) {
      await controller.clear();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('meal_planner_reset_success'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('meal_planner_title')),
        actions: [
          IconButton(
            onPressed: controller.isEmpty ? null : _confirmReset,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: context.tr('meal_planner_reset_tooltip'),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('meal_planner_intro_title'),
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  context.tr('meal_planner_intro_subtitle'),
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  context.tr('meal_planner_drag_hint'),
                  style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 140,
            child: ValueListenableBuilder<List<FoodItem>>(
              valueListenable: controller.availableItems,
              builder: (context, items, _) {
                if (items.isEmpty) {
                  return const SizedBox.shrink();
                }
                return ListView.separated(
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 8),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _AvailableMealItemChip(item: item);
                  },
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemCount: items.length,
                );
              },
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<Map<MealDay, List<MealPlanEntry>>>(
              valueListenable: controller.days,
              builder: (context, plan, _) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: MealDay.values
                        .map(
                          (day) => _MealPlannerColumn(
                            day: day,
                            entries: plan[day] ?? const <MealPlanEntry>[],
                            controller: controller,
                          ),
                        )
                        .toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AvailableMealItemChip extends StatelessWidget {
  const _AvailableMealItemChip({required this.item});

  final FoodItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final card = Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            item.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text('${item.kcal} kcal', style: theme.textTheme.bodySmall),
          const SizedBox(height: 6),
          Wrap(
            spacing: 4,
            runSpacing: 2,
            children: item.tags.take(3).map((tag) {
              return Chip(
                label: Text(tag),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
              );
            }).toList(),
          ),
        ],
      ),
    );

    return LongPressDraggable<MealDragData>(
      data: MealDragData.available(item: item),
      dragAnchorStrategy: pointerDragAnchorStrategy,
      feedback: Material(
        color: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 160),
          child: card,
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.35, child: card),
      child: card,
    );
  }
}

class _MealPlannerColumn extends StatelessWidget {
  const _MealPlannerColumn({
    required this.day,
    required this.entries,
    required this.controller,
  });

  final MealDay day;
  final List<MealPlanEntry> entries;
  final MealPlannerController controller;

  String _label(BuildContext context) {
    switch (day) {
      case MealDay.monday:
        return context.tr('meal_day_monday');
      case MealDay.tuesday:
        return context.tr('meal_day_tuesday');
      case MealDay.wednesday:
        return context.tr('meal_day_wednesday');
      case MealDay.thursday:
        return context.tr('meal_day_thursday');
      case MealDay.friday:
        return context.tr('meal_day_friday');
      case MealDay.saturday:
        return context.tr('meal_day_saturday');
      case MealDay.sunday:
        return context.tr('meal_day_sunday');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final calories = controller.caloriesFor(day);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: DragTarget<MealDragData>(
        onWillAccept: (_) => true,
        onAccept: (data) {
          if (data.isFromPlan) {
            controller.moveItem(
              fromDay: data.sourceDay!,
              fromIndex: data.sourceIndex!,
              toDay: day,
            );
          } else {
            controller.addItem(day, data.item);
          }
        },
        builder: (context, candidate, rejected) {
          final highlight = candidate.isNotEmpty;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 180,
            height: 420,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: highlight
                  ? colorScheme.primary.withOpacity(0.08)
                  : colorScheme.surfaceVariant.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: highlight
                    ? colorScheme.primary
                    : colorScheme.outlineVariant.withOpacity(0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _label(context),
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  context.tr('meal_planner_day_calories', params: <String, dynamic>{'kcal': calories}),
                  style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: entries.isEmpty
                      ? Center(
                          child: Text(
                            context.tr('meal_planner_empty_day'),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.zero,
                          physics: const BouncingScrollPhysics(),
                          itemCount: entries.length,
                          itemBuilder: (context, index) {
                            final entry = entries[index];
                            final item = controller.itemById(entry.itemId);
                            if (item == null) {
                              return const SizedBox.shrink();
                            }
                            return _MealPlanEntryCard(
                              day: day,
                              index: index,
                              item: item,
                              controller: controller,
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MealPlanEntryCard extends StatelessWidget {
  const _MealPlanEntryCard({
    required this.day,
    required this.index,
    required this.item,
    required this.controller,
  });

  final MealDay day;
  final int index;
  final FoodItem item;
  final MealPlannerController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final card = Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        title: Text(item.name, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text('${item.kcal} kcal'),
        trailing: IconButton(
          icon: const Icon(Icons.close_rounded),
          tooltip: context.tr('meal_planner_remove_tooltip'),
          onPressed: () => controller.removeItem(day, index),
        ),
      ),
    );

    return LongPressDraggable<MealDragData>(
      data: MealDragData.fromPlan(item: item, sourceDay: day, sourceIndex: index),
      dragAnchorStrategy: pointerDragAnchorStrategy,
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(width: 200, child: card),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: card),
      child: card.animate().fadeIn(duration: const Duration(milliseconds: 220)).slideY(begin: 0.1, end: 0),
    );
  }
}
