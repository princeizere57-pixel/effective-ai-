import 'package:flutter/material.dart';

/// Brand and status colors from tailwind.config.js. They read well in both themes.
/// Surfaces, text and borders change with the theme: use `context.palette` for those.
abstract final class AppColors {
  // navy
  static const navy = Color(0xFF0F1629);
  static const navyLight = Color(0xFF1A2340);
  static const navyLighter = Color(0xFF1E2A4A);
  static const navyBorder = Color(0xFF2A3558);
  static const navyMuted = Color(0xFF3D4F7A);
  static const navyText = Color(0xFF9AA5C4);

  // violet
  static const violet = Color(0xFF7C5CFC);
  static const violetDark = Color(0xFF6344E8);
  static const violetLight = Color(0xFF9B7FFD);
  static const violetMuted = Color(0xFFC4B5FD);

  // blue
  static const blue = Color(0xFF3B82F6);
  static const blueDark = Color(0xFF2563EB);
  static const blueLight = Color(0xFF60A5FA);

  // status
  static const green = Color(0xFF22C55E);
  static const amber = Color(0xFFF59E0B);
  static const red = Color(0xFFEF4444);
}

/// Translucent fill behind a colored icon, pill or chip. Works on light and dark surfaces.
Color tint(Color color, [double alpha = 0.14]) => color.withValues(alpha: alpha);

abstract final class AppShadows {
  static const List<BoxShadow> violet = [
    BoxShadow(color: Color(0x407C5CFC), blurRadius: 20, offset: Offset(0, 4)),
  ];
  static const List<BoxShadow> sidebar = [
    BoxShadow(color: Color(0x1F000000), blurRadius: 24, offset: Offset(4, 0)),
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
