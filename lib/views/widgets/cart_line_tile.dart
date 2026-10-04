import 'package:flutter/material.dart';

import '../../core/theme/app_tokens.dart';
import '../../models/cart_item.dart';
import 'product_visual.dart';
import 'quantity_stepper.dart';

/// One line in the cart. Swipe it away to remove, the screen puts it back when
/// the snack bar action is tapped.
class CartLineTile extends StatelessWidget {
  const CartLineTile({
    super.key,
    required this.item,
    required this.heroPrefix,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
    required this.onTap,
    this.canIncrease = true,
  });

  final CartItem item;
  final String heroPrefix;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;
  final VoidCallback onTap;
  final bool canIncrease;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Dismissible(
      key: ValueKey<String>('cart_line_${item.product.id}'),
      direction: DismissDirection.endToStart,
      background: _SwipeBackground(theme: theme, alignment: Alignment.centerRight),
      confirmDismiss: (DismissDirection direction) async {
        onRemove();
        return false;
      },
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadii.card,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: 68,
                  height: 68,
                  child: ProductVisual(
                    product: item.product,
                    heroTag: '$heroPrefix-${item.product.id}',
                    iconSize: 32,
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                    showDiscount: false,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              item.product.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            item.lineTotalLabel,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${item.product.priceLabel} each',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      QuantityStepper(
                        quantity: item.quantity,
                        dense: true,
                        canIncrease: canIncrease,
                        onIncrease: onIncrease,
                        onDecrease: onDecrease,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SwipeBackground extends StatelessWidget {
  const _SwipeBackground({required this.theme, required this.alignment});

  final ThemeData theme;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: AppRadii.card,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Icon(
            Icons.delete_outline_rounded,
            color: theme.colorScheme.onErrorContainer,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'Remove',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onErrorContainer,
            ),
          ),
        ],
      ),
    );
  }
}