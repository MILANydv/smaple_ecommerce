import 'package:flutter/material.dart';

/// Model: one onboarding page. Data only, the screen decides how to draw it.
@immutable
class OnboardingSlide {
  const OnboardingSlide({
    required this.title,
    required this.body,
    required this.icon,
    required this.colors,
  });

  final String title;
  final String body;
  final IconData icon;
  final List<Color> colors;

  LinearGradient get gradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: colors,
  );
}

/// The copy and the artwork of the first run experience.
const List<OnboardingSlide> kOnboardingSlides = <OnboardingSlide>[
  OnboardingSlide(
    title: 'The whole shop in one place',
    body:
        'Browse the catalog, jump between categories and sort by price or rating whenever you want.',
    icon: Icons.storefront_rounded,
    colors: <Color>[Color(0xFF4F46E5), Color(0xFF8B5CF6)],
  ),
  OnboardingSlide(
    title: 'A cart that remembers',
    body:
        'Add items while you browse, use a promo code at checkout and come back tomorrow: your cart is already there.',
    icon: Icons.shopping_bag_rounded,
    colors: <Color>[Color(0xFF06B6D4), Color(0xFF3B82F6)],
  ),
  OnboardingSlide(
    title: 'Checkout in three taps',
    body:
        'Free delivery over \$75, 30 day returns and a receipt the moment your order is placed.',
    icon: Icons.receipt_long_rounded,
    colors: <Color>[Color(0xFFF43F5E), Color(0xFFFB923C)],
  ),
];