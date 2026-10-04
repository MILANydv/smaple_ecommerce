import 'package:flutter/material.dart';

import '../../core/theme/app_tokens.dart';
import '../../models/product.dart';
import 'price_label.dart';
import 'product_visual.dart';
import 'rating_badge.dart';

/// Wide tile used in the "Featured" carousel on the home page.
class FeaturedCard extends StatelessWidget {
  const FeaturedCard({
    super.key,
    required this.product,
    required this.heroPrefix,
    required this.onTap,
    required this.onAddToCart,
  });

  final Product product;
  final String heroPrefix;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return SizedBox(
      width: 232,
      child: Card(
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
                        iconSize: 64,
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
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  product.stockLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: product.inStock
                        ? theme.colorScheme.onSurfaceVariant
                        : theme.colorScheme.error,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: PriceLabel(
                        product: product,
                        size: PriceSize.small,
                      ),
                    ),
                    IconButton.filledTonal(
                      key: Key('featured_add_${product.id}'),
                      tooltip: 'Add to cart',
                      onPressed: product.inStock ? onAddToCart : null,
                      iconSize: 18,
                      icon: const Icon(Icons.add_rounded),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}