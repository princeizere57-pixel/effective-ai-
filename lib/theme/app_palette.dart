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

  /// Dark: a neutral dark-grey page (#161616) with near-black panels, black
  /// buttons and selected items, and white text and icons. No navy or blue.
  static const dark = AppPalette(
    background: Color(0xFF161616),
    card: Color(0xFF0A0A0A),
    muted: Color(0xFF0F0F0F),
    foreground: Color(0xFFF2F2F2),
    mutedForeground: Color(0xFFA8A8A8),
    subtle: Color(0xFF7A7A7A),
    border: Color(0xFF2A2A2A),
    primaryText: Color(0xFFFFFFFF),
    sidebarBg: Color(0xFF0A0A0A),
    sidebarHover: Color(0xFF1F1F1F),
    sidebarActive: Color(0xFF000000),
    sidebarText: Color(0xFFCFCFCF),
    sidebarTextActive: Color(0xFFFFFFFF),
    sidebarBorder: Color(0xFF222222),
    shimmerBase: Color(0xFF1F1F1F),
    shimmerHighlight: Color(0xFF2A2A2A),
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
