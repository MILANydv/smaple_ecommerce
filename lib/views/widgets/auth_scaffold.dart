import 'package:flutter/material.dart';

import '../../core/theme/app_tokens.dart';
import 'brand_mark.dart';

/// View helper: the frame shared by sign in, register and forgot password.
///
/// It owns the background glows, the brand mark, the page title and the top bar
/// with the back button, so the three account pages only differ in the form
/// they put in [child].
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.footer,
    this.trailing,
    this.onBack,
  });

  /// Page headline, for example "Welcome to Shop".
  final String title;

  /// One line explaining what the page is for.
  final String subtitle;

  /// The form itself: fields, buttons, anything page specific.
  final Widget child;

  /// Optional block under the form, usually the links to the other pages.
  final Widget? footer;

  /// Optional action in the top bar.
  final Widget? trailing;

  /// When null the back button is hidden, which is what sign in wants.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned(
            top: -140,
            right: -90,
            child: Glow(color: scheme.primaryContainer, size: 320),
          ),
          Positioned(
            top: 120,
            left: -120,
            child: Glow(color: scheme.tertiaryContainer, size: 260),
          ),
          SafeArea(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: AppSpacing.xxs,
                  ),
                  child: Row(
                    children: <Widget>[
                      if (onBack != null)
                        IconButton(
                          key: const Key('auth_back_button'),
                          tooltip: 'Back',
                          onPressed: onBack,
                          icon: const Icon(Icons.arrow_back_rounded),
                        )
                      else
                        const SizedBox(width: AppSpacing.page),
                      const Spacer(),
                      ?trailing,
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.md,
                      AppSpacing.lg,
                      AppSpacing.lg,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 440),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            const BrandMark(size: 96),
                            const SizedBox(height: AppSpacing.lg),
                            Text(
                              title,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineSmall,
                            ),
                            const SizedBox(height: AppSpacing.xxs),
                            Text(
                              subtitle,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            child,
                            if (footer != null) ...<Widget>[
                              const SizedBox(height: AppSpacing.lg),
                              footer!,
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
