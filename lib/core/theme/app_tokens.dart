import 'package:flutter/material.dart';

/// Spacing scale. Views never invent their own numbers, they pick a token.
abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  /// Horizontal page padding used by every screen.
  static const double page = 20;
}

/// Corner radius scale + the ready made shapes built from it.
abstract final class AppRadii {
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double pill = 999;

  static const BorderRadius chip = BorderRadius.all(Radius.circular(pill));
  static const BorderRadius control = BorderRadius.all(Radius.circular(md));
  static const BorderRadius card = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius hero = BorderRadius.all(Radius.circular(xl));
}

/// Motion tokens, so animation feels consistent across the app.
abstract final class AppMotion {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 280);
  static const Duration slow = Duration(milliseconds: 450);

  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;
  static const Curve emphasized = Curves.easeOutBack;
}

/// The single accent colour every theme is generated from.
const Color kBrandSeed = Color(0xFF4F46E5);

/// Gradient + icon used to paint a category. Keeps product art on brand
/// without shipping any image assets.
class CategoryStyle {
  const CategoryStyle({
    required this.label,
    required this.icon,
    required this.colors,
  });

  final String label;
  final IconData icon;
  final List<Color> colors;

  LinearGradient get gradient => LinearGradient(
    colors: colors,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  Color get accent => colors.first;
}

const Map<String, CategoryStyle> kCategoryStyles = <String, CategoryStyle>{
  'Audio': CategoryStyle(
    label: 'Audio',
    icon: Icons.headphones_rounded,
    colors: <Color>[Color(0xFF6366F1), Color(0xFF8B5CF6)],
  ),
  'Accessories': CategoryStyle(
    label: 'Accessories',
    icon: Icons.keyboard_rounded,
    colors: <Color>[Color(0xFF06B6D4), Color(0xFF3B82F6)],
  ),
  'Wearables': CategoryStyle(
    label: 'Wearables',
    icon: Icons.watch_rounded,
    colors: <Color>[Color(0xFFF43F5E), Color(0xFFFB923C)],
  ),
  'Home': CategoryStyle(
    label: 'Home',
    icon: Icons.lightbulb_rounded,
    colors: <Color>[Color(0xFFF59E0B), Color(0xFFEF4444)],
  ),
  'Bags': CategoryStyle(
    label: 'Bags',
    icon: Icons.backpack_rounded,
    colors: <Color>[Color(0xFF10B981), Color(0xFF14B8A6)],
  ),
};

const CategoryStyle kFallbackStyle = CategoryStyle(
  label: 'Other',
  icon: Icons.shopping_bag_rounded,
  colors: <Color>[Color(0xFF64748B), Color(0xFF475569)],
);

/// Product icons keyed by the `icon` field coming from the data source,
/// so the artwork follows the payload instead of only the category.
const Map<String, IconData> kProductIcons = <String, IconData>{
  'headphones': Icons.headphones_rounded,
  'keyboard': Icons.keyboard_rounded,
  'watch': Icons.watch_rounded,
  'mouse': Icons.mouse_rounded,
  'lamp': Icons.lightbulb_rounded,
  'backpack': Icons.backpack_rounded,
  'speaker': Icons.speaker_rounded,
  'camera': Icons.photo_camera_rounded,
  'shoes': Icons.ice_skating_rounded,
  'jacket': Icons.checkroom_rounded,
};

/// Looks a style up by category, falling back to a neutral palette.
CategoryStyle categoryStyleFor(String category) =>
    kCategoryStyles[category] ?? kFallbackStyle;

IconData productIconFor(String iconName) =>
    kProductIcons[iconName] ?? kFallbackStyle.icon;