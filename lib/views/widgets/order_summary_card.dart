import 'package:flutter/material.dart';

import '../../controllers/cart_controller.dart';
import '../../core/theme/app_tokens.dart';

/// The money panel above the checkout button. Every number is read from
/// [CartController], the view only lays it out.
class OrderSummaryCard extends StatelessWidget {
  const OrderSummaryCard({
    super.key,
    required this.cart,
    this.onRemovePromo,
  });

  final CartController cart;
  final VoidCallback? onRemovePromo;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool hasDiscount = cart.discount > 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  Icons.receipt_long_rounded,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text('Order summary', style: theme.textTheme.titleSmall),
                const Spacer(),
                Text(
                  cart.itemCountLabel,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            const Divider(),
            const SizedBox(height: AppSpacing.xs),
            _Row(
              label: 'Subtotal',
              value: _money(cart.subtotal),
            ),
            if (hasDiscount)
              _Row(
                label: 'Promo ${cart.promoCode}',
                value: '-${_money(cart.discount)}',
                valueColor: theme.colorScheme.tertiary,
                onRemove: onRemovePromo,
              ),
            _Row(
              label: 'Delivery',
              value: cart.shipping == 0
                  ? 'Free'
                  : _money(cart.shipping),
              valueColor: cart.shipping == 0
                  ? theme.colorScheme.tertiary
                  : null,
            ),
            _Row(
              label: 'Tax (${(CartController.taxRate * 100).round()}%)',
              value: _money(cart.tax),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Divider(),
            ),
            Row(
              children: <Widget>[
                Text('Total', style: theme.textTheme.titleMedium),
                const Spacer(),
                Text(
                  _money(cart.total),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _money(double value) => '\$${value.toStringAsFixed(2)}';
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    this.valueColor,
    this.onRemove,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: <Widget>[
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          if (onRemove != null)
            InkWell(
              onTap: onRemove,
              borderRadius: BorderRadius.circular(AppRadii.pill),
              child: const Padding(
                padding: EdgeInsets.all(2),
                child: Icon(Icons.close_rounded, size: 14),
              ),
            ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}