import 'package:effective_ai/main.dart';
import 'package:effective_ai/widgets/effective_ai_splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

/// The launch intro: the emblem appears on a blue-white splash, then the real
/// app is revealed underneath and the splash leaves.
void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  setUp(EffectiveAiSplash.resetForTest);

  // The intro's emblem (the welcome page's own logo is smaller).
  final emblem = find.byWidgetPredicate(
    (w) => w is Image && w.width == EffectiveAiSplash.logoSize && w.image is AssetImage,
  );

  Future<void> launch(WidgetTester tester, {Size size = const Size(1440, 900)}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const EffectiveAiApp());
  }

  double appOpacity(WidgetTester tester) {
    final opacity = find.ancestor(of: find.byKey(const ValueKey('app')), matching: find.byType(Opacity));
    return opacity.evaluate().isEmpty ? 1 : tester.widget<Opacity>(opacity.first).opacity;
  }

  testWidgets('the emblem appears, then the app is revealed and the splash leaves', (tester) async {
    await launch(tester);
    expect(emblem, findsWidgets);
    expect((tester.widget<Image>(emblem.first).image as AssetImage).assetName, EffectiveAiSplash.logoAsset);
    expect(appOpacity(tester), 0, reason: 'the app is hidden at the start');

    await tester.pump(const Duration(milliseconds: 1000));
    expect(appOpacity(tester), inExclusiveRange(0, 1), reason: 'the app is fading in underneath');

    await tester.pump(const Duration(milliseconds: 600));
    expect(emblem, findsNothing, reason: 'the splash has left after about 1.5 s');
    expect(appOpacity(tester), 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('taps are held back only until the app starts to appear', (tester) async {
    await launch(tester);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.text('Log in').first, warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Welcome back'), findsNothing, reason: 'early taps are not passed to the hidden app');

    await tester.pump(const Duration(milliseconds: 1200));
    await tester.tap(find.text('Log in').first);
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Welcome back'), findsOneWidget, reason: 'the app is interactive after the intro');
  });

  testWidgets('it plays once per launch, not on every rebuild', (tester) async {
    await launch(tester);
    await tester.pump(const Duration(milliseconds: 1600));
    expect(emblem, findsNothing);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(const EffectiveAiApp());
    await tester.pump();
    expect(emblem, findsNothing);
    expect(appOpacity(tester), 1);
  });

  testWidgets('reduced motion: a still emblem and a short cross-fade', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await launch(tester);
    expect(emblem, findsWidgets);
    // The light sweep is the only srcATop mask (the headline's gradient text uses srcIn).
    expect(find.byWidgetPredicate((w) => w is ShaderMask && w.blendMode == BlendMode.srcATop), findsNothing,
        reason: 'no light sweep');
    await tester.pump(const Duration(milliseconds: 650));
    expect(emblem, findsNothing, reason: 'done in about 0.6 s');
    expect(appOpacity(tester), 1);
  });

  testWidgets('works on a phone-sized screen', (tester) async {
    await launch(tester, size: const Size(375, 812));
    await tester.pump(const Duration(milliseconds: 500));
    expect(emblem, findsWidgets);
    expect(tester.takeException(), isNull);
    await tester.pump(const Duration(milliseconds: 1100));
    expect(emblem, findsNothing);
  });
}
