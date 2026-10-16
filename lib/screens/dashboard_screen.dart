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
import '../widgets/stat_card.dart';
import '../widgets/suggestions.dart';
import 'page_scaffold.dart';
import 'study_session_screen.dart';

/// Home: summary, suggestions (feature 32), the pipeline and what to fix next.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.onNavigate});

  final ValueChanged<AppSection> onNavigate;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: learner,
      builder: (context, _) {
        final stats = [
          Stat(label: 'Documents in your library', value: '${learner.docs.length}', icon: Icons.folder_copy_outlined, color: AppColors.violet),
          Stat(label: 'Concepts mastered', value: '${learner.strong.length}/${concepts.length}', icon: Icons.workspace_premium_outlined, color: AppColors.green),
          Stat(label: 'Gaps to fix', value: '${learner.gaps.length}', icon: Icons.track_changes, color: AppColors.red),
          const Stat(label: 'Day streak', value: '$streakDays', delta: '+3', icon: Icons.local_fire_department_outlined, color: AppColors.amber),
        ];
        return PageScaffold(
          builder: (context, width) => [
            FadeSlideIn(child: _Header(wide: width >= 900)),
            const SizedBox(height: 24),
            FadeSlideIn(
              delay: const Duration(milliseconds: 80),
              child: ResponsiveGrid(minItemWidth: 200, children: [for (final s in stats) StatCard(stat: s)]),
            ),
            const SizedBox(height: 32),
            const SectionHeader(title: 'Suggested for you'),
            const SizedBox(height: 12),
            FadeSlideIn(
              delay: const Duration(milliseconds: 140),
              child: SuggestionsPanel(onNavigate: onNavigate),
            ),
            const SizedBox(height: 32),
            const SectionHeader(title: 'From your materials to results'),
            const SizedBox(height: 12),
            FadeSlideIn(
              delay: const Duration(milliseconds: 200),
              child: _Pipeline(onNavigate: onNavigate),
            ),
            const SizedBox(height: 32),
            FadeSlideIn(
              delay: const Duration(milliseconds: 260),
              child: width >= 900
                  ? const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: _FixNextPanel()),
                        SizedBox(width: 16),
                        Expanded(flex: 2, child: _DeadlinesPanel()),
                      ],
                    )
                  : const Column(children: [_FixNextPanel(), SizedBox(height: 16), _DeadlinesPanel()]),
            ),
            const SizedBox(height: 16),
            const _StudyTimePanel(),
          ],
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.wide});

  final bool wide;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Good morning, $userFirstName', style: AppTheme.display(wide ? 34 : 28)),
        const SizedBox(height: 6),
        Text(
          'Your exam is in $daysToExam days. You have ${learner.gaps.length} gaps to close and a $streakDays-day streak to keep.',
          style: TextStyle(color: p.mutedForeground, fontSize: 15),
        ),
      ],
    );
  }
}

class _Pipeline extends StatelessWidget {
  const _Pipeline({required this.onNavigate});

  final ValueChanged<AppSection> onNavigate;

  static const _steps = <(IconData, String, String, AppSection, Color)>[
    (Icons.folder_copy_outlined, 'Your data', 'Books, notes, slides, papers and past exams in one private library', AppSection.library, AppColors.violet),
    (Icons.forum_outlined, 'Navigate', 'Ask, search and explore with sources for every answer', AppSection.ask, AppColors.blue),
    (Icons.lightbulb_outline, 'Understand', 'Explain at your level, connect and compare ideas', AppSection.explain, AppColors.amber),
    (Icons.track_changes, 'Improve', 'Find gaps and mistakes, then practise exactly those', AppSection.diagnose, AppColors.red),
    (Icons.assignment_outlined, 'Apply', 'Past papers, mock tests and study sessions', AppSection.exam, AppColors.green),
    (Icons.insights, 'Measure', 'Your plan adapts and your report shows progress', AppSection.progress, AppColors.violetLight),
  ];

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return ResponsiveGrid(
      minItemWidth: 180,
      children: [
        for (final (icon, title, text, section, color) in _steps)
          Material(
            color: p.card,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              onTap: () => onNavigate(section),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(color: tint(color), borderRadius: BorderRadius.circular(AppRadius.base)),
                      child: Icon(icon, color: color, size: 20),
                    ),
                    const SizedBox(height: 12),
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(text, style: TextStyle(color: p.mutedForeground, fontSize: 12, height: 1.4)),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _FixNextPanel extends StatelessWidget {
  const _FixNextPanel();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final gaps = learner.gaps.take(3).toList();
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Fix next', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text('Your weakest concepts, from every answer so far', style: TextStyle(color: p.mutedForeground, fontSize: 13)),
          const SizedBox(height: 6),
          if (gaps.isEmpty) Text('No gaps right now.', style: TextStyle(color: p.mutedForeground)),
          for (final c in gaps)
            MasteryRow(
              concept: c,
              trailing: FilledButton.tonal(
                onPressed: () => StudySessionScreen.open(context, c.id),
                child: const Text('Fix'),
              ),
            ),
        ],
      ),
    );
  }
}

class _StudyTimePanel extends StatelessWidget {
  const _StudyTimePanel();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final total = weeklyHours.fold<double>(0, (sum, d) => sum + d.$2);
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Study time', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text('${total.toStringAsFixed(1)} hours this week', style: TextStyle(color: p.mutedForeground, fontSize: 13)),
                  ],
                ),
              ),
              const Pill(label: '+18% vs last week', color: AppColors.green),
            ],
          ),
          const SizedBox(height: 24),
          const SizedBox(height: 200, child: WeeklyHoursChart(data: weeklyHours)),
        ],
      ),
    );
  }
}

class _DeadlinesPanel extends StatelessWidget {
  const _DeadlinesPanel();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Upcoming', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          for (final d in deadlines)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(color: _color(d.status), shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          d.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: d.status == DeadlineStatus.done ? p.subtle : null,
                            decoration: d.status == DeadlineStatus.done ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        Text(d.course, style: TextStyle(color: p.mutedForeground, fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Pill(label: d.due, color: _color(d.status)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  static Color _color(DeadlineStatus s) => switch (s) {
        DeadlineStatus.overdue => AppColors.red,
        DeadlineStatus.soon => AppColors.amber,
        DeadlineStatus.upcoming => AppColors.blue,
        DeadlineStatus.done => AppColors.green,
      };
}
