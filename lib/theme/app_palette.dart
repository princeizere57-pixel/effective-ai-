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

  /// Violet text on a tinted violet background.
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

  /// Two colours: white surfaces and bright blue (#335CFF) for all text and icons.
  /// Fills and borders are pale tints of that same blue.
  static const light = AppPalette(
    background: Color(0xFFFFFFFF),
    card: Color(0xFFFFFFFF),
    muted: Color(0xFFF0F3FF),
    foreground: Color(0xFF335CFF),
    mutedForeground: Color(0xFF335CFF),
    subtle: Color(0xFF335CFF),
    border: Color(0xFFDCE3FF),
    primaryText: Color(0xFF335CFF),
    sidebarBg: Color(0xFFFFFFFF),
    sidebarHover: Color(0xFFF0F3FF),
    sidebarActive: Color(0xFFE3E9FF),
    sidebarText: Color(0xFF335CFF),
    sidebarTextActive: Color(0xFF335CFF),
    sidebarBorder: Color(0xFFDCE3FF),
    shimmerBase: Color(0xFFE9EEFF),
    shimmerHighlight: Color(0xFFFFFFFF),
    cardShadow: [
      BoxShadow(color: Color(0x14335CFF), blurRadius: 3, offset: Offset(0, 1)),
      BoxShadow(color: Color(0x0A335CFF), blurRadius: 12, offset: Offset(0, 4)),
    ],
    cardHoverShadow: [
      BoxShadow(color: Color(0x26335CFF), blurRadius: 16, offset: Offset(0, 6)),
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
    primaryText: Color(0xFFC4B5FD),
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
