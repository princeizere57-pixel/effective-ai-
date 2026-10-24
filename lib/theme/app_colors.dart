import 'package:flutter/material.dart';

/// Effective AI's accent colour depends on the theme. Light mode: black
/// (#000000). Dark mode: a dark, styled navy with a soft glow: [navyFill] for
/// buttons and selected fills, [blue] (a lighter navy) for icons and accent
/// text so they stay readable. Surfaces and borders come from `context.palette`.
abstract final class AppColors {
  /// Dark-mode accent for icons and accent text: glowing navy.
  static const blue = Color(0xFF5A76D1);

  /// Dark-mode fill for buttons and selected items: deep navy.
  static const navyFill = Color(0xFF1E3A8A);

  /// The soft glow behind dark-mode icons and buttons.
  static const glow = Color(0x995A76D1);

  /// Light-mode accent: black.
  static const lightAccent = Color(0xFF000000);

  /// The accent for the theme on screen. Set by the app whenever the theme
  /// changes (see `EffectiveAiApp` in main.dart), so it is not a constant.
  static Color brand = lightAccent;

  /// Dark-theme surfaces only.
  static const navy = Color(0xFF0F1629);
  static const navyBorder = Color(0xFF2A3558);

  static Color accentFor(Brightness b) => b == Brightness.light ? lightAccent : blue;

  /// Button and selected-item fill for the theme.
  static Color fillFor(Brightness b) => b == Brightness.light ? lightAccent : navyFill;
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
