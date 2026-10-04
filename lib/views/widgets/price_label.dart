import 'package:flutter/material.dart';

import '../../models/product.dart';

/// Price block: big price, strike through original price and the saving.
class PriceLabel extends StatelessWidget {
  const PriceLabel({
    super.key,
    required this.product,
    this.size = PriceSize.medium,
    this.color,
  });

  final Product product;
  final PriceSize size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color priceColor = color ?? theme.colorScheme.onSurface;
    final TextStyle? priceStyle = switch (size) {
      PriceSize.small => theme.textTheme.titleMedium,
      PriceSize.medium => theme.textTheme.titleLarge,
      PriceSize.large => theme.textTheme.headlineMedium,
    };
    final TextStyle? subStyle = switch (size) {
      PriceSize.small => theme.textTheme.labelSmall,
      PriceSize.medium => theme.textTheme.bodySmall,
      PriceSize.large => theme.textTheme.bodyMedium,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          product.priceLabel,
          style: priceStyle?.copyWith(
            color: priceColor,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        if (product.isOnSale)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                product.originalPriceLabel,
                style: subStyle?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  decoration: TextDecoration.lineThrough,
                  decorationThickness: 1.5,
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Save ${product.discountPercent}%',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: subStyle?.copyWith(
                    color: theme.colorScheme.tertiary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

enum PriceSize { small, medium, large }