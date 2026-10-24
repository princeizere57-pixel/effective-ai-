import 'package:flutter/material.dart';

/// Effective AI uses one accent colour: bright blue (#335CFF), on a dark
/// background. Surfaces and borders come from `context.palette`.
abstract final class AppColors {
  /// The accent: bright blue (#335CFF).
  static const blue = Color(0xFF335CFF);

  /// Kept for the light palette; the same blue.
  static const lightAccent = blue;

  /// The accent for the theme on screen. The app is always dark and always blue,
  /// but widgets read it from here so it can change in one place.
  static Color brand = blue;

  /// Dark-theme surfaces only.
  static const navy = Color(0xFF0F1629);
  static const navyBorder = Color(0xFF2A3558);

  static Color accentFor(Brightness b) => blue;
}
/// Translucent fill behind an icon, pill or chip: the pale tile behind the
/// folder icon on Home, for example.
Color tint(Color color, [double alpha = 0.12]) => color.withValues(alpha: alpha);

abstract final class AppShadows {
  static List<BoxShadow> get brand => [
        BoxShadow(color: AppColors.brand.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 4)),
      ];
  static List<BoxShadow> get sidebar => [
        BoxShadow(color: AppColors.brand.withValues(alpha: 0.06), blurRadius: 24, offset: const Offset(4, 0)),
      ];
}

/// borderRadius tokens: `--radius` is 0.75rem (12px); the scale is built from it.
abstract final class AppRadius {
  static const base = 12.0;
  static const sm = base - 4;
  static const lg = base + 4;
  static const xl = base + 8;
  static const xl2 = base + 16;
}
