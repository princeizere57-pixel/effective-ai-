import 'package:flutter/material.dart';

import '../data/knowledge.dart';
import '../data/mock_data.dart';
import '../navigation.dart';
import '../services/learner_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_palette.dart';
import '../theme/app_theme.dart';
import '../widgets/charts.dart';
import '../widgets/common.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/source_widgets.dart';
import 'page_scaffold.dart';
import 'study_session_screen.dart';

/// Features 28 and 30: Progress Memory and Personal Learning Report.
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key, required this.onNavigate});

  final ValueChanged<AppSection> onNavigate;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: learner,
      builder: (context, _) {
        final p = context.palette;
        const title = TextStyle(fontSize: 16, fontWeight: FontWeight.w700);
        return PageScaffold(
          builder: (context, width) => [
            const FadeSlideIn(
              child: PageHeader(
                title: 'My Progress',
                subtitle: 'What you know, what you don\'t yet, what to do next, and everything you have done so far.',
              ),
            ),
            const SizedBox(height: 20),
            FadeSlideIn(
              delay: const Duration(milliseconds: 60),
              child: _LearningReport(onNavigate: onNavigate),
            ),
            const SizedBox(height: 16),
            ResponsiveGrid(
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
                        style: TextStyle(color: p.mutedForeground, fontSize: 13),
                      ),
                      const SizedBox(height: 24),
                      const SizedBox(height: 200, child: QuizTrendChart(scores: quizScores)),
                    ],
                  ),
                ),
                Panel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Hours per day', style: title),
                      const SizedBox(height: 2),
                      Text('Wednesday is your strongest day', style: TextStyle(color: p.mutedForeground, fontSize: 13)),
                      const SizedBox(height: 24),
                      const SizedBox(height: 200, child: WeeklyHoursChart(data: weeklyHours)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Mastery by concept', style: title),
                  const SizedBox(height: 4),
                  for (final c in concepts) MasteryRow(concept: c),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Learning history', style: title),
                  const SizedBox(height: 4),
                  Text(
                    'Remembered across sessions: ${learner.history.length} activities, '
                    '${learner.mistakes.length} mistakes, ${learner.totalAnswers} answers.',
                    style: TextStyle(color: p.mutedForeground, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  for (final a in learner.history.take(12))
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Row(
                        children: [
                          Icon(a.kind.icon, size: 18, color: p.subtle),
                          const SizedBox(width: 12),
                          Expanded(child: Text(a.text)),
                          const SizedBox(width: 8),
                          Text(timeAgo(a.when), style: AppTheme.mono(11, color: p.subtle)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _LearningReport extends StatelessWidget {
  const _LearningReport({required this.onNavigate});

  final ValueChanged<AppSection> onNavigate;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final gaps = learner.gaps;
    final kinds = <QuestionKind, int>{};
    for (final m in learner.mistakes) {
      kinds.update(m.question.kind, (v) => v + 1, ifAbsent: () => 1);
    }
    final topKind = kinds.entries.isEmpty
        ? null
        : (kinds.entries.toList()..sort((a, b) => b.value.compareTo(a.value))).first.key;

    Widget column(String heading, Color color, List<Concept> list, String empty) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Flexible(child: Text('$heading (${list.length})', style: const TextStyle(fontWeight: FontWeight.w700))),
              ],
            ),
            const SizedBox(height: 8),
            if (list.isEmpty) Text(empty, style: TextStyle(color: p.subtle, fontSize: 13)),
            for (final c in list)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('${c.name} · ${percent(learner.mastery(c.id))}', style: const TextStyle(fontSize: 13)),
              ),
          ],
        );

    final next = <(String, VoidCallback)>[
      if (gaps.isNotEmpty)
        ('Run a study session on ${gaps.first.name}, your weakest concept', () => StudySessionScreen.open(context, gaps.first.id)),
      if (topKind != null)
        ('Practise ${topKind.label.toLowerCase()}: most of your mistakes are this type', () => onNavigate(AppSection.diagnose)),
      ('Sit a mock test to check exam readiness ($daysToExam days to go)', () => onNavigate(AppSection.exam)),
    ];

    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.description_outlined, color: AppColors.brand),
              const SizedBox(width: 10),
              Expanded(child: Text('Your learning report', style: AppTheme.display(22))),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'You know ${learner.strong.length} of ${concepts.length} concepts well. '
            '${gaps.length} still need work${gaps.isEmpty ? '' : ', starting with ${gaps.first.name}'}.',
            style: TextStyle(color: p.mutedForeground, height: 1.5),
          ),
          const SizedBox(height: 16),
          ResponsiveGrid(
            minItemWidth: 200,
            children: [
              column('Know well', AppColors.brand, learner.strong, 'Nothing yet'),
              column('Still learning', AppColors.brand, learner.learning, 'Nothing here'),
              column("Don't know yet", AppColors.brand, gaps, 'No gaps'),
            ],
          ),
          const SizedBox(height: 16),
          const Text('What to do next', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          for (var i = 0; i < next.length; i++)
            InkWell(
              borderRadius: BorderRadius.circular(AppRadius.base),
              onTap: next[i].$2,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Row(
                  children: [
                    CitationMarker(i + 1),
                    const SizedBox(width: 10),
                    Expanded(child: Text(next[i].$1)),
                    Icon(Icons.arrow_forward, size: 16, color: p.subtle),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
