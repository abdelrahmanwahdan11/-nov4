import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/locale/localization_extension.dart';
import '../../../domain/models/food_item.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/favorites_controller.dart';
import '../../controllers/recently_viewed_controller.dart';
import '../../widgets/manual_flip_card.dart';

class ItemDetailsPage extends StatefulWidget {
  const ItemDetailsPage({super.key, required this.item});

  static const routeName = '/item/details';

  final FoodItem item;

  @override
  State<ItemDetailsPage> createState() => _ItemDetailsPageState();
}

class _ItemDetailsPageState extends State<ItemDetailsPage> {
  FavoritesController? _favoritesController;
  bool _recorded = false;
  late String _selectedSizeId;
  late Set<String> _selectedAddons;
  int _quantity = 1;

  FoodSizeOption get _selectedSize => widget.item.sizeById(_selectedSizeId) ?? widget.item.defaultSize;

  double get _basePrice => _selectedSize.priceFor(widget.item);

  double get _addonsPrice {
    return _selectedAddons.fold<double>(0, (value, addonId) {
      final addon = widget.item.addonById(addonId);
      return value + (addon?.price ?? 0);
    });
  }

  double get _unitPrice => double.parse((_basePrice + _addonsPrice).toStringAsFixed(2));

  double get _totalPrice => double.parse((_unitPrice * _quantity).toStringAsFixed(2));

  double get _baseTotal => double.parse((_basePrice * _quantity).toStringAsFixed(2));

  double get _addonsTotal => double.parse((_addonsPrice * _quantity).toStringAsFixed(2));

  int get _displayWeight => _selectedSize.weightFor(widget.item);

  int get _displayKcal => _selectedSize.kcalFor(widget.item);

  @override
  void initState() {
    super.initState();
    _selectedSizeId = widget.item.defaultSize.id;
    _selectedAddons = <String>{};
  }

  void _onSelectSize(String id) {
    if (id == _selectedSizeId) {
      return;
    }
    setState(() {
      _selectedSizeId = id;
    });
  }

  void _onToggleAddon(String id, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedAddons.add(id);
      } else {
        _selectedAddons.remove(id);
      }
    });
  }

  void _changeQuantity(int delta) {
    final next = _quantity + delta;
    if (next < 1) {
      return;
    }
    setState(() {
      _quantity = next;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final favorites = FavoritesScope.maybeOf(context);
    if (!identical(favorites, _favoritesController)) {
      _favoritesController = favorites;
    }
    final recent = RecentlyViewedScope.maybeOf(context);
    if (!_recorded && recent != null) {
      _recorded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        recent.record(widget.item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final unitPrice = _unitPrice;
    final totalPrice = _totalPrice;
    final weight = _displayWeight;
    final kcal = _displayKcal;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.name),
        actions: [
          if (_favoritesController != null)
            ValueListenableBuilder<List<String>>(
              valueListenable: _favoritesController!.favoriteIds,
              builder: (context, ids, _) {
                final isFavorite = ids.contains(widget.item.id);
                return IconButton(
                  onPressed: () => _favoritesController!.toggleFavorite(widget.item),
                  tooltip: context.tr(isFavorite ? 'action_unfavorite' : 'action_favorite'),
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? theme.colorScheme.error : null,
                  ),
                );
              },
            ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Hero(
              tag: 'food_${widget.item.id}',
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                child: Image.network(
                  widget.item.imageUrl,
                  height: 260,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) {
                      return child;
                    }
                    return SizedBox(
                      height: 260,
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.item.name,
                          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Text(
                              '\\$${unitPrice.toStringAsFixed(2)}',
                              key: ValueKey<double>(unitPrice),
                              style: theme.textTheme.headlineSmall?.copyWith(color: colorScheme.primary),
                            ),
                          ),
                          const SizedBox(height: 4),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Text(
                              '$weight g • $kcal kcal',
                              key: ValueKey<String>('${weight}_$kcal'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.item.description,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  Text(context.tr('flip_card_hint'), style: theme.textTheme.labelLarge),
                  const SizedBox(height: 12),
                  ManualFlipCard(
                    front: _InfoSide(
                      title: context.tr('nutrition_front_title'),
                      subtitle: context.tr('nutrition_front_sub'),
                      content: _buildTagWrap(context),
                    ),
                    back: _InfoSide(
                      title: context.tr('nutrition_back_title'),
                      subtitle: context.tr('nutrition_back_sub'),
                      content: _buildFacts(context, weight, kcal, unitPrice),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    context.tr('item_size_section_title'),
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.tr('item_size_section_subtitle'),
                    style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 12),
                  _buildSizeSelector(theme, colorScheme),
                  if (widget.item.addons.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      context.tr('item_addons_section_title'),
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.tr('item_addons_section_subtitle'),
                      style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 12),
                    _buildAddonsSelector(theme, colorScheme),
                  ],
                  const SizedBox(height: 24),
                  _buildQuantitySelector(context),
                  const SizedBox(height: 16),
                  _buildPriceSummary(context),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final cart = CartScope.of(context);
                      await cart.addItem(
                        widget.item,
                        sizeId: _selectedSizeId,
                        addons: _selectedAddons.toList(),
                        quantity: _quantity,
                      );
                      if (!mounted) {
                        return;
                      }
                      final multiplier = _quantity > 1 ? ' ×$_quantity' : '';
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${context.tr('added_to_cart')} ${widget.item.name}$multiplier',
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    ),
                    icon: const Icon(Icons.shopping_bag_outlined),
                    label: Text(
                      '${context.tr('action_add_cart')} • \\${totalPrice.toStringAsFixed(2)}',
                    ),
                  ).animate().slideY(begin: 0.2, end: 0, curve: Curves.easeOut).fadeIn(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagWrap(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: widget.item.tags
          .map(
            (tag) => Chip(
              label: Text(tag),
              backgroundColor: theme.colorScheme.surfaceVariant,
            ),
          )
          .toList(),
    );
  }

  Widget _buildSizeSelector(ThemeData theme, ColorScheme colorScheme) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: widget.item.sizes.map((option) {
        final selected = option.id == _selectedSizeId;
        final price = option.priceFor(widget.item).toStringAsFixed(2);
        return ChoiceChip(
          selected: selected,
          onSelected: (_) => _onSelectSize(option.id),
          label: Text('${option.label} • \\$${price}'),
          selectedColor: colorScheme.primary.withOpacity(0.12),
          labelStyle: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        );
      }).toList(),
    );
  }

  Widget _buildAddonsSelector(ThemeData theme, ColorScheme colorScheme) {
    if (widget.item.addons.isEmpty) {
      return Text(
        context.tr('item_addons_none'),
        style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
      );
    }
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: widget.item.addons.map((addon) {
        final selected = _selectedAddons.contains(addon.id);
        return FilterChip(
          selected: selected,
          onSelected: (value) => _onToggleAddon(addon.id, value),
          label: Text('${addon.label} (+\\$${addon.price.toStringAsFixed(2)})'),
          selectedColor: colorScheme.primary.withOpacity(0.12),
          labelStyle: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        );
      }).toList(),
    );
  }

  Widget _buildQuantitySelector(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('item_quantity_label'),
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                context.tr('item_quantity_helper'),
                style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant.withOpacity(0.5),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => _changeQuantity(-1),
                icon: const Icon(Icons.remove),
                tooltip: context.tr('item_quantity_decrease'),
              ),
              Text(
                '$_quantity',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              IconButton(
                onPressed: () => _changeQuantity(1),
                icon: const Icon(Icons.add),
                tooltip: context.tr('item_quantity_increase'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSummary(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.35),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SummaryRow(
            label: context.tr('item_price_breakdown_base'),
            value: '\\$${_baseTotal.toStringAsFixed(2)}',
            emphasize: false,
          ),
          _SummaryRow(
            label: context.tr('item_price_breakdown_addons'),
            value: '\\$${_addonsTotal.toStringAsFixed(2)}',
            emphasize: false,
          ),
          _SummaryRow(
            label: context.tr('item_price_breakdown_quantity'),
            value: '×$_quantity',
            emphasize: false,
          ),
          const Divider(height: 24),
          _SummaryRow(
            label: context.tr('item_price_breakdown_total'),
            value: '\\$${_totalPrice.toStringAsFixed(2)}',
            emphasize: true,
          ),
        ],
      ),
    );
  }

  Widget _buildFacts(BuildContext context, int weight, int kcal, double price) {
    final theme = Theme.of(context);
    final style = theme.textTheme.titleMedium;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FactTile(label: context.tr('fact_weight'), value: '$weight g', style: style),
        _FactTile(label: context.tr('fact_kcal'), value: '$kcal kcal', style: style),
        _FactTile(
          label: context.tr('fact_price'),
          value: '\\$${price.toStringAsFixed(2)}',
          style: style,
        ),
        _FactTile(
          label: context.tr('fact_type'),
          value: widget.item.isVegan ? context.tr('fact_type_vegan') : context.tr('fact_type_mixed'),
          style: style,
        ),
        _FactTile(
          label: context.tr('fact_new'),
          value: widget.item.isNew ? context.tr('fact_new_yes') : context.tr('fact_new_no'),
          style: style,
        ),
      ],
    );
  }
}

class _InfoSide extends StatelessWidget {
  const _InfoSide({required this.title, required this.subtitle, required this.content});

  final String title;
  final String subtitle;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(subtitle, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }
}

class _FactTile extends StatelessWidget {
  const _FactTile({required this.label, required this.value, required this.style});

  final String label;
  final String value;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value, required this.emphasize});

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = emphasize
        ? theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)
        : theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }
}
