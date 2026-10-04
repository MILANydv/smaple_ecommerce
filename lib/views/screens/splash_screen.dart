import 'package:flutter/material.dart';

import '../../controllers/boot_controller.dart';
import '../../controllers/shop_scope.dart';
import '../../core/theme/app_tokens.dart';
import '../widgets/brand_mark.dart';

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
            child: Glow(color: theme.colorScheme.primaryContainer, size: 320),
          ),
          Positioned(
            bottom: -140,
            right: -100,
            child: Glow(
              color: theme.colorScheme.tertiaryContainer,
              size: 320,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.page),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Spacer(),
                  const BrandMark(size: 128, animate: true),
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
