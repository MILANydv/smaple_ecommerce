import 'package:flutter/material.dart';

import '../../core/theme/app_tokens.dart';

/// Animated page indicator for [PageView].
class PageDots extends StatelessWidget {
  const PageDots({
    super.key,
    required this.count,
    required this.activeIndex,
    this.onTap,
  });

  final int count;
  final int activeIndex;
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        for (int index = 0; index < count; index++)
          GestureDetector(
            key: Key('dot_$index'),
            onTap: onTap == null ? null : () => onTap!(index),
            child: AnimatedContainer(
              duration: AppMotion.medium,
              curve: AppMotion.enter,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 8,
              width: index == activeIndex ? 26 : 8,
              decoration: BoxDecoration(
                color: index == activeIndex
                    ? scheme.primary
                    : scheme.outlineVariant,
                borderRadius: AppRadii.chip,
              ),
            ),
          ),
      ],
    );
  }
}