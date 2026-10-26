import 'package:effective_ai/navigation.dart';
import 'package:effective_ai/screens/app_shell.dart';
import 'package:effective_ai/services/session.dart';
import 'package:effective_ai/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

/// Pages open straight away: no book loading screen when entering the app or
/// when moving between pages.
void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('Home opens on the first frame, and other pages open without a loading screen', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    startSection = AppSection.home;

    await tester.pumpWidget(MaterialApp(theme: AppTheme.light(), home: const AppShell()));
    await tester.pump();
    expect(find.text('Suggested for you'), findsOneWidget, reason: 'Home is showing on the first frame');
    expect(find.textContaining('Opening'), findsNothing, reason: 'no "Opening …" book loader');

    // Moving to another page: its content is there at once (sliding in with the page turn).
    await tester.tap(find.text('Settings').first);
    await tester.pump();
    expect(find.textContaining('Opening'), findsNothing);
    expect(find.text('Daily goal'), findsOneWidget, reason: 'Settings is already on screen');

    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Suggested for you'), findsNothing, reason: 'Home has turned away');
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
  });
}
