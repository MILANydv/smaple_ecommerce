import 'package:flutter/material.dart';

import '../../core/theme/app_tokens.dart';

/// Little progress bar that tells the customer how far they are from free
/// delivery. The bar animates whenever the cart total changes.
class FreeShippingMeter extends StatelessWidget {
  const FreeShippingMeter({
    super.key,
    required this.progress,
    required this.amountMissing,
    required this.thresholdLabel,
  });

  final double progress;
  final double? amountMissing;
  final String thresholdLabel;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool unlocked = amountMissing == null;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: unlocked
              ? <Color>[
                  theme.colorScheme.tertiaryContainer,
                  theme.colorScheme.primaryContainer,
                ]
              : <Color>[
                  theme.colorScheme.surfaceContainerHigh,
                  theme.colorScheme.surfaceContainerHighest,
                ],
        ),
        borderRadius: AppRadii.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                unlocked ? Icons.local_shipping_rounded : Icons.pedal_bike_rounded,
                size: 20,
                color: unlocked
                    ? theme.colorScheme.onTertiaryContainer
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  unlocked
                      ? 'Free delivery unlocked'
                      : 'Add ${_money(amountMissing!)} more for free delivery',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: unlocked
                        ? theme.colorScheme.onTertiaryContainer
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: progress),
            duration: AppMotion.slow,
            curve: AppMotion.enter,
            builder:
                (BuildContext context, double value, Widget? child) =>
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                      child: LinearProgressIndicator(
                        key: const Key('free_shipping_progress'),
                        value: value,
                        minHeight: 8,
                        backgroundColor: theme.colorScheme.surface,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          unlocked
                              ? theme.colorScheme.tertiary
                              : theme.colorScheme.primary,
                        ),
                      ),
                    ),
          ),
          const SizedBox(height: 6),
          Text(
            thresholdLabel,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  static String _money(double value) => '\$${value.toStringAsFixed(2)}';
}