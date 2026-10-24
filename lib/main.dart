import 'package:flutter/material.dart';

import 'screens/app_shell.dart';
import 'screens/welcome_screen.dart';
import 'services/session.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

/// All text is drawn at this fraction of its designed size.
const textScale = 0.9;

void main() {
  // Bright blue accent in both themes.
  AppColors.brand = AppColors.blue;
  runApp(const EffectiveAiApp());
}

class EffectiveAiApp extends StatelessWidget {
  const EffectiveAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeMode,
      builder: (context, mode, _) => MaterialApp(
        title: 'Effective AI',
        debugShowCheckedModeBanner: false,
        // White by default; dark only when the learner chooses it.
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: mode,
        builder: (context, child) {
          final media = MediaQuery.of(context);
          return MediaQuery(
            data: media.copyWith(textScaler: TextScaler.linear(media.textScaler.scale(1) * textScale)),
            child: child!,
          );
        },
        home: ValueListenableBuilder<bool>(
          valueListenable: signedIn,
          builder: (context, inApp, _) => inApp ? const AppShell() : const WelcomeScreen(),
        ),
      ),
    );
  }
}
