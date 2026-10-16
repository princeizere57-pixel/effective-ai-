import 'package:flutter/material.dart';

/// Effective AI uses a two-colour identity: one accent colour and white.
/// Light mode uses Windows blue for every line of text and every icon; dark mode
/// keeps the original violet accents. Surfaces and borders come from `context.palette`.
abstract final class AppColors {
  /// Light-mode accent, the blue of the Windows logo.
  static const windowsBlue = Color(0xFF0078D4);

  /// Dark-mode accent, the logo violet.
  static const violet = Color(0xFF7C5CFC);

  /// The accent for the theme currently on screen. Set by the app whenever the
  /// theme changes (see `EffectiveAiApp` in main.dart), so it is not a constant.
  static Color brand = windowsBlue;

  /// Dark-theme surfaces only.
  static const navy = Color(0xFF0F1629);
  static const navyBorder = Color(0xFF2A3558);

  static Color accentFor(Brightness b) => b == Brightness.light ? windowsBlue : violet;
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
