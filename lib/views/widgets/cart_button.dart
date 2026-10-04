import 'package:flutter/material.dart';

import '../../core/theme/app_tokens.dart';

/// App bar cart action. The count bubble swaps with a small pop animation, so
/// adding an item is acknowledged even when the grid is scrolled away.
class CartButton extends StatelessWidget {
  const CartButton({super.key, required this.count, required this.onPressed});

  final int count;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: const Key('open_cart'),
      tooltip: 'Cart',
      onPressed: onPressed,
      icon: _CartIcon(count: count),
    );
  }
}

class _CartIcon extends StatelessWidget {
  const _CartIcon({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final String label = count > 99 ? '99+' : '$count';

    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.only(right: 2, top: 2),
          child: Icon(Icons.shopping_bag_outlined),
        ),
        if (count > 0)
          Positioned(
            right: -6,
            top: -6,
            child: AnimatedSwitcher(
              duration: AppMotion.medium,
              switchInCurve: AppMotion.emphasized,
              transitionBuilder:
                  (Widget child, Animation<double> animation) =>
                      ScaleTransition(
                        scale: Tween<double>(
                          begin: 0.4,
                          end: 1,
                        ).animate(animation),
                        child: FadeTransition(opacity: animation, child: child),
                      ),
              child: Container(
                key: ValueKey<int>(count),
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                constraints: const BoxConstraints(minWidth: 18),
                decoration: BoxDecoration(
                  color: scheme.tertiary,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  border: Border.all(color: scheme.surface, width: 1.5),
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.onTertiary,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}