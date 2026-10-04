import 'package:flutter/material.dart';

import '../../controllers/boot_controller.dart';
import '../../controllers/shop_scope.dart';
import '../../core/theme/app_tokens.dart';

/// View: the splash screen shown while the app boots.
///
/// It starts the boot sequence (a minimum visible time plus the catalog
/// prefetch) and animates the brand mark in. The moment [BootController] says
/// it is ready, the root widget swaps this screen for the next one.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Kicks off loading. The controller ignores every call after the first.
    ShopScope.of(context).boot.start();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final BootController boot = ShopScope.of(context).boot;

    return Scaffold(
      key: const Key('splash_screen'),
      body: Stack(
        children: <Widget>[
          Positioned(
            top: -160,
            left: -80,
            child: _Glow(color: theme.colorScheme.primaryContainer),
          ),
          Positioned(
            bottom: -140,
            right: -100,
            child: _Glow(color: theme.colorScheme.tertiaryContainer),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.page),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Spacer(),
                  const _BrandMark(),
                  const SizedBox(height: AppSpacing.lg),
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: AppMotion.slow,
                    curve: AppMotion.enter,
                    builder:
                        (BuildContext context, double value, Widget? child) =>
                            Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, 16 * (1 - value)),
                                child: child,
                              ),
                            ),
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Shop',
                          style: theme.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          'Small catalog, big cart',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  _BootProgress(ready: boot.isReady),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Made with Flutter',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Determinate ring: creeps towards three quarters while booting and fills up
/// completely the moment the app is ready.
class _BootProgress extends StatelessWidget {
  const _BootProgress({required this.ready});

  final bool ready;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      children: <Widget>[
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.04, end: ready ? 1 : 0.78),
          duration: AppMotion.slow,
          curve: AppMotion.enter,
          builder:
              (BuildContext context, double value, Widget? child) =>
                  SizedBox(
                    height: 34,
                    width: 34,
                    child: CircularProgressIndicator(
                      key: const Key('splash_progress'),
                      value: value,
                      strokeWidth: 3,
                      strokeCap: StrokeCap.round,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    ),
                  ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          ready ? 'Ready' : 'Preparing your catalog',
          key: const Key('splash_caption'),
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Gradient app mark that scales in once.
class _BrandMark extends StatefulWidget {
  const _BrandMark();

  @override
  State<_BrandMark> createState() => _BrandMarkState();
}

class _BrandMarkState extends State<_BrandMark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Animation<double> curve = CurvedAnimation(
      parent: _controller,
      curve: AppMotion.emphasized,
    );

    return ScaleTransition(
      scale: Tween<double>(begin: 0.4, end: 1).animate(curve),
      child: FadeTransition(
        opacity: _controller,
        child: Container(
          height: 128,
          width: 128,
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
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 32,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: const Icon(
            Icons.storefront_rounded,
            size: 64,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        height: 320,
        width: 320,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: <Color>[color.withValues(alpha: 0.85), Colors.transparent],
          ),
        ),
      ),
    );
  }
}