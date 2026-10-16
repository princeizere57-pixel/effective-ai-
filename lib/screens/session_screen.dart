import 'package:flutter/material.dart';

import '../data/knowledge.dart';
import '../services/learner_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_palette.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/source_widgets.dart';
import 'page_scaffold.dart';
import 'study_session_screen.dart';

/// Feature 25: Study Session Workflow — select a topic, then learn, practise, test, review.
class SessionScreen extends StatelessWidget {
  const SessionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: learner,
      builder: (context, _) {
        final p = context.palette;
        final gaps = learner.gaps;
        final recommended = gaps.isNotEmpty ? gaps.first : concepts.first;
        final papers = learner.examFrequency(recommended.id);
        final recent = learner.history.where((a) => a.kind == ActivityKind.session).take(5).toList();

        return PageScaffold(
          builder: (context, width) => [
            const FadeSlideIn(
              child: PageHeader(
                title: 'Study Session',
                subtitle: 'Select a topic → learn → practise → test → review. About 15 minutes.',
              ),
            ),
            const SizedBox(height: 20),
            Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Pill(label: 'Recommended now', color: AppColors.violet),
                  const SizedBox(height: 12),
                  Text(recommended.name, style: AppTheme.display(26)),
                  const SizedBox(height: 6),
                  Text(
                    [
                      'Mastery ${percent(learner.mastery(recommended.id))}',
                      if (papers > 0) 'asked in $papers past paper${papers == 1 ? '' : 's'}',
                      '${passagesFor(recommended.id).length} sections in your library',
                    ].join(' · '),
                    style: TextStyle(color: p.mutedForeground),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => StudySessionScreen.open(context, recommended.id),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start session'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Or choose a topic', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  for (final c in concepts)
                    MasteryRow(
                      concept: c,
                      trailing: OutlinedButton(
                        onPressed: () => StudySessionScreen.open(context, c.id),
                        child: const Text('Start'),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Recent sessions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  if (recent.isEmpty) Text('None yet.', style: TextStyle(color: p.mutedForeground)),
                  for (final a in recent)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Icon(a.kind.icon, size: 18, color: p.subtle),
                          const SizedBox(width: 10),
                          Expanded(child: Text(a.text)),
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
