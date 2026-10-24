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
            child: _AccentScope(brightness: Theme.of(context).brightness, child: child!),
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

/// Keeps [AppColors.brand] in step with the theme on screen (black in light
/// mode, blue in dark mode). Widgets read the accent while building, so when the
/// theme changes every widget below is rebuilt, including const ones that do
/// not otherwise depend on the theme. State (the open page, scroll positions)
/// is kept.
class _AccentScope extends StatefulWidget {
  const _AccentScope({required this.brightness, required this.child});

  final Brightness brightness;
  final Widget child;

  @override
  State<_AccentScope> createState() => _AccentScopeState();
}

class _AccentScopeState extends State<_AccentScope> {
  @override
  void initState() {
    super.initState();
    AppColors.brand = AppColors.accentFor(widget.brightness);
  }

  @override
  void didUpdateWidget(_AccentScope old) {
    super.didUpdateWidget(old);
    if (old.brightness == widget.brightness) return;
    AppColors.brand = AppColors.accentFor(widget.brightness);
    void rebuild(Element e) {
      e.markNeedsBuild();
      e.visitChildren(rebuild);
    }

    (context as Element).visitChildren(rebuild);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
