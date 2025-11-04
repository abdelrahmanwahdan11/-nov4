import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../controllers/cart_controller.dart';
import '../../widgets/app_scaffold.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _couponController = TextEditingController();

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return AppScaffold(
      currentIndex: 2,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Consumer<CartController>(
            builder: (context, cart, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(loc.translate('cartTitle'), style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 16),
                  Expanded(
                    child: cart.items.isEmpty
                        ? const Center(child: Text('Your cart is empty'))
                        : ListView.separated(
                            itemCount: cart.items.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final item = cart.items[index];
                              return Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Expanded(child: Text(item.title, style: Theme.of(context).textTheme.titleMedium)),
                                      IconButton(
                                        onPressed: () => cart.updateQuantity(item.id, item.quantity - 1),
                                        icon: const Icon(Icons.remove_circle_outline),
                                      ),
                                      Text('${item.quantity}'),
                                      IconButton(
                                        onPressed: () => cart.updateQuantity(item.id, item.quantity + 1),
                                        icon: const Icon(Icons.add_circle_outline),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(item.price.toStringAsFixed(2)),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _couponController,
                    decoration: InputDecoration(
                      labelText: 'Coupon code',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.redeem),
                        onPressed: () {
                          cart.applyCoupon(_couponController.text);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coupon applied')));
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subtotal'),
                      Text(cart.subtotal.toStringAsFixed(2)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Discount'),
                      Text(cart.discount.toStringAsFixed(2)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(cart.total.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: cart.items.isEmpty ? null : () {},
                      child: const Text('Checkout'),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
