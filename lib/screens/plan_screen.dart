import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../services/learner_state.dart';
import '../services/study_planner.dart';
import '../theme/app_colors.dart';
import '../theme/app_palette.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/progress_bar.dart';
import 'page_scaffold.dart';
import 'study_session_screen.dart';

/// Features 26 and 27: Study Plan Generator and Adaptive Study Plan.
class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: learner,
      builder: (context, _) {
        final p = context.palette;
        final plan = StudyPlanner.build(learner);
        final items = [for (final d in plan.days) ...d.items];
        final done = items.where((i) => learner.planDone.contains(i.key)).length;

        return PageScaffold(
          builder: (context, width) => [
            FadeSlideIn(
              child: PageHeader(
                title: 'My Plan',
                subtitle: 'Next 7 days, built from ${learner.gaps.length} gaps, ${learner.pastPaperCount} past papers, '
                    'your exam in $daysToExam days and a ${learner.dailyGoal}-minute daily goal.',
              ),
            ),
            const SizedBox(height: 20),
            Panel(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text('Daily goal', style: TextStyle(fontWeight: FontWeight.w700)),
                      SegmentedButton<int>(
                        segments: const [
                          ButtonSegment(value: 15, label: Text('15 min')),
                          ButtonSegment(value: 30, label: Text('30 min')),
                          ButtonSegment(value: 60, label: Text('60 min')),
                        ],
                        selected: {learner.dailyGoal},
                        showSelectedIcon: false,
                        onSelectionChanged: (s) => learner.setDailyGoal(s.first),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('This week', style: TextStyle(fontWeight: FontWeight.w700)),
                      const Spacer(),
                      Text('$done of ${items.length} done', style: AppTheme.mono(12, color: p.mutedForeground)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ProgressBar(value: items.isEmpty ? 0 : done / items.length, height: 8),
                  if (plan.unscheduled > 0) ...[
                    const SizedBox(height: 10),
                    Text(
                      '${plan.unscheduled} more sessions did not fit this week. Raise your daily goal to fit them in.',
                      style: TextStyle(color: p.mutedForeground, fontSize: 13),
                    ),
                  ],
                ],
              ),
            ),
            if (learner.planUpdates.isNotEmpty) ...[
              const SizedBox(height: 16),
              Panel(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.autorenew, color: AppColors.violet, size: 20),
                        SizedBox(width: 8),
                        Text('How your plan adapted', style: TextStyle(fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    for (final u in learner.planUpdates.take(4))
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text('• $u', style: TextStyle(color: p.mutedForeground, height: 1.45)),
                      ),
                  ],
                ),
              ),
            ],
            for (final day in plan.days) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 20, 0, 8),
                child: Row(
                  children: [
                    Text(
                      day.label.toUpperCase(),
                      style: AppTheme.mono(11, color: p.subtle).copyWith(letterSpacing: 1.2),
                    ),
                    const Spacer(),
                    Text('${day.minutes} min', style: AppTheme.mono(11, color: p.subtle)),
                  ],
                ),
              ),
              Panel(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  children: [
                    if (day.items.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text('Rest day', style: TextStyle(color: p.mutedForeground)),
                      ),
                    for (final item in day.items) _PlanTile(item: item),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _PlanTile extends StatelessWidget {
  const _PlanTile({required this.item});

  final PlanItem item;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final done = learner.planDone.contains(item.key);
    final (icon, color) = switch (item.kind) {
      PlanItemKind.study => (Icons.school_outlined, AppColors.violet),
      PlanItemKind.review => (Icons.replay, AppColors.green),
      PlanItemKind.mock => (Icons.timer_outlined, AppColors.amber),
    };
    return ListTile(
      leading: Checkbox(
        value: done,
        activeColor: AppColors.violet,
        onChanged: (_) => learner.togglePlanItem(item.key),
      ),
      title: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              item.title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: done ? p.subtle : null,
                decoration: done ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ],
      ),
      subtitle: Text('${item.minutes} min · ${item.reason}', style: TextStyle(color: p.mutedForeground, fontSize: 12)),
      trailing: item.conceptId != null && !done
          ? TextButton(
              onPressed: () => StudySessionScreen.open(context, item.conceptId!),
              child: const Text('Start'),
            )
          : null,
    );
  }
}
