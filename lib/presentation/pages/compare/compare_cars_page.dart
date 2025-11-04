import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/locale/localization_extension.dart';
import '../../../domain/models/car.dart';
import '../../controllers/compare_controller.dart';
import '../../widgets/car_3d_viewer.dart';
import '../../widgets/car_compare_card.dart';

class CompareCarsPage extends StatefulWidget {
  const CompareCarsPage({super.key});

  static const routeName = '/compare/cars';

  @override
  State<CompareCarsPage> createState() => _CompareCarsPageState();
}

class _CompareCarsPageState extends State<CompareCarsPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  CompareController? _controller;
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
    _controller ??= CompareScope.of(context);
    if (!_requestedLoad) {
      _requestedLoad = true;
      _controller?.load();
    }
  }

  void _onSearchChanged(String value) {
    _controller?.updateSearch(value);
  }

  void _toggleBrand(String brand) {
    _controller?.toggleBrand(brand);
  }

  void _toggleCar(Car car) {
    _controller?.toggleSelection(car);
  }

  void _setFocus(Car car) {
    _controller?.setFocus(car);
  }

  Widget _buildSearchField(BuildContext context) {
    return TextField(
      controller: _searchController,
      focusNode: _searchFocus,
      decoration: InputDecoration(
        hintText: context.tr('compare_search_hint'),
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

  Widget _buildBrands(BuildContext context, List<String> brands, Set<String> active) {
    if (brands.isEmpty) {
      return const SizedBox.shrink();
    }
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: brands
          .map(
            (brand) => FilterChip(
              label: Text(brand),
              selected: active.contains(brand),
              onSelected: (_) => _toggleBrand(brand),
            ),
          )
          .toList(),
    );
  }

  Widget _buildSelectionHeader(BuildContext context, List<Car> selected) {
    if (selected.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(
          context.tr('compare_selection_empty'),
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
              context.tr('compare_selected_title'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              context.tr('compare_selected_hint'),
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
                (car) => GestureDetector(
                  onTap: () => _setFocus(car),
                  child: Chip(
                    avatar: CircleAvatar(
                      backgroundImage: NetworkImage(car.imageUrl),
                      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                    ),
                    label: Text(car.displayName),
                    deleteIcon: const Icon(Icons.close),
                    onDeleted: () => _toggleCar(car),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildSpecsTable(BuildContext context, CompareController controller) {
    return ValueListenableBuilder<List<Car>>(
      valueListenable: controller.selectedCars,
      builder: (context, selected, _) {
        if (selected.length < 2) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              context.tr('compare_specs_placeholder'),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          );
        }
        final specKeys = controller.buildSpecKeys();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('compare_specs_title'),
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
                        (car) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                          child: Text(
                            car.displayName,
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ),
                      ),
                    ],
                  ),
                  ...specKeys.map((spec) {
                    final highlight = controller.hasDifference(spec);
                    final rowColor = highlight
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.08)
                        : Colors.transparent;
                    final label = context.tr('compare_spec_$spec');
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
                          (car) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                            child: Text(car.specs[spec] ?? '-'),
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

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('compare_title')),
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
                      child: ValueListenableBuilder<List<String>>(
                        valueListenable: controller.availableBrands,
                        builder: (context, brands, _) {
                          if (brands.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return ValueListenableBuilder<Set<String>>(
                            valueListenable: controller.activeBrands,
                            builder: (context, active, __) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    context.tr('compare_filter_brand'),
                                    style: theme.textTheme.titleSmall,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildBrands(context, brands, active),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: ValueListenableBuilder<List<Car>>(
                        valueListenable: controller.selectedCars,
                        builder: (context, selected, _) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSelectionHeader(context, selected),
                              const SizedBox(height: 16),
                              ValueListenableBuilder<Car?>(
                                valueListenable: controller.focusCar,
                                builder: (context, car, __) {
                                  if (car == null) {
                                    return Container(
                                      height: 220,
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(context.tr('compare_viewer_placeholder')),
                                    );
                                  }
                                  return SizedBox(
                                    height: 260,
                                    child: Car3DViewer(
                                      assetPath: car.asset3D,
                                      onReset: () {},
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 24),
                              _buildSpecsTable(context, controller),
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
                    ValueListenableBuilder<List<Car>>(
                      valueListenable: controller.filteredCars,
                      builder: (context, cars, _) {
                        if (cars.isEmpty) {
                          return SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Text(
                                context.tr('compare_empty'),
                                style: theme.textTheme.bodyLarge,
                              ),
                            ),
                          );
                        }
                        return SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                          sliver: SliverToBoxAdapter(
                            child: ValueListenableBuilder<List<Car>>(
                              valueListenable: controller.selectedCars,
                              builder: (context, selectedCars, __) {
                                return GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 16,
                                    crossAxisSpacing: 16,
                                    childAspectRatio: 0.76,
                                  ),
                                  itemCount: cars.length,
                                  itemBuilder: (context, index) {
                                    final car = cars[index];
                                    final isSelected = selectedCars.any((c) => c.id == car.id);
                                    final actionLabel = isSelected
                                        ? context.tr('compare_remove')
                                        : context.tr('compare_add');
                                    return CarCompareCard(
                                      car: car,
                                      isSelected: isSelected,
                                      onToggle: () => _toggleCar(car),
                                      onPreview: () {
                                        _setFocus(car);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('${context.tr('compare_preview_snackbar')} ${car.displayName}'),
                                            duration: const Duration(seconds: 2),
                                          ),
                                        );
                                      },
                                      primaryActionLabel: actionLabel,
                                      previewTooltip: context.tr('compare_preview_tooltip'),
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
