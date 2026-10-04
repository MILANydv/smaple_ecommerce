import 'package:flutter/material.dart';

import '../../controllers/cart_controller.dart';
import '../../controllers/shop_scope.dart';
import '../../core/theme/app_tokens.dart';
import '../../models/cart_item.dart';
import '../../models/product.dart';
import '../widgets/cart_line_tile.dart';
import '../widgets/empty_state.dart';
import '../widgets/free_shipping_meter.dart';
import '../widgets/order_summary_card.dart';
import '../widgets/promo_code_field.dart';
import '../widgets/shop_snack.dart';
import 'order_success_screen.dart';
import 'product_detail_screen.dart';

/// View: the cart. Every number comes from [CartController], the screen only
/// decides what happens when a line is swiped away or checkout is tapped.
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  static const String _heroPrefix = 'cart';

  Future<void> _removeLine(
    BuildContext context,
    CartController cart,
    CartItem item,
  ) async {
    await cart.removeLine(item.product);
    if (!context.mounted) return;

    ShopSnack.show(
      context,
      '${item.product.name} removed from cart',
      actionLabel: 'Undo',
      onAction: () => cart.restore(item),
    );
  }

  Future<void> _confirmClear(BuildContext context, CartController cart) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        icon: const Icon(Icons.delete_sweep_outlined),
        title: const Text('Empty the cart?'),
        content: const Text('Every item will be removed from your cart.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep'),
          ),
          FilledButton(
            key: const Key('confirm_clear_cart'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Clear cart'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      await cart.clear();
    }
  }

  void _applyPromo(BuildContext context, CartController cart, String code) {
    final bool accepted = cart.applyPromo(code);
    ShopSnack.show(
      context,
      accepted ? '$code applied to your order' : 'That promo code is not valid',
    );
  }

  void _checkout(BuildContext context, CartController cart) {
    final order = cart.placeOrder();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => OrderSuccessScreen(order: order),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final CartController cart = ShopScope.of(context).cart;

    return ListenableBuilder(
      listenable: cart,
      builder: (BuildContext context, Widget? child) {
        final List<CartItem> items = cart.items;

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: <Widget>[
                const Text('Your cart'),
                if (items.isNotEmpty) ...<Widget>[
                  const SizedBox(width: AppSpacing.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: AppRadii.chip,
                    ),
                    child: Text(
                      '${cart.itemCount}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            actions: <Widget>[
              if (items.isNotEmpty)
                TextButton(
                  key: const Key('clear_cart_button'),
                  onPressed: () => _confirmClear(context, cart),
                  child: const Text('Clear'),
                ),
              const SizedBox(width: AppSpacing.xs),
            ],
          ),
          body: items.isEmpty
              ? EmptyState(
                  icon: Icons.shopping_cart_outlined,
                  title: 'Your cart is empty',
                  subtitle: 'Add a few products from the catalog to get started',
                  actionLabel: 'Browse products',
                  onAction: () => Navigator.of(context).maybePop(),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    AppSpacing.xs,
                    AppSpacing.page,
                    AppSpacing.lg,
                  ),
                  children: <Widget>[
                    FreeShippingMeter(
                      progress: cart.freeShippingProgress,
                      amountMissing: cart.amountToFreeShipping,
                      thresholdLabel:
                          'Free delivery on orders over ${Product.formatPrice(CartController.freeShippingThreshold)}',
                    ),
                    const SizedBox(height: AppSpacing.md),
                    for (final CartItem item in items)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: CartLineTile(
                          item: item,
                          heroPrefix: _heroPrefix,
                          canIncrease:
                              item.product.stock <= 0 ||
                              item.quantity < item.product.stock,
                          onIncrease: () => cart.add(item.product),
                          onDecrease: () => cart.removeOne(item.product),
                          onRemove: () => _removeLine(context, cart, item),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (BuildContext context) =>
                                  ProductDetailScreen(
                                    product: item.product,
                                    heroPrefix: _heroPrefix,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: AppSpacing.xs),
                    PromoCodeField(
                      appliedCode: cart.promoCode,
                      onApply: (String code) =>
                          _applyPromo(context, cart, code),
                      onRemove: cart.removePromo,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    OrderSummaryCard(
                      cart: cart,
                      onRemovePromo: cart.removePromo,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const _TrustRow(),
                  ],
                ),
          bottomNavigationBar: items.isEmpty
              ? null
              : _CheckoutBar(
                  cart: cart,
                  onCheckout: () => _checkout(context, cart),
                ),
        );
      },
    );
  }
}

/// Sticky total + checkout button.
class _CheckoutBar extends StatelessWidget {
  const _CheckoutBar({required this.cart, required this.onCheckout});

  final CartController cart;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.sm,
        AppSpacing.page,
        AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Total',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  Product.formatPrice(cart.total),
                  key: const Key('cart_total'),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: FilledButton.icon(
                key: const Key('checkout_button'),
                onPressed: onCheckout,
                icon: const Icon(Icons.lock_rounded, size: 18),
                label: Text('Checkout · ${cart.itemCountLabel}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Three small promises under the summary card.
class _TrustRow extends StatelessWidget {
  const _TrustRow();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<(IconData, String)> items = <(IconData, String)>[
      (Icons.lock_outline_rounded, 'Secure payment'),
      (Icons.pedal_bike_rounded, 'Carbon neutral delivery'),
      (Icons.replay_rounded, '30 day returns'),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        for (final (IconData icon, String label) in items)
          Expanded(
            child: Column(
              children: <Widget>[
                Icon(
                  icon,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}