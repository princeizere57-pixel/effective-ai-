import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_palette.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/fade_slide_in.dart';
import 'page_scaffold.dart';

/// Practice sets waiting for the learner; each opens a quick question.
class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  /// Index of a practice set → whether the answer was correct.
  final _results = <int, bool>{};

  Future<void> _start(int index) async {
    final correct = await showDialog<bool>(
      context: context,
      builder: (_) => _QuestionDialog(set: practiceSets[index]),
    );
    if (correct == null || !mounted) return;
    setState(() => _results[index] = correct);
    showToast(context, correct ? 'Correct, nice work' : 'Not quite. Review this topic next.');
  }

  @override
  Widget build(BuildContext context) {
    final pending = practiceSets.length - _results.length;

    return PageScaffold(
      builder: (context, width) => [
        FadeSlideIn(
          child: PageHeader(
            title: 'Practice',
            subtitle: pending == 0
                ? 'All caught up for today.'
                : '$pending ${pending == 1 ? 'set is' : 'sets are'} waiting for you.',
          ),
        ),
        const SizedBox(height: 20),
        for (var i = 0; i < practiceSets.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _PracticeTile(
              set: practiceSets[i],
              result: _results[i],
              onStart: () => _start(i),
            ),
          ),
      ],
    );
  }
}

class _PracticeTile extends StatelessWidget {
  const _PracticeTile({required this.set, required this.result, required this.onStart});

  final PracticeSet set;
  final bool? result;
  final VoidCallback onStart;

  Color get _difficultyColor => switch (set.difficulty) {
        'Easy' => AppColors.green,
        'Hard' => AppColors.red,
        _ => AppColors.amber,
      };

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final Widget action = switch (result) {
      null => FilledButton(onPressed: onStart, child: const Text('Start')),
      true => const Pill(label: 'Correct', color: AppColors.green),
      false => OutlinedButton(onPressed: onStart, child: const Text('Try again')),
    };

    return Panel(
      padding: const EdgeInsets.all(20),
      child: Wrap(
        spacing: 16,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.spaceBetween,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: tint(set.accent),
                    borderRadius: BorderRadius.circular(AppRadius.base),
                  ),
                  child: Icon(Icons.fitness_center, color: set.accent, size: 22),
                ),
                const SizedBox(width: 14),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        set.title,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(set.course, style: TextStyle(color: p.mutedForeground, fontSize: 13)),
                      const SizedBox(height: 6),
                      Text(
                        '${set.questions} questions · ${set.minutes} min',
                        style: AppTheme.mono(11, color: p.subtle),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Pill(label: set.difficulty, color: _difficultyColor),
              const SizedBox(width: 12),
              action,
            ],
          ),
        ],
      ),
    );
  }
}

class _QuestionDialog extends StatefulWidget {
  const _QuestionDialog({required this.set});

  final PracticeSet set;

  @override
  State<_QuestionDialog> createState() => _QuestionDialogState();
}

class _QuestionDialogState extends State<_QuestionDialog> {
  int? _picked;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final set = widget.set;
    return AlertDialog(
      title: Text(set.title),
      content: SizedBox(
        width: 440,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(set.sampleQuestion, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            for (var i = 0; i < set.options.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  onTap: () => setState(() => _picked = i),
                  selected: _picked == i,
                  selectedColor: p.primaryText,
                  selectedTileColor: tint(AppColors.violet),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.base),
                    side: BorderSide(color: _picked == i ? AppColors.violet : p.border),
                  ),
                  leading: Icon(
                    _picked == i ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  ),
                  title: Text(set.options[i]),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: _picked == null ? null : () => Navigator.pop(context, _picked == set.answer),
          child: const Text('Check answer'),
        ),
      ],
    );
  }
}
