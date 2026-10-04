import 'package:flutter/material.dart';

import '../../core/theme/app_tokens.dart';

/// Gradient app mark, shared by the splash and all three account pages.
///
/// [animate] plays the scale and fade in once, which is what the splash wants;
/// the account pages keep it static so nothing moves under the user's eyes.
class BrandMark extends StatefulWidget {
  const BrandMark({
    super.key,
    this.size = 104,
    this.icon = Icons.storefront_rounded,
    this.animate = false,
  });

  final double size;

  final IconData icon;

  final bool animate;

  @override
  State<BrandMark> createState() => _BrandMarkState();
}

class _BrandMarkState extends State<BrandMark>
    with SingleTickerProviderStateMixin {
  /// Only created when [BrandMark.animate] is set: a static mark needs no
  /// ticker, and building one just to dispose it would tick after unmount.
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.animate) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 700),
      )..forward();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Widget mark = Container(
      height: widget.size,
      width: widget.size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            theme.colorScheme.primary,
            theme.colorScheme.tertiary,
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadii.xl),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.28),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Icon(
        widget.icon,
        size: widget.size * 0.5,
        color: Colors.white,
      ),
    );

    final AnimationController? controller = _controller;
    if (controller == null) return Center(child: mark);

    final Animation<double> curve = CurvedAnimation(
      parent: controller,
      curve: AppMotion.emphasized,
    );

    return Center(
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.4, end: 1).animate(curve),
        child: FadeTransition(opacity: controller, child: mark),
      ),
    );
  }
}

/// Soft coloured circle used to give a page some depth.
class Glow extends StatelessWidget {
  const Glow({
    super.key,
    required this.color,
    required this.size,
    this.opacity = 0.85,
  });

  final Color color;
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: <Color>[
              color.withValues(alpha: opacity),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}
