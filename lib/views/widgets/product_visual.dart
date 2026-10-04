import 'package:flutter/material.dart';

import '../../core/theme/app_tokens.dart';
import '../../models/product.dart';

/// The artwork of a product: a gradient tile painted with the colours of its
/// category plus the icon from the payload. No image assets needed, and every
/// tile looks intentional.
///
/// Pass [heroTag] to animate the tile into the detail screen. The tag has to be
/// unique inside one route, so each list prefixes it differently.
class ProductVisual extends StatelessWidget {
  const ProductVisual({
    super.key,
    required this.product,
    this.heroTag,
    this.iconSize = 56,
    this.borderRadius = AppRadii.card,
    this.showDiscount = true,
  });

  final Product product;
  final String? heroTag;
  final double iconSize;
  final BorderRadius borderRadius;
  final bool showDiscount;

  @override
  Widget build(BuildContext context) {
    final CategoryStyle style = categoryStyleFor(product.category);
    final Widget tile = _Tile(
      product: product,
      style: style,
      iconSize: iconSize,
      borderRadius: borderRadius,
      showDiscount: showDiscount,
    );

    final String? tag = heroTag;
    if (tag == null) return tile;

    return Hero(
      tag: tag,
      flightShuttleBuilder:
          (
            BuildContext flightContext,
            Animation<double> animation,
            HeroFlightDirection direction,
            BuildContext fromContext,
            BuildContext toContext,
          ) => FadeTransition(opacity: animation, child: tile),
      child: tile,
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.product,
    required this.style,
    required this.iconSize,
    required this.borderRadius,
    required this.showDiscount,
  });

  final Product product;
  final CategoryStyle style;
  final double iconSize;
  final BorderRadius borderRadius;
  final bool showDiscount;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(gradient: style.gradient, borderRadius: borderRadius),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            const _Sheen(),
            Center(
              child: Icon(
                productIconFor(product.iconName),
                size: iconSize,
                color: Colors.white,
                shadows: const <Shadow>[
                  Shadow(color: Color(0x40000000), blurRadius: 16, offset: Offset(0, 6)),
                ],
              ),
            ),
            if (!product.inStock)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    borderRadius: borderRadius,
                  ),
                  child: const Center(
                    child: _Pill(
                      label: 'Sold out',
                      background: Colors.white24,
                      foreground: Colors.white,
                    ),
                  ),
                ),
              ),
            if (showDiscount && product.isOnSale && product.inStock)
              Positioned(
                top: AppSpacing.xs,
                left: AppSpacing.xs,
                child: _Pill(
                  label: '-${product.discountPercent}%',
                  background: Colors.white,
                  foreground: const Color(0xFFBE123C),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Diagonal light so the flat gradient gets a bit of depth.
class _Sheen extends StatelessWidget {
  const _Sheen();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Colors.white.withValues(alpha: 0.28),
            Colors.white.withValues(alpha: 0.02),
            Colors.black.withValues(alpha: 0.16),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadii.chip,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}