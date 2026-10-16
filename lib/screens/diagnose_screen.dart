import 'package:flutter/material.dart';

import '../data/knowledge.dart';
import '../services/learner_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_palette.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/progress_bar.dart';
import '../widgets/question_card.dart';
import '../widgets/source_widgets.dart';
import 'page_scaffold.dart';
import 'study_session_screen.dart';

/// Features 12, 13, 14, 19 and 20: gaps, diagnostic, targeted learning,
/// error analysis and remediation.
class DiagnoseScreen extends StatefulWidget {
  const DiagnoseScreen({super.key});

  @override
  State<DiagnoseScreen> createState() => _DiagnoseScreenState();
}

class _DiagnoseScreenState extends State<DiagnoseScreen> {
  int _tab = 0;

  // Diagnostic: one question per concept, drawn from the learner's materials.
  final List<QuizQuestion> _diagnostic = [for (final c in concepts) questionsFor(c.id).last];
  bool _started = false;
  int _index = 0;
  int _correct = 0;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: learner,
      builder: (context, _) => PageScaffold(
        builder: (context, width) => [
          const FadeSlideIn(
            child: PageHeader(
              title: 'Diagnose & Improve',
              subtitle: "Find what you don't understand yet, see why you get questions wrong, then fix exactly that.",
            ),
          ),
          const SizedBox(height: 20),
          TabSwitch(
            labels: ['Learning gaps (${learner.gaps.length})', 'Diagnostic test', 'Error analysis'],
            index: _tab,
            onChanged: (i) => setState(() => _tab = i),
          ),
          const SizedBox(height: 20),
          ...(switch (_tab) {
            0 => _gaps(context),
            1 => _diagnosticView(context),
            _ => _errors(context),
          }),
        ],
      ),
    );
  }

  List<Widget> _gaps(BuildContext context) {
    final p = context.palette;
    final gaps = learner.gaps;
    final others = concepts.where((c) => !learner.isGap(c.id)).toList();
    return [
      Text(
        'Based on ${learner.totalAnswers} answers from diagnostics, practice, reviews and tests.',
        style: TextStyle(color: p.mutedForeground),
      ),
      const SizedBox(height: 12),
      Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Work on these (${gaps.length})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            if (gaps.isEmpty)
              Text('No gaps right now. Keep reviewing to hold on to it.', style: TextStyle(color: p.mutedForeground)),
            for (final c in gaps)
              MasteryRow(
                concept: c,
                trailing: FilledButton(
                  onPressed: () => StudySessionScreen.open(context, c.id),
                  child: const Text('Fix this'),
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
            Text('Understood (${others.length})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            for (final c in others) MasteryRow(concept: c),
          ],
        ),
      ),
    ];
  }

  List<Widget> _diagnosticView(BuildContext context) {
    final p = context.palette;
    if (!_started) {
      return [
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Diagnostic test', style: AppTheme.display(24)),
              const SizedBox(height: 8),
              Text(
                '${_diagnostic.length} questions, one per concept, written from your own materials. '
                'About 4 minutes. Each answer updates your gaps.',
                style: TextStyle(color: p.mutedForeground, height: 1.5),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => setState(() {
                  _started = true;
                  _index = 0;
                  _correct = 0;
                }),
                child: const Text('Start diagnostic'),
              ),
            ],
          ),
        ),
      ];
    }
    if (_index >= _diagnostic.length) {
      return [
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('You scored $_correct of ${_diagnostic.length}', style: AppTheme.display(24)),
              const SizedBox(height: 8),
              Text(
                'Your gaps were updated: ${learner.gaps.map((c) => c.name).join(', ')}.',
                style: TextStyle(color: p.mutedForeground, height: 1.5),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton(onPressed: () => setState(() => _tab = 0), child: const Text('See my gaps')),
                  OutlinedButton(onPressed: () => setState(() => _tab = 2), child: const Text('Why I got them wrong')),
                  TextButton(onPressed: () => setState(() => _started = false), child: const Text('Retake')),
                ],
              ),
            ],
          ),
        ),
      ];
    }
    return [
      ProgressBar(value: _index / _diagnostic.length, height: 6),
      const SizedBox(height: 16),
      QuestionCard(
        key: ValueKey('diag-$_index'),
        header: 'Question ${_index + 1} of ${_diagnostic.length} · ${conceptById(_diagnostic[_index].conceptId).name}',
        question: _diagnostic[_index],
        nextLabel: _index == _diagnostic.length - 1 ? 'See results' : 'Next question',
        onAnswered: (ok) {
          if (ok) _correct++;
        },
        onNext: () {
          if (_index == _diagnostic.length - 1) {
            learner.diagnosticDone = true;
            learner.log(ActivityKind.diagnostic, 'Diagnostic test: $_correct of ${_diagnostic.length} correct');
          }
          setState(() => _index++);
        },
      ),
    ];
  }

  List<Widget> _errors(BuildContext context) {
    final p = context.palette;
    final mistakes = learner.mistakes;
    if (mistakes.isEmpty) {
      return [Panel(child: Text('No mistakes recorded yet.', style: TextStyle(color: p.mutedForeground)))];
    }
    final byKind = <QuestionKind, int>{};
    final byConcept = <String, int>{};
    for (final m in mistakes) {
      byKind.update(m.question.kind, (v) => v + 1, ifAbsent: () => 1);
      byConcept.update(m.question.conceptId, (v) => v + 1, ifAbsent: () => 1);
    }
    final kinds = byKind.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final conceptsByErrors = byConcept.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final top = kinds.first;

    return [
      Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.insights, color: AppColors.brand),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${top.value} of your ${mistakes.length} mistakes are about ${top.key.label.toLowerCase()}.',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${top.key.description}. Practise questions that ask you to use ideas, not only recall them.',
              style: TextStyle(color: p.mutedForeground, height: 1.5),
            ),
            const SizedBox(height: 16),
            for (final e in kinds) ...[
              Row(
                children: [
                  Expanded(child: Text(e.key.label)),
                  Text('${e.value}', style: AppTheme.mono(12, color: p.mutedForeground)),
                ],
              ),
              const SizedBox(height: 6),
              ProgressBar(value: e.value / mistakes.length, color: AppColors.brand, height: 6),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 4),
            Text(
              'Most mistakes by concept: ${conceptsByErrors.take(3).map((e) => '${conceptById(e.key).name} (${e.value})').join(', ')}',
              style: TextStyle(color: p.mutedForeground, fontSize: 13),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      const Text('Recent mistakes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      const SizedBox(height: 10),
      for (final m in mistakes.take(8))
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Panel(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(m.question.question, style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                    Text(timeAgo(m.when), style: AppTheme.mono(11, color: p.subtle)),
                  ],
                ),
                const SizedBox(height: 8),
                Text('You chose: ${m.question.options[m.chosen]}', style: TextStyle(color: AppColors.brand)),
                Text('Correct: ${m.question.options[m.question.answer]}', style: TextStyle(color: AppColors.brand)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    NeutralPill(conceptById(m.question.conceptId).name),
                    Pill(label: m.question.kind.label, color: AppColors.brand),
                    TextButton.icon(
                      onPressed: () => StudySessionScreen.open(context, m.question.conceptId, mistake: m),
                      icon: const Icon(Icons.build_outlined, size: 16),
                      label: const Text('Fix this mistake'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
    ];
  }
}
