import 'package:flutter/material.dart';

import '../data/knowledge.dart';
import '../services/learner_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_palette.dart';
import 'common.dart';
import 'source_widgets.dart';

/// One multiple-choice question with instant feedback and its source.
/// Every answer is recorded in the learner's progress memory.
class QuestionCard extends StatefulWidget {
  const QuestionCard({
    super.key,
    required this.question,
    required this.onNext,
    this.onAnswered,
    this.header,
    this.nextLabel = 'Next question',
  });

  final QuizQuestion question;
  final VoidCallback onNext;
  final ValueChanged<bool>? onAnswered;
  final String? header;
  final String nextLabel;

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  int? _picked;
  bool _checked = false;

  void _check() {
    final correct = learner.answer(widget.question, _picked!);
    setState(() => _checked = true);
    widget.onAnswered?.call(correct);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final q = widget.question;
    final correct = _picked == q.answer;

    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.header != null) ...[
            Text(widget.header!, style: TextStyle(color: p.subtle, fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
          ],
          Text(q.question, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, height: 1.35)),
          const SizedBox(height: 16),
          for (var i = 0; i < q.options.length; i++)
            OptionTile(
              label: q.options[i],
              selected: _picked == i,
              state: !_checked
                  ? OptionState.open
                  : i == q.answer
                      ? OptionState.correct
                      : i == _picked
                          ? OptionState.wrong
                          : OptionState.idle,
              onTap: _checked ? null : () => setState(() => _picked = i),
            ),
          if (_checked) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  correct ? Icons.check_circle : Icons.cancel,
                  color: correct ? AppColors.brand : AppColors.brand,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  correct ? 'Correct' : 'Not quite',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: correct ? AppColors.brand : AppColors.brand,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(q.explanation, style: TextStyle(color: p.mutedForeground, height: 1.5)),
            const SizedBox(height: 10),
            SourceTile(passage: passageById(q.passageId)),
          ],
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: _checked
                ? FilledButton(onPressed: widget.onNext, child: Text(widget.nextLabel))
                : FilledButton(
                    onPressed: _picked == null ? null : _check,
                    child: const Text('Check answer'),
                  ),
          ),
        ],
      ),
    );
  }
}

enum OptionState { open, idle, correct, wrong }

class OptionTile extends StatelessWidget {
  const OptionTile({
    super.key,
    required this.label,
    required this.selected,
    required this.state,
    this.onTap,
  });

  final String label;
  final bool selected;
  final OptionState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final Color border = switch (state) {
      OptionState.correct => AppColors.brand,
      OptionState.wrong => AppColors.brand,
      _ => selected ? AppColors.brand : p.border,
    };
    final Color? fill = switch (state) {
      OptionState.correct => tint(AppColors.brand),
      OptionState.wrong => tint(AppColors.brand),
      _ => selected ? tint(AppColors.brand) : null,
    };
    final IconData icon = switch (state) {
      OptionState.correct => Icons.check_circle,
      OptionState.wrong => Icons.cancel,
      _ => selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: fill ?? Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.base),
          side: BorderSide(color: border),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.base),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(icon, size: 20, color: border == p.border ? p.subtle : border),
                const SizedBox(width: 12),
                Expanded(child: Text(label)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
