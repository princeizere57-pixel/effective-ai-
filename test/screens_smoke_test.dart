import 'package:effective_ai/navigation.dart';
import 'package:effective_ai/screens/app_shell.dart';
import 'package:effective_ai/services/session.dart';
import 'package:effective_ai/theme/app_colors.dart';
import 'package:effective_ai/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

/// Opens every screen of the app at phone, tablet and desktop width and checks
/// that it builds and lays out without errors (no exceptions, no overflow).
void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    AppColors.brand = AppColors.lightAccent;
  });

  const sizes = {'phone': Size(375, 812), 'tablet': Size(800, 1100), 'desktop': Size(1440, 900)};

  for (final (themeName, theme) in [('light', AppTheme.light), ('dark', AppTheme.dark)]) {
    for (final MapEntry(key: name, value: size) in sizes.entries) {
      for (final section in AppSection.values) {
        testWidgets('${section.name} on $name ($themeName)', (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);

          startSection = section;
          AppColors.brand = themeName == 'dark' ? AppColors.blue : AppColors.lightAccent;
          await tester.pumpWidget(MaterialApp(theme: theme(), home: const AppShell()));
          // Past the page-turn animation.
          await tester.pump(const Duration(seconds: 1));
          await tester.pump(const Duration(seconds: 1));
          expect(tester.takeException(), isNull);

          // Scroll to the bottom so the whole page is built and laid out.
          final scrollables = find.byType(Scrollable);
          if (scrollables.evaluate().isNotEmpty) {
            await tester.drag(scrollables.first, const Offset(0, -6000), warnIfMissed: false);
            await tester.pump(const Duration(milliseconds: 500));
          }
          expect(tester.takeException(), isNull);

          // Unmount so timers and animations are disposed before the test ends.
          await tester.pumpWidget(const SizedBox());
          await tester.pump(const Duration(seconds: 2));
        });
      }
    }
  }
}
