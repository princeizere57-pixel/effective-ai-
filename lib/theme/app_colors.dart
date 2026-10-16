import 'package:flutter/material.dart';

/// Color tokens ported from tailwind.config.js.
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
  static const violetPale = Color(0xFFF0ECFF);
  static const violetMuted = Color(0xFFC4B5FD);

  // blue
  static const blue = Color(0xFF3B82F6);
  static const blueDark = Color(0xFF2563EB);
  static const blueLight = Color(0xFF60A5FA);
  static const bluePale = Color(0xFFEFF6FF);

  // synapse (status)
  static const green = Color(0xFF22C55E);
  static const greenPale = Color(0xFFF0FDF4);
  static const amber = Color(0xFFF59E0B);
  static const amberPale = Color(0xFFFFFBEB);
  static const red = Color(0xFFEF4444);
  static const redPale = Color(0xFFFEF2F2);

  // surfaces
  static const workspace = Color(0xFFF8F9FC);
  static const surface = Color(0xFFFFFFFF);

  // text and lines
  static const textPrimary = navy;
  static const textSecondary = Color(0xFF5B6478);
  static const textMuted = Color(0xFF8A93A8);
  static const divider = Color(0xFFE6E8F0);
}

/// Semantic tokens matching the CSS variables in tailwind.config.js
/// (light values from src/styles/tailwind.css in the Next.js project).
abstract final class AppTokens {
  static const background = AppColors.workspace;
  static const foreground = AppColors.navy;
  static const primary = AppColors.violet;
  static const primaryForeground = Colors.white;
  static const secondary = AppColors.violetPale;
  static const secondaryForeground = AppColors.violetDark;
  static const accent = AppColors.blue;
  static const accentForeground = Colors.white;
  static const muted = Color(0xFFF1F3F8);
  static const mutedForeground = AppColors.textSecondary;
  static const card = AppColors.surface;
  static const cardForeground = AppColors.navy;
  static const border = AppColors.divider;
  static const input = AppColors.divider;
  static const ring = AppColors.violet;

  static const success = AppColors.green;
  static const successBg = AppColors.greenPale;
  static const warning = AppColors.amber;
  static const warningBg = AppColors.amberPale;
  static const danger = AppColors.red;
  static const dangerBg = AppColors.redPale;
  static const info = AppColors.blue;
  static const infoBg = AppColors.bluePale;

  static const sidebarBg = AppColors.navy;
  static const sidebarHover = AppColors.navyLight;
  static const sidebarActive = AppColors.navyMuted;
  static const sidebarText = AppColors.navyText;
  static const sidebarTextActive = Colors.white;
  static const sidebarBorder = AppColors.navyBorder;
}

/// boxShadow tokens from tailwind.config.js.
abstract final class AppShadows {
  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x0F000000), blurRadius: 3, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x0A000000), blurRadius: 2, offset: Offset(0, 1)),
  ];
  static const List<BoxShadow> cardMd = [
    BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 4)),
  ];
  static const List<BoxShadow> cardLg = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 24, offset: Offset(0, 8)),
  ];
  static const List<BoxShadow> sidebar = [
    BoxShadow(color: Color(0x1F000000), blurRadius: 24, offset: Offset(4, 0)),
  ];

  /// Used when a card is hovered.
  static const cardHover = cardMd;
  static const List<BoxShadow> violet = [
    BoxShadow(color: Color(0x407C5CFC), blurRadius: 20, offset: Offset(0, 4)),
  ];
}

/// borderRadius tokens: `--radius` is 0.75rem (12px); the scale is built from it.
abstract final class AppRadius {
  static const base = 12.0;
  static const sm = base - 4;
  static const lg = base + 4;
  static const xl = base + 8;
  static const xl2 = base + 16;

  // Older names kept so existing widgets compile.
  static const xl3 = 24.0;
  static const xl4 = 32.0;
}
