import 'package:flutter/material.dart';

import '../../core/theme/app_tokens.dart';

/// Star + rating pill. [compact] renders it small enough to sit on artwork.
class RatingBadge extends StatelessWidget {
  const RatingBadge({
    super.key,
    required this.rating,
    this.compact = false,
    this.onDark = false,
  });

  final double rating;
  final bool compact;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color foreground = onDark
        ? Colors.white
        : theme.colorScheme.onSurface;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : AppSpacing.xs,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: onDark
            ? Colors.white24
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: AppRadii.chip,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFB300)),
          const SizedBox(width: 3),
          Text(
            rating.toStringAsFixed(1),
            style:
                (compact
                        ? theme.textTheme.labelSmall
                        : theme.textTheme.labelMedium)
                    ?.copyWith(color: foreground, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}