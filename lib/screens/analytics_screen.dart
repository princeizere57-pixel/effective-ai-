import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/charts.dart';
import '../widgets/common.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/progress_bar.dart';
import 'page_scaffold.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      builder: (context, width) => [
        FadeSlideIn(child: Text('Analytics', style: AppTheme.display(width >= 600 ? 34 : 28))),
        const SizedBox(height: 6),
        const Text(
          'How your study habits and scores are trending.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
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
                    const Text(
                      'Quiz score trend',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Up ${(quizScores.last - quizScores.first).toInt()} points in 8 weeks',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 24),
                    const SizedBox(height: 220, child: QuizTrendChart(scores: quizScores)),
                  ],
                ),
              ),
              const Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hours per day',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Wednesday is your strongest day',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                    SizedBox(height: 24),
                    SizedBox(height: 220, child: WeeklyHoursChart(data: weeklyHours)),
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
                const Text(
                  'Skill mastery',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
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
                              style: AppTheme.mono(12, color: AppColors.textSecondary),
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
