import 'package:flutter/material.dart';
import 'package:greenly/core/state/simple_provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/routing/app_router.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/session_controller.dart';
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

  void _applyCoupon(CartController cart, AppLocalizations loc) {
    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(loc.translate('cartCouponNoItems'))));
      return;
    }

    final success = cart.applyCoupon(_couponController.text);
    if (!mounted) return;
    final message = success ? loc.translate('couponApplied') : loc.translate('couponInvalid');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _handleCheckout(CartController cart, AppLocalizations loc) {
    final session = context.read<SessionController>();
    if (session.isGuest) {
      _showGuestSheet(loc);
      return;
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(loc.translate('cartCheckoutComingSoon'))));
  }

  void _showGuestSheet(AppLocalizations loc) {
    final parentContext = context;
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(loc.translate('cartGuestCheckoutTitle'),
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(loc.translate('cartGuestCheckoutMessage')),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    Navigator.of(parentContext).pushNamed(AppRoutes.login);
                  },
                  child: Text(loc.translate('cartGuestCheckoutAction')),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  child: Text(loc.translate('cancel')),
                ),
              ),
            ],
          ),
        );
      },
    );
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
              final theme = Theme.of(context);
              final items = cart.items;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(loc.translate('cartTitle'), style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 16),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: items.isEmpty
                          ? _EmptyCartMessage(message: loc.translate('cartEmpty'))
                          : ListView.separated(
                              itemCount: items.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final item = items[index];
                                return _CartItemTile(
                                  item: item,
                                  onDecrease: () => cart.updateQuantity(item.id, item.quantity - 1),
                                  onIncrease: () => cart.updateQuantity(item.id, item.quantity + 1),
                                );
                              },
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _couponController,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: loc.translate('cartCouponLabel'),
                      hintText: loc.translate('cartCouponHint'),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.redeem),
                        onPressed: items.isEmpty ? null : () => _applyCoupon(cart, loc),
                      ),
                    ),
                    onSubmitted: (_) => _applyCoupon(cart, loc),
                  ),
                  const SizedBox(height: 16),
                  _SummaryRow(label: loc.translate('cartSubtotal'), value: cart.subtotal),
                  _SummaryRow(label: loc.translate('cartDiscount'), value: cart.discount),
                  _SummaryRow(
                    label: loc.translate('cartTotal'),
                    value: cart.total,
                    emphasize: true,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: items.isEmpty ? null : () => _handleCheckout(cart, loc),
                      child: Text(loc.translate('cartCheckout')),
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

class _EmptyCartMessage extends StatelessWidget {
  const _EmptyCartMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inbox, size: 48),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  const _CartItemTile({required this.item, required this.onDecrease, required this.onIncrease});

  final CartItemState item;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(item.price.toStringAsFixed(2), style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            IconButton(
              onPressed: onDecrease,
              icon: const Icon(Icons.remove_circle_outline),
              tooltip: MaterialLocalizations.of(context).decrementButtonTooltip,
            ),
            Text('${item.quantity}', style: theme.textTheme.titleMedium),
            IconButton(
              onPressed: onIncrease,
              icon: const Icon(Icons.add_circle_outline),
              tooltip: MaterialLocalizations.of(context).incrementButtonTooltip,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value, this.emphasize = false});

  final String label;
  final double value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = emphasize
        ? theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
        : theme.textTheme.bodyLarge;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: textStyle),
          Text(value.toStringAsFixed(2), style: textStyle),
        ],
      ),
    );
  }
}
