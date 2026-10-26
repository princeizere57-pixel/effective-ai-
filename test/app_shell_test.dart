import 'package:effective_ai/navigation.dart';
import 'package:effective_ai/screens/app_shell.dart';
import 'package:effective_ai/screens/loading_view.dart';
import 'package:effective_ai/services/session.dart';
import 'package:effective_ai/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('entering from the landing page opens Home straight away, with no book animation', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    startSection = AppSection.home;

    await tester.pumpWidget(MaterialApp(theme: AppTheme.light(), home: const AppShell()));
    await tester.pump();
    expect(find.byType(LoadingView), findsNothing);
    expect(find.text('Suggested for you'), findsOneWidget, reason: 'Home is showing on the first frame');

    // Moving between pages inside the app still plays it.
    await tester.tap(find.text('My Library').first);
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(LoadingView), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
  });
}
