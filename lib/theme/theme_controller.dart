import 'package:flutter/material.dart';

/// Light, dark or follow the device. Changed from Settings.
///
/// Kept in memory; persist it (for example with shared_preferences) to remember
/// the choice between launches.
final themeMode = ValueNotifier<ThemeMode>(ThemeMode.light);
