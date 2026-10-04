import 'package:flutter/material.dart';

import '../../controllers/onboarding_controller.dart';
import '../../controllers/shop_scope.dart';
import '../../core/theme/app_tokens.dart';
import '../../models/onboarding_slide.dart';
import '../widgets/page_dots.dart';

/// View: the first run experience.
///
/// The page the user is on lives in [OnboardingController], so the dots, the
/// button label and the stored flag can never disagree with each other.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goTo(int index) {
    _pageController.animateToPage(
      index,
      duration: AppMotion.medium,
      curve: AppMotion.enter,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final OnboardingController onboarding = ShopScope.of(context).onboarding;

    return Scaffold(
      key: const Key('onboarding_screen'),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: AppSpacing.xs),
                child: TextButton(
                  key: const Key('skip_onboarding'),
                  onPressed: onboarding.skip,
                  child: Text(onboarding.isFirstPage ? 'Skip' : 'Skip tour'),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: onboarding.pageCount,
                onPageChanged: onboarding.goTo,
                itemBuilder: (BuildContext context, int index) {
                  return _Slide(
                    slide: onboarding.slides[index],
                    page: index,
                    total: onboarding.pageCount,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.page,
              ),
              child: Column(
                children: <Widget>[
                  PageDots(
                    count: onboarding.pageCount,
                    activeIndex: onboarding.page,
                    onTap: _goTo,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: FilledButton.icon(
                          key: const Key('onboarding_next'),
                          onPressed: onboarding.isLastPage
                              ? onboarding.complete
                              // onPageChanged keeps the controller in sync
                              : () => _goTo(onboarding.page + 1),
                          icon: Icon(
                            onboarding.isLastPage
                                ? Icons.check_rounded
                                : Icons.arrow_forward_rounded,
                          ),
                          label: Text(
                            onboarding.isLastPage ? 'Get started' : 'Next',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Step ${onboarding.page + 1} of ${onboarding.pageCount}',
                    key: const Key('onboarding_step'),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One onboarding page: gradient artwork, title, body and a progress caption.
class _Slide extends StatelessWidget {
  const _Slide({required this.slide, required this.page, required this.total});

  final OnboardingSlide slide;
  final int page;
  final int total;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.page,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const SizedBox(height: AppSpacing.md),
          Container(
            height: 240,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: slide.gradient,
              borderRadius: AppRadii.hero,
            ),
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: AppRadii.hero,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: <Color>[
                          Colors.white.withValues(alpha: 0.25),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.18),
                        ],
                      ),
                    ),
                  ),
                ),
                Center(
                  child: TweenAnimationBuilder<double>(
                    key: Key('slide_icon_$page'),
                    tween: Tween<double>(begin: 0.6, end: 1),
                    duration: AppMotion.slow,
                    curve: AppMotion.emphasized,
                    builder:
                        (BuildContext context, double value, Widget? child) =>
                            Transform.scale(scale: value, child: child),
                    child: Icon(
                      slide.icon,
                      size: 104,
                      color: Colors.white,
                      shadows: const <Shadow>[
                        Shadow(
                          color: Color(0x40000000),
                          blurRadius: 20,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            slide.body,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}