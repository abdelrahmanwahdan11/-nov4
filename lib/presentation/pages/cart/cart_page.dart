import 'package:flutter/material.dart';

import '../../../core/locale/localization_extension.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('cart_title')),
      ),
      body: Center(
        child: Text(context.tr('cart_placeholder')),
      ),
    );
  }
}
