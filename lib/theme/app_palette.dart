import 'package:flutter/material.dart';

/// Theme-dependent colors, matching the CSS variables in src/styles/tailwind.css
/// (`:root` for light, `.dark` for dark).
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.background,
    required this.card,
    required this.muted,
    required this.foreground,
    required this.mutedForeground,
    required this.subtle,
    required this.border,
    required this.primaryText,
    required this.sidebarBg,
    required this.sidebarHover,
    required this.sidebarActive,
    required this.sidebarText,
    required this.sidebarTextActive,
    required this.sidebarBorder,
    required this.shimmerBase,
    required this.shimmerHighlight,
    required this.cardShadow,
    required this.cardHoverShadow,
  });

  final Color background;
  final Color card;
  final Color muted;
  final Color foreground;
  final Color mutedForeground;
  final Color subtle;
  final Color border;

  /// Accent-coloured text on a tinted accent background.
  final Color primaryText;

  final Color sidebarBg;
  final Color sidebarHover;
  final Color sidebarActive;
  final Color sidebarText;
  final Color sidebarTextActive;
  final Color sidebarBorder;

  final Color shimmerBase;
  final Color shimmerHighlight;

  final List<BoxShadow> cardShadow;
  final List<BoxShadow> cardHoverShadow;

  /// Light: white surfaces with black (#000000) for all text, icons and accents.
  /// Fills and borders are neutral greys, so no blue appears in light mode.
  static const light = AppPalette(
    background: Color(0xFFFFFFFF),
    card: Color(0xFFFFFFFF),
    muted: Color(0xFFF2F2F2),
    foreground: Color(0xFF000000),
    mutedForeground: Color(0xFF000000),
    subtle: Color(0xFF000000),
    border: Color(0xFFE2E2E2),
    primaryText: Color(0xFF000000),
    sidebarBg: Color(0xFFFFFFFF),
    sidebarHover: Color(0xFFF2F2F2),
    sidebarActive: Color(0xFFE6E6E6),
    sidebarText: Color(0xFF000000),
    sidebarTextActive: Color(0xFF000000),
    sidebarBorder: Color(0xFFE2E2E2),
    shimmerBase: Color(0xFFF0F0F0),
    shimmerHighlight: Color(0xFFFFFFFF),
    cardShadow: [
      BoxShadow(color: Color(0x14000000), blurRadius: 3, offset: Offset(0, 1)),
      BoxShadow(color: Color(0x0A000000), blurRadius: 12, offset: Offset(0, 4)),
    ],
    cardHoverShadow: [
      BoxShadow(color: Color(0x26000000), blurRadius: 16, offset: Offset(0, 6)),
    ],
  );

  static const dark = AppPalette(
    background: Color(0xFF0B1020),
    card: Color(0xFF141B30),
    muted: Color(0xFF1A2340),
    foreground: Color(0xFFE6E9F2),
    mutedForeground: Color(0xFF9AA5C4),
    subtle: Color(0xFF6B7694),
    border: Color(0xFF2A3558),
    primaryText: Color(0xFF6F89D8),
    sidebarBg: Color(0xFF080C18),
    sidebarHover: Color(0xFF141B30),
    sidebarActive: Color(0xFF2A3558),
    sidebarText: Color(0xFF9AA5C4),
    sidebarTextActive: Color(0xFFFFFFFF),
    sidebarBorder: Color(0xFF1E2A4A),
    shimmerBase: Color(0xFF1A2340),
    shimmerHighlight: Color(0xFF2A3558),
    cardShadow: [
      BoxShadow(color: Color(0x66000000), blurRadius: 3, offset: Offset(0, 1)),
    ],
    cardHoverShadow: [
      BoxShadow(color: Color(0x80000000), blurRadius: 16, offset: Offset(0, 6)),
    ],
  );

  @override
  AppPalette copyWith() => this;

  @override
  AppPalette lerp(covariant AppPalette? other, double t) =>
      other == null || t < 0.5 ? this : other;
}

extension AppPaletteContext on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>() ?? AppPalette.light;
}
