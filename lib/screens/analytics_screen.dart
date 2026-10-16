import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../theme/app_palette.dart';
import '../theme/app_theme.dart';
import '../widgets/charts.dart';
import '../widgets/common.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/progress_bar.dart';
import 'page_scaffold.dart';

/// "My Progress": quiz trend, hours per day and skill mastery.
class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    const title = TextStyle(fontSize: 16, fontWeight: FontWeight.w700);
    final sub = TextStyle(color: p.mutedForeground, fontSize: 13);

    return PageScaffold(
      builder: (context, width) => [
        const FadeSlideIn(
          child: PageHeader(
            title: 'My Progress',
            subtitle: 'How your study habits and scores are trending.',
          ),
        ),
        const SizedBox(height: 24),
        FadeSlideIn(
          delay: const Duration(milliseconds: 80),
          child: ResponsiveGrid(
            minItemWidth: 340,
            children: [
              Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Quiz score trend', style: title),
                    const SizedBox(height: 2),
                    Text(
                      'Up ${(quizScores.last - quizScores.first).toInt()} points in 8 weeks',
                      style: sub,
                    ),
                    const SizedBox(height: 24),
                    const SizedBox(height: 220, child: QuizTrendChart(scores: quizScores)),
                  ],
                ),
              ),
              Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Hours per day', style: title),
                    const SizedBox(height: 2),
                    Text('Wednesday is your strongest day', style: sub),
                    const SizedBox(height: 24),
                    const SizedBox(height: 220, child: WeeklyHoursChart(data: weeklyHours)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FadeSlideIn(
          delay: const Duration(milliseconds: 160),
          child: Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Skill mastery', style: title),
                const SizedBox(height: 16),
                for (final s in skills)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              s.name,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                            const Spacer(),
                            Text(
                              '${(s.mastery * 100).round()}%',
                              style: AppTheme.mono(12, color: p.mutedForeground),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ProgressBar(value: s.mastery, color: s.color, height: 8),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
