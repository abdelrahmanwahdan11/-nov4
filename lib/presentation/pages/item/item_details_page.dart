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
                          Text(
                            '\\$${widget.item.price.toStringAsFixed(2)}',
                            style: theme.textTheme.headlineSmall?.copyWith(color: colorScheme.primary),
                          ),
                          const SizedBox(height: 4),
                          Text('${widget.item.weight} g • ${widget.item.kcal} kcal'),
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
                      content: _buildFacts(context),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final cart = CartScope.of(context);
                      await cart.addItem(widget.item);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${context.tr('added_to_cart')} ${widget.item.name}')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    ),
                    icon: const Icon(Icons.shopping_bag_outlined),
                    label: Text(context.tr('action_add_cart')),
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

  Widget _buildFacts(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.titleMedium;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FactTile(label: context.tr('fact_weight'), value: '${widget.item.weight} g', style: style),
        _FactTile(label: context.tr('fact_kcal'), value: '${widget.item.kcal} kcal', style: style),
        _FactTile(
          label: context.tr('fact_price'),
          value: '\\$${widget.item.price.toStringAsFixed(2)}',
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
