import 'package:flutter/material.dart';

import 'screens/app_shell.dart';
import 'screens/welcome_screen.dart';
import 'services/session.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

void main() {
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
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: mode,
        home: ValueListenableBuilder<bool>(
          valueListenable: signedIn,
          builder: (context, inApp, _) => inApp ? const AppShell() : const WelcomeScreen(),
        ),
      ),
    );
  }
}
