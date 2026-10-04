import 'package:flutter/material.dart';

import '../../core/theme/app_tokens.dart';

/// − value + control used on the cart lines and on the detail page.
/// [canDecrease] / [canIncrease] let the caller respect stock limits.
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.quantity,
    required this.onIncrease,
    required this.onDecrease,
    this.canDecrease = true,
    this.canIncrease = true,
    this.dense = false,
  });

  final int quantity;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final bool canDecrease;
  final bool canIncrease;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      padding: EdgeInsets.all(dense ? 2 : 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _StepButton(
            icon: quantity <= 1
                ? Icons.delete_outline_rounded
                : Icons.remove_rounded,
            tooltip: quantity <= 1 ? 'Remove' : 'Decrease',
            onPressed: canDecrease ? onDecrease : null,
            dense: dense,
          ),
          SizedBox(width: dense ? 6 : 10),
          AnimatedSwitcher(
            duration: AppMotion.fast,
            transitionBuilder: (Widget child, Animation<double> animation) =>
                FadeTransition(opacity: animation, child: child),
            child: Text(
              '$quantity',
              key: ValueKey<int>(quantity),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(width: dense ? 6 : 10),
          _StepButton(
            icon: Icons.add_rounded,
            tooltip: 'Increase',
            onPressed: canIncrease ? onIncrease : null,
            dense: dense,
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    required this.dense,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon),
      iconSize: dense ? 16 : 18,
      visualDensity: dense ? VisualDensity.compact : VisualDensity.standard,
      style: IconButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        minimumSize: Size(dense ? 30 : 36, dense ? 30 : 36),
        padding: EdgeInsets.zero,
      ),
    );
  }
}