import 'package:flutter/material.dart';

import '../navigation.dart';
import '../services/learner_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_palette.dart';
import 'common.dart';

class Suggestion {
  const Suggestion(this.icon, this.title, this.detail, this.section, this.color);

  final IconData icon;
  final String title;
  final String detail;
  final AppSection section;
  final Color color;
}

/// Suggestions that help a learner discover features, based on what they have
/// done and what they have not tried yet.
List<Suggestion> suggestionsFor(LearnerState s) {
  bool tried(AppSection a) => s.visited.contains(a.name);
  final gaps = s.gaps;
  final out = <Suggestion>[
    if (!s.diagnosticDone)
      const Suggestion(Icons.track_changes, 'Take the 4-minute diagnostic',
          'Eight questions from your materials show exactly where you stand.', AppSection.diagnose, AppColors.brand),
    if (gaps.isNotEmpty)
      Suggestion(Icons.school_outlined, 'Fix your weakest concept: ${gaps.first.name}',
          'A guided session: learn, practise, test and review.', AppSection.session, AppColors.brand),
    if (s.pastPaperCount > 0 && !tried(AppSection.exam))
      Suggestion(Icons.assignment_outlined, 'See what your ${s.pastPaperCount} past papers keep asking',
          'Recurring topics, question types and a prep plan.', AppSection.exam, AppColors.brand),
    if (!tried(AppSection.ask))
      Suggestion(Icons.forum_outlined, 'Ask a question across all ${s.indexedDocs.length} documents',
          'Every answer shows the page it came from.', AppSection.ask, AppColors.brand),
    if (!tried(AppSection.connections))
      const Suggestion(Icons.compare_arrows, 'Compare what your book and the paper say',
          'See agreements and contradictions about regularisation.', AppSection.connections, AppColors.brand),
    if (!tried(AppSection.practice))
      const Suggestion(Icons.psychology_outlined, 'Try Socratic mode',
          'Reason your way to the answer with guiding questions.', AppSection.practice, AppColors.brand),
    if (!tried(AppSection.plan))
      const Suggestion(Icons.calendar_month_outlined, 'Get your 7-day study plan',
          'Built from your gaps, past papers and daily goal.', AppSection.plan, AppColors.brand),
    if (!tried(AppSection.explain))
      const Suggestion(Icons.lightbulb_outline, 'Read a concept at your level',
          'Simplify or go deeper with one tap.', AppSection.explain, AppColors.brand),
    const Suggestion(Icons.insights, 'Read your personal learning report',
        'What you know, what you don\'t, and what to do next.', AppSection.progress, AppColors.brand),
  ];
  return out.take(4).toList();
}

class SuggestionsPanel extends StatelessWidget {
  const SuggestionsPanel({super.key, required this.onNavigate});

  final ValueChanged<AppSection> onNavigate;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return ResponsiveGrid(
      minItemWidth: 240,
      children: [
        for (final s in suggestionsFor(learner))
          Material(
            color: p.card,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              onTap: () => onNavigate(s.section),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: p.border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: tint(s.color),
                        borderRadius: BorderRadius.circular(AppRadius.base),
                      ),
                      child: Icon(s.icon, color: s.color, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(s.detail, style: TextStyle(color: p.mutedForeground, fontSize: 13)),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward, size: 18, color: p.subtle),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
