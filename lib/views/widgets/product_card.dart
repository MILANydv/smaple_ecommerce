import 'package:flutter/material.dart';

import '../../core/theme/app_tokens.dart';
import '../../models/product.dart';
import 'price_label.dart';
import 'product_visual.dart';
import 'rating_badge.dart';

/// One tile of the catalog grid. Pure view: it receives the product, the
/// quantity already in the cart and the two callbacks the screen wires up.
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.quantityInCart,
    required this.heroPrefix,
    required this.onTap,
    required this.onAddToCart,
  });

  final Product product;
  final int quantityInCart;
  final String heroPrefix;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool soldOut = !product.inStock;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    ProductVisual(
                      product: product,
                      heroTag: '$heroPrefix-${product.id}',
                      iconSize: 60,
                    ),
                    Positioned(
                      top: AppSpacing.xs,
                      right: AppSpacing.xs,
                      child: RatingBadge(
                        rating: product.rating,
                        compact: true,
                        onDark: true,
                      ),
                    ),
                    if (quantityInCart > 0)
                      Positioned(
                        bottom: AppSpacing.xs,
                        left: AppSpacing.xs,
                        child: _InCartPill(count: quantityInCart),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                product.category.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                product.stockLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: soldOut
                      ? theme.colorScheme.error
                      : product.isLowStock
                      ? theme.colorScheme.tertiary
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: soldOut ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: PriceLabel(product: product, size: PriceSize.small),
                  ),
                  AddToCartButton(
                    productId: product.id,
                    enabled: !soldOut,
                    onPressed: onAddToCart,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Gradient pill showing how many of this product are already in the cart.
class _InCartPill extends StatelessWidget {
  const _InCartPill({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: AppRadii.chip,
      ),
      child: Text(
        '$count in cart',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Round add button that plays a short pop when it is tapped.
class AddToCartButton extends StatefulWidget {
  const AddToCartButton({
    super.key,
    required this.productId,
    required this.onPressed,
    this.enabled = true,
  });

  final String productId;
  final VoidCallback onPressed;
  final bool enabled;

  @override
  State<AddToCartButton> createState() => _AddToCartButtonState();
}

class _AddToCartButtonState extends State<AddToCartButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.medium,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward(from: 0).then((_) {
      if (mounted) _controller.reverse();
    });
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return ScaleTransition(
      scale: Tween<double>(begin: 1, end: 1.18).animate(
        CurvedAnimation(parent: _controller, curve: AppMotion.emphasized),
      ),
      child: IconButton.filled(
        key: Key('add_${widget.productId}'),
        tooltip: widget.enabled ? 'Add to cart' : 'Out of stock',
        onPressed: widget.enabled ? _handleTap : null,
        iconSize: 18,
        style: IconButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          disabledBackgroundColor: scheme.surfaceContainerHighest,
          minimumSize: const Size(38, 38),
        ),
        icon: const Icon(Icons.add_shopping_cart_rounded),
      ),
    );
  }
}