import 'package:effective_ai/main.dart';
import 'package:effective_ai/widgets/section_video_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

/// The landing page's section video backgrounds: each section gets the clip
/// cut for it from the story film, and shows its still frame where video
/// can't play (as in tests).
void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('How it works, Why you\'re wrong and Our mission each have their own clip', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const EffectiveAiApp(showIntro: false));
    await tester.pump();

    final clips = tester
        .widgetList<SectionVideoBackground>(find.byType(SectionVideoBackground))
        .map((w) => w.clip)
        .toList();
    expect(clips, ['how-it-works', 'why-youre-wrong', 'our-mission']);

    // Still frames stand in for the video here.
    for (final clip in clips) {
      expect(
        find.byWidgetPredicate(
            (w) => w is Image && w.image is AssetImage && (w.image as AssetImage).assetName == 'assets/video/$clip.jpg'),
        findsOneWidget,
      );
    }
    expect(find.text('One loop, built on your own course.'), findsOneWidget);
    expect(find.text('We find why you’re wrong, not just where.'), findsOneWidget);

    // Scrolling through the whole page with the backgrounds is fine.
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -20000));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
