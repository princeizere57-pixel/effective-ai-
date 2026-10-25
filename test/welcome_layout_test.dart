import 'package:effective_ai/main.dart';
import 'package:effective_ai/theme/app_colors.dart';
import 'package:effective_ai/theme/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  tearDown(() => themeMode.value = ThemeMode.light);

  // The landing page must lay out without overflow on phone, tablet and desktop, in both themes.
  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    for (final (name, size) in const [
      ('phone', Size(375, 800)),
      ('tablet', Size(800, 1000)),
      ('desktop', Size(1440, 900))
    ]) {
      testWidgets('welcome page lays out on $name in ${mode.name} mode', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        themeMode.value = mode;

        await tester.pumpWidget(const EffectiveAiApp(showIntro: false));
        await tester.pump();

        expect(find.text('Start your path to an A'), findsOneWidget);
        expect(find.text('One loop, built on your own course.'), findsOneWidget);
        expect(tester.takeException(), isNull);

        // Scroll to the bottom so every section is built and laid out.
        await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -20000));
        await tester.pump();
        expect(find.text('Help'), findsWidgets);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('the app opens white and the welcome page can switch to dark and back', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const EffectiveAiApp(showIntro: false));
    await tester.pump();
    Color background() => tester.widget<Scaffold>(find.byType(Scaffold).first).backgroundColor!;
    expect(themeMode.value, ThemeMode.light);
    expect(background(), Colors.white);
    expect(AppColors.brand, AppColors.lightAccent, reason: 'light mode accent is black');

    await tester.tap(find.byTooltip('Switch to dark'));
    await tester.pumpAndSettle();
    expect(themeMode.value, ThemeMode.dark);
    expect(background(), isNot(Colors.white));
    expect(AppColors.brand, AppColors.blue, reason: 'dark mode accent is blue');

    await tester.tap(find.byTooltip('Switch to light'));
    await tester.pumpAndSettle();
    expect(themeMode.value, ThemeMode.light);
    expect(background(), Colors.white);
  });
}
