import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  /// Matches `cubic-bezier(0.16, 1, 0.3, 1)` used by the Tailwind animations.
  static const easeOutExpo = Cubic(0.16, 1, 0.3, 1);

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.violet,
        primary: AppColors.violet,
        surface: AppColors.surface,
      ),
      scaffoldBackgroundColor: AppColors.workspace,
    );

    return base.copyWith(
      textTheme: GoogleFonts.plusJakartaSansTextTheme(base.textTheme).apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      dividerColor: AppColors.divider,
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.navy,
      ),
    );
  }

  /// Fraunces display face (`font-fraunces`).
  static TextStyle display(double size, {Color color = AppColors.textPrimary}) {
    return GoogleFonts.fraunces(
      fontSize: size,
      fontWeight: FontWeight.w600,
      color: color,
      height: 1.15,
    );
  }

  /// JetBrains Mono (`font-mono`).
  static TextStyle mono(double size, {Color color = AppColors.textSecondary}) {
    return GoogleFonts.jetBrainsMono(fontSize: size, color: color);
  }
}
