import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/locale/localization_extension.dart';
import '../../../domain/models/in_app_message.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/in_app_messaging_controller.dart';
import '../../widgets/cart_line_tile.dart';
import '../../widgets/in_app_banner_strip.dart';
import '../../widgets/contextual_nudge_overlay.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  CartController? _controller;
  late final TextEditingController _promoController;
  late final FocusNode _promoFocusNode;
  StreamSubscription<CartEvent>? _eventSubscription;
  InAppMessagingController? _messagingController;
  StreamSubscription<SnackMessage>? _messagingSubscription;

  @override
  void initState() {
    super.initState();
    _promoController = TextEditingController();
    _promoFocusNode = FocusNode();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = CartScope.of(context);
    if (!identical(_controller, controller)) {
      _eventSubscription?.cancel();
      _controller?.promoCode.removeListener(_syncPromoField);
      _controller = controller;
      _promoController.text = controller.promoCode.value ?? '';
      controller.promoCode.addListener(_syncPromoField);
      _eventSubscription = controller.events.listen(_handleEvent);
    }
    final messaging = InAppMessagingScope.maybeOf(context);
    if (!identical(_messagingController, messaging)) {
      _messagingSubscription?.cancel();
      _messagingController = messaging;
      if (messaging != null) {
        messaging.activateSurface(MessageSurface.cart);
        _messagingSubscription = messaging.snackMessages.listen((event) {
          if (!mounted) {
            return;
          }
          final messenger = ScaffoldMessenger.of(context);
          messenger.hideCurrentSnackBar();
          messenger.showSnackBar(
            SnackBar(content: Text(context.tr(event.key, params: event.params))),
          );
        });
      }
    }
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    _controller?.promoCode.removeListener(_syncPromoField);
    _promoController.dispose();
    _promoFocusNode.dispose();
    _messagingSubscription?.cancel();
    super.dispose();
  }

  void _syncPromoField() {
    final controller = _controller;
    if (controller == null) {
      return;
    }
    final code = controller.promoCode.value ?? '';
    if (_promoController.text != code) {
      _promoController.value = TextEditingValue(
        text: code,
        selection: TextSelection.collapsed(offset: code.length),
      );
    }
  }

  void _handleEvent(CartEvent event) {
    if (!mounted) {
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    switch (event.type) {
      case CartEventType.promoApplied:
        final code = event.code ?? '';
        final message = code.isEmpty
            ? context.tr('cart_promo_success')
            : '${context.tr('cart_promo_success')} $code';
        messenger.showSnackBar(SnackBar(content: Text(message)));
        break;
      case CartEventType.checkoutSuccess:
        final orderId = event.orderId ?? '';
        final message = orderId.isEmpty
            ? context.tr('cart_checkout_success')
            : '${context.tr('cart_checkout_success')} ${context.tr('cart_checkout_id')} $orderId';
        messenger.showSnackBar(SnackBar(content: Text(message)));
        break;
    }
  }

  void _applyPromo() {
    final controller = _controller;
    if (controller == null) {
      return;
    }
    _promoFocusNode.unfocus();
    controller.applyPromo(_promoController.text);
    _messagingController?.markActionCompleted(InAppActionIds.focusCartPromo);
  }

  void _showCheckoutSheet() {
    final controller = _controller;
    if (controller == null || controller.entries.value.isEmpty) {
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (sheetContext) {
        final navigator = Navigator.of(sheetContext);
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(sheetContext).colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    sheetContext.tr('cart_checkout_title'),
                    style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    sheetContext.tr('cart_checkout_desc'),
                    style: Theme.of(sheetContext).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  ValueListenableBuilder<double>(
                    valueListenable: controller.subtotal,
                    builder: (context, value, _) {
                      return _SummaryRow(
                        label: context.tr('cart_summary_subtotal'),
                        value: value,
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  ValueListenableBuilder<double>(
                    valueListenable: controller.discount,
                    builder: (context, value, _) {
                      return _SummaryRow(
                        label: context.tr('cart_summary_discount'),
                        value: value,
                        isDiscount: true,
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  ValueListenableBuilder<double>(
                    valueListenable: controller.total,
                    builder: (context, value, _) {
                      return _SummaryRow(
                        label: context.tr('cart_summary_total'),
                        value: value,
                        emphasize: true,
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(sheetContext).pop(),
                          child: Text(sheetContext.tr('cart_checkout_cancel')),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ValueListenableBuilder<bool>(
                          valueListenable: controller.isProcessingCheckout,
                          builder: (context, processing, _) {
                            return FilledButton(
                              onPressed: processing
                                  ? null
                                  : () async {
                                      await controller.checkout();
                                      if (navigator.mounted) {
                                        navigator.pop();
                                      }
                                    },
                              child: processing
                                  ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.4,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Theme.of(sheetContext).colorScheme.onPrimary,
                                        ),
                                      ),
                                    )
                                  : Text(sheetContext.tr('cart_checkout_confirm')),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleMessagingAction(String? route, String? actionId) {
    if (actionId == InAppActionIds.focusCartPromo) {
      _promoFocusNode.requestFocus();
      return;
    }
    if (route != null) {
      Navigator.of(context).pushNamed(route);
    }
  }

  Widget _buildPromoCard() {
    final controller = _controller;
    if (controller == null) {
      return const SizedBox.shrink();
    }
    return ValueListenableBuilder<String?>(
      valueListenable: controller.promoCode,
      builder: (context, code, _) {
        return ValueListenableBuilder<String?>(
          valueListenable: controller.promoError,
          builder: (context, errorKey, __) {
            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('cart_promo_label'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _promoController,
                      focusNode: _promoFocusNode,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _applyPromo(),
                      decoration: InputDecoration(
                        hintText: context.tr('cart_promo_hint'),
                        errorText: () {
                          if (errorKey == 'empty') {
                            return context.tr('cart_promo_error_empty');
                          }
                          if (errorKey == 'invalid') {
                            return context.tr('cart_promo_error_invalid');
                          }
                          return null;
                        }(),
                        suffixIcon: code == null
                            ? null
                            : IconButton(
                                onPressed: controller.clearPromo,
                                tooltip: context.tr('cart_promo_clear'),
                                icon: const Icon(Icons.close_rounded),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.tonal(
                            onPressed: _applyPromo,
                            child: Text(context.tr('cart_apply')),
                          ),
                        ),
                      ],
                    ),
                    if (code != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        '${context.tr('cart_promo_active')} $code',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 300.ms, curve: Curves.easeOut);
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final color = theme.colorScheme.primary;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 72, color: color).animate().fadeIn(duration: 300.ms).scale(),
          const SizedBox(height: 24),
          Text(
            context.tr('cart_empty_title'),
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              context.tr('cart_empty_subtitle'),
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    final controller = _controller;
    if (controller == null) {
      return const SizedBox.shrink();
    }
    return ValueListenableBuilder<List<CartEntry>>(
      valueListenable: controller.entries,
      builder: (context, entries, _) {
        if (entries.isEmpty) {
          return const SizedBox.shrink();
        }
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.08),
                blurRadius: 32,
                offset: const Offset(0, -18),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ValueListenableBuilder<double>(
                  valueListenable: controller.subtotal,
                  builder: (context, value, _) => _SummaryRow(
                    label: context.tr('cart_summary_subtotal'),
                    value: value,
                  ),
                ),
                const SizedBox(height: 8),
                ValueListenableBuilder<double>(
                  valueListenable: controller.discount,
                  builder: (context, value, _) => _SummaryRow(
                    label: context.tr('cart_summary_discount'),
                    value: value,
                    isDiscount: true,
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                ValueListenableBuilder<double>(
                  valueListenable: controller.total,
                  builder: (context, totalValue, _) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _SummaryRow(
                          label: context.tr('cart_summary_total'),
                          value: totalValue,
                          emphasize: true,
                        ),
                        const SizedBox(height: 16),
                        ValueListenableBuilder<bool>(
                          valueListenable: controller.isProcessingCheckout,
                          builder: (context, processing, __) {
                            return FilledButton(
                              onPressed: processing ? null : _showCheckoutSheet,
                              style: FilledButton.styleFrom(
                                minimumSize: const Size.fromHeight(56),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                              ),
                              child: processing
                                  ? SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.6,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Theme.of(context).colorScheme.onPrimary,
                                        ),
                                      ),
                                    )
                                  : Text(context.tr('cart_checkout')),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCartList(CartController controller, List<CartEntry> entries) {
    final children = <Widget>[];
    final messaging = _messagingController;
    if (messaging != null) {
      children
        ..add(
          InAppBannerStrip(
            controller: messaging,
            surface: MessageSurface.cart,
            padding: EdgeInsets.zero,
            onAction: (banner, route) => _handleMessagingAction(route, banner.actionId),
          ),
        )
        ..add(const SizedBox(height: 16));
    }
    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      children
        ..add(
          CartLineTile(
            entry: entry,
            onIncrement: () => controller.increment(entry.line.identifier),
            onDecrement: () => controller.decrement(entry.line.identifier),
            onRemove: () => controller.remove(entry.line.identifier),
          )
              .animate()
              .fadeIn(duration: 280.ms, curve: Curves.easeOut)
              .slideY(begin: 0.1, end: 0),
        )
        ..add(const SizedBox(height: 16));
    }
    children
      ..add(_buildPromoCard())
      ..add(const SizedBox(height: 24));
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 220),
      physics: const BouncingScrollPhysics(),
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('cart_title')),
      ),
      body: controller == null
          ? const SizedBox.shrink()
          : ValueListenableBuilder<List<CartEntry>>(
              valueListenable: controller.entries,
              builder: (context, entries, _) {
                if (entries.isEmpty) {
                  return _buildEmptyState();
                }
                final list = _buildCartList(controller, entries);
                return Stack(
                  children: [
                    Positioned.fill(child: list),
                    if (_messagingController != null)
                      Positioned.fill(
                        child: ContextualNudgeOverlay(
                          controller: _messagingController!,
                          surface: MessageSurface.cart,
                          isEnabled: entries.isNotEmpty,
                          additionalBottomPadding: 220,
                          onAction: (nudge, route) => _handleMessagingAction(route, nudge.actionId),
                        ),
                      ),
                  ],
                );
              },
            ),
      bottomNavigationBar: _buildSummary(),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isDiscount = false,
    this.emphasize = false,
  });

  final String label;
  final double value;
  final bool isDiscount;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = emphasize
        ? theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)
        : theme.textTheme.titleMedium;
    final formatted = '\\$${value.toStringAsFixed(2)}';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyMedium),
        Text(
          isDiscount ? '-$formatted' : formatted,
          style: isDiscount
              ? textStyle?.copyWith(color: theme.colorScheme.primary)
              : textStyle,
        ),
      ],
    );
  }
}

// PHASE_4_DONE
