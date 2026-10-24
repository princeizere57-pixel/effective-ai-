import 'package:flutter/material.dart';

/// Light (the default) or dark. Changed from Settings or the sun/moon button on
/// the welcome page. There is no "follow the device" option.
///
/// Kept in memory; persist it (for example with shared_preferences) to remember
/// the choice between launches.
final themeMode = ValueNotifier<ThemeMode>(ThemeMode.light);

bool get isDarkMode => themeMode.value == ThemeMode.dark;

void toggleThemeMode() => themeMode.value = isDarkMode ? ThemeMode.light : ThemeMode.dark;
