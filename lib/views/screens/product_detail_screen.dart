import 'package:flutter/material.dart';

import '../../controllers/cart_controller.dart';
import '../../controllers/shop_scope.dart';
import '../../core/theme/app_tokens.dart';
import '../../models/product.dart';
import '../widgets/cart_button.dart';
import '../widgets/price_label.dart';
import '../widgets/product_visual.dart';
import '../widgets/quantity_stepper.dart';
import '../widgets/rating_badge.dart';
import '../widgets/shop_snack.dart';
import 'cart_screen.dart';

/// View: one product. The tile animates in from the list that was tapped
/// ([heroPrefix] tells the Hero which list it came from).
class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({
    super.key,
    required this.product,
    this.heroPrefix = 'grid',
  });

  final Product product;
  final String heroPrefix;

  void _openCart(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const CartScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final CartController cart = ShopScope.of(context).cart;
    final int quantity = cart.quantityOf(product);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          product.category,
          style: theme.textTheme.titleMedium,
        ),
        actions: <Widget>[
          CartButton(count: cart.itemCount, onPressed: () => _openCart(context)),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              key: const Key('detail_scroll'),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                0,
                AppSpacing.page,
                AppSpacing.lg,
              ),
              children: <Widget>[
                AspectRatio(
                  aspectRatio: 4 / 3,
                  child: ProductVisual(
                    product: product,
                    heroTag: '$heroPrefix-${product.id}',
                    iconSize: 132,
                    borderRadius: AppRadii.hero,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: <Widget>[
                    _CategoryPill(category: product.category),
                    const SizedBox(width: AppSpacing.xs),
                    RatingBadge(rating: product.rating),
                    const Spacer(),
                    Text(
                      product.stockLabel,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: product.inStock
                            ? (product.isLowStock
                                  ? scheme.tertiary
                                  : scheme.onSurfaceVariant)
                            : scheme.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(product.name, style: theme.textTheme.headlineSmall),
                const SizedBox(height: AppSpacing.sm),
                PriceLabel(
                  product: product,
                  size: PriceSize.large,
                  color: scheme.primary,
                ),
                const SizedBox(height: AppSpacing.md),
                const Divider(),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  product.description.isEmpty
                      ? 'A dependable pick from the $product.category range.'
                      : product.description,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('Why you will like it', style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                const _FeatureRow(
                  icon: Icons.local_shipping_rounded,
                  title: 'Free delivery over \$75',
                  subtitle: 'Dispatched within 24 hours, tracked end to end.',
                ),
                const _FeatureRow(
                  icon: Icons.assignment_return_rounded,
                  title: '30 day returns',
                  subtitle: 'Changed your mind? Send it back, no questions.',
                ),
                const _FeatureRow(
                  icon: Icons.verified_rounded,
                  title: 'Two year warranty',
                  subtitle: 'Repairs handled by the manufacturer, shipping on us.',
                ),
              ],
            ),
          ),
          _AddToCartBar(product: product, cart: cart, quantity: quantity),
        ],
      ),
    );
  }
}

/// Sticky bottom bar: quantity stepper plus the add button.
class _AddToCartBar extends StatelessWidget {
  const _AddToCartBar({
    required this.product,
    required this.cart,
    required this.quantity,
  });

  final Product product;
  final CartController cart;
  final int quantity;

  Future<void> _add(BuildContext context) async {
    await cart.add(product);
    if (!context.mounted) return;
    ShopSnack.show(
      context,
      '${product.name} added to cart',
      actionLabel: 'View cart',
      onAction: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) => const CartScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool canIncrease = product.stock <= 0 || quantity < product.stock;

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
            QuantityStepper(
              quantity: quantity,
              canDecrease: quantity > 0,
              canIncrease: canIncrease,
              onIncrease: () => cart.add(product),
              onDecrease: () => cart.removeOne(product),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: FilledButton.icon(
                key: const Key('add_to_cart_button'),
                onPressed: product.inStock ? () => _add(context) : null,
                icon: const Icon(Icons.add_shopping_cart_rounded),
                label: Text(
                  !product.inStock
                      ? 'Out of stock'
                      : quantity > 0
                      ? 'Add another ($quantity)'
                      : 'Add to cart',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({required this.category});

  final String category;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: AppRadii.chip,
      ),
      child: Text(
        category.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            child: Icon(
              icon,
              size: 20,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: theme.textTheme.titleSmall),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}