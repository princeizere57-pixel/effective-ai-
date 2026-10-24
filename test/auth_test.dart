import 'package:effective_ai/main.dart';
import 'package:effective_ai/services/auth_service.dart';
import 'package:effective_ai/services/current_user.dart';
import 'package:effective_ai/services/session.dart';
import 'package:effective_ai/theme/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

/// Sign-in from the welcome page: Google or email (demo mode, no backend keys).
void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  tearDown(() {
    signedIn.value = false;
    currentUser.value = AppUser.demo;
    themeMode.value = ThemeMode.light;
  });

  Future<void> openLogIn(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const EffectiveAiApp());
    await tester.pump();
    await tester.tap(find.text('Log in').first);
    await tester.pump(const Duration(milliseconds: 400));
  }

  // Lets the simulated sign-in finish and the app open, without waiting on its animations.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  testWidgets('Log in opens the sign-in screen with Google and email', (tester) async {
    expect(AuthService.instance.isDemo, isTrue);
    await openLogIn(tester);
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Forgot password?'), findsOneWidget);
    expect(find.textContaining('Demo mode'), findsOneWidget);
  });

  testWidgets('an invalid email shows an error and stays on the sign-in screen', (tester) async {
    await openLogIn(tester);
    await tester.enterText(find.byType(TextFormField).at(0), 'not-an-email');
    await tester.enterText(find.byType(TextFormField).at(1), 'secret');
    await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
    await tester.pump();
    expect(find.text('Enter a valid email address, like you@university.edu.'), findsOneWidget);
    expect(signedIn.value, isFalse);
  });

  testWidgets('signing up with email enters the app as that learner', (tester) async {
    await openLogIn(tester);
    await tester.tap(find.text('Create an account'));
    await tester.pump();
    expect(find.text('Create your account'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(0), 'Prince Izere');
    await tester.enterText(find.byType(TextFormField).at(1), 'prince@example.com');
    await tester.enterText(find.byType(TextFormField).at(2), 'longenough1');
    await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
    await settle(tester);
    expect(signedIn.value, isTrue);
    expect(currentUser.value.fullName, 'Prince Izere');
    expect(currentUser.value.email, 'prince@example.com');
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('Continue with Google enters the app', (tester) async {
    await openLogIn(tester);
    await tester.tap(find.text('Continue with Google'));
    await settle(tester);
    expect(signedIn.value, isTrue);
    expect(currentUser.value.email, AppUser.demo.email);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
  });

  test('a name is made from the email when none is given', () {
    expect(nameFromEmail('jane.doe@uni.ac.uk'), 'Jane Doe');
    expect(AppUser.fromEmail('sam_lee@x.io').firstName, 'Sam');
  });
}
