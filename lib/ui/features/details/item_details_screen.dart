import 'package:flutter/material.dart';
import 'package:greenly/core/state/simple_provider.dart';

import '../../../data/models/food_item.dart';
import '../../../data/repositories_local/food_repository_local.dart';
import '../../controllers/cart_controller.dart';
import '../../widgets/skeleton_base.dart';
import '../../widgets/simple_flip_card.dart';

class ItemDetailsScreen extends StatefulWidget {
  const ItemDetailsScreen({super.key, required this.itemId});

  final String itemId;

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> with SingleTickerProviderStateMixin {
  final FoodRepositoryLocal _repository = FoodRepositoryLocal();
  FoodItem? _item;
  bool _loading = true;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final item = await _repository.getById(widget.itemId);
    setState(() {
      _item = item;
      _loading = false;
    });
  }

  void _changeQuantity(int delta) {
    setState(() {
      _quantity = (_quantity + delta).clamp(1, 20);
    });
  }

  void _addToCart() {
    final item = _item;
    if (item == null) return;
    context.read<CartController>().addItem(CartItemState(id: item.id, title: item.titleEn, price: item.price, quantity: _quantity));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to cart')));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: SkeletonBase(height: 200)));
    }
    final item = _item;
    if (item == null) {
      return const Scaffold(body: Center(child: Text('Item not found')));
    }
    return Scaffold(
      appBar: AppBar(title: Text(item.titleEn)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: item.id,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.network(item.imageUrl, height: 240, width: double.infinity, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 16),
            FlipCard(
              front: _CardFace(
                title: item.titleEn,
                description: item.descEn,
                onAdd: _addToCart,
              ),
              back: _CardFace(
                title: 'Nutrition',
                description: 'Weight: ${item.grams} g\nCalories: ${item.kcal}\nTags: ${item.tags.join(', ')}',
                onAdd: _addToCart,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                IconButton(onPressed: () => _changeQuantity(-1), icon: const Icon(Icons.remove_circle_outline)),
                AnimatedScale(
                  scale: 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Text('$_quantity', style: Theme.of(context).textTheme.headlineMedium),
                ),
                IconButton(onPressed: () => _changeQuantity(1), icon: const Icon(Icons.add_circle_outline)),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _addToCart,
                  icon: const Icon(Icons.shopping_bag),
                  label: const Text('Add to cart'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CardFace extends StatelessWidget {
  const _CardFace({required this.title, required this.description, required this.onAdd});

  final String title;
  final String description;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                const Icon(Icons.cyclone, size: 20),
              ],
            ),
            const SizedBox(height: 12),
            Text(description),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(onPressed: onAdd, child: const Text('Add')),
            ),
          ],
        ),
      ),
    );
  }
}
