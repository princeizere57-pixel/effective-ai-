import 'package:flutter/material.dart';

/// Effective AI uses a two-colour identity: the logo's violet and white.
/// Every icon, accent and line of text is [brand]; text on violet surfaces is white.
/// Surfaces, borders and the dark theme come from `context.palette`.
abstract final class AppColors {
  /// The logo violet: text, icons, buttons, charts.
  static const brand = Color(0xFF7C5CFC);

  /// Dark-theme surfaces only.
  static const navy = Color(0xFF0F1629);
  static const navyBorder = Color(0xFF2A3558);
}

/// Translucent fill behind an icon, pill or chip: the pale violet behind the
/// folder icon on Home, for example.
Color tint(Color color, [double alpha = 0.12]) => color.withValues(alpha: alpha);

abstract final class AppShadows {
  static const List<BoxShadow> brand = [
    BoxShadow(color: Color(0x337C5CFC), blurRadius: 20, offset: Offset(0, 4)),
  ];
  static const List<BoxShadow> sidebar = [
    BoxShadow(color: Color(0x0F7C5CFC), blurRadius: 24, offset: Offset(4, 0)),
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
