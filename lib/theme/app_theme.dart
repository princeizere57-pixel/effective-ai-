import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_palette.dart';

abstract final class AppTheme {
  /// Matches `cubic-bezier(0.16, 1, 0.3, 1)` used by the Tailwind animations.
  static const easeOutExpo = Cubic(0.16, 1, 0.3, 1);

  static ThemeData light() => _build(Brightness.light, AppPalette.light);

  static ThemeData dark() => _build(Brightness.dark, AppPalette.dark);

  static ThemeData _build(Brightness brightness, AppPalette p) {
    final isLight = brightness == Brightness.light;
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.brand,
      brightness: brightness,
      primary: AppColors.brand,
      onPrimary: Colors.white,
      surface: p.card,
      onSurface: p.foreground,
      onSurfaceVariant: p.mutedForeground,
      secondaryContainer: tint(AppColors.brand, 0.14),
      onSecondaryContainer: p.primaryText,
      outline: p.border,
      outlineVariant: p.border,
    );
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: p.background,
      dividerColor: p.border,
      extensions: [p],
    );

    return base.copyWith(
      textTheme: GoogleFonts.plusJakartaSansTextTheme(base.textTheme).apply(
        bodyColor: p.foreground,
        displayColor: p.foreground,
      ),
      iconTheme: IconThemeData(color: p.foreground),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isLight ? AppColors.brand : AppColors.navyBorder,
        contentTextStyle: const TextStyle(color: Colors.white),
      ),
    );
  }

  /// Fraunces display face (`font-fraunces`). Inherits the text color unless one is given.
  static TextStyle display(double size, {Color? color}) {
    return GoogleFonts.fraunces(
      fontSize: size,
      fontWeight: FontWeight.w600,
      color: color,
      height: 1.15,
    );
  }

  /// JetBrains Mono (`font-mono`).
  static TextStyle mono(double size, {Color? color}) {
    return GoogleFonts.jetBrainsMono(fontSize: size, color: color);
  }
}
