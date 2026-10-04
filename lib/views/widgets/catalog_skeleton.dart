import 'package:flutter/material.dart';

import '../../core/theme/app_tokens.dart';

/// A pulsing placeholder used while the catalog is loading.
class SkeletonBox extends StatefulWidget {
  const SkeletonBox({
    super.key,
    this.height,
    this.width,
    this.borderRadius = AppRadii.card,
  });

  final double? height;
  final double? width;
  final BorderRadius borderRadius;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color base = Theme.of(
      context,
    ).colorScheme.surfaceContainerHighest;

    return FadeTransition(
      opacity: Tween<double>(begin: 0.45, end: 0.9).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          color: base,
          borderRadius: widget.borderRadius,
        ),
      ),
    );
  }
}

/// Grid of skeleton cards shaped like [ProductCard], so the layout does not
/// jump when the real data arrives.
class CatalogSkeleton extends StatelessWidget {
  const CatalogSkeleton({super.key, required this.itemCount});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        0,
        AppSpacing.page,
        AppSpacing.page,
      ),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 220,
          mainAxisExtent: 262,
          crossAxisSpacing: AppSpacing.sm,
          mainAxisSpacing: AppSpacing.sm,
        ),
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            return const SkeletonBox();
          },
          childCount: itemCount,
        ),
      ),
    );
  }
}