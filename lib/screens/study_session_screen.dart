import 'package:flutter/material.dart';

import '../data/knowledge.dart';
import '../services/learner_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_palette.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/feedback_prompt.dart';
import '../widgets/progress_bar.dart';
import '../widgets/question_card.dart';
import '../widgets/source_widgets.dart';
import 'page_scaffold.dart';

/// One guided workflow used by three features:
/// 14 Targeted Learning (weak concept → source → explanation → examples → questions),
/// 20 Remediation (mistake → concept → explanation → new practice → reassessment),
/// 25 Study Session (topic → learn → practise → test → review).
class StudySessionScreen extends StatefulWidget {
  const StudySessionScreen({super.key, required this.conceptId, this.mistake});

  final String conceptId;

  /// When set, the session starts by looking at this mistake (remediation).
  final Mistake? mistake;

  static Future<void> open(BuildContext context, String conceptId, {Mistake? mistake}) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => StudySessionScreen(conceptId: conceptId, mistake: mistake)),
    );
  }

  @override
  State<StudySessionScreen> createState() => _StudySessionScreenState();
}

class _StudySessionScreenState extends State<StudySessionScreen> {
  late final Concept _concept = conceptById(widget.conceptId);
  late final double? _before = learner.mastery(widget.conceptId);
  late final List<String> _steps = [
    if (widget.mistake != null) 'Mistake',
    'Learn',
    'Practise',
    'Test',
    'Review',
  ];
  late final List<QuizQuestion> _questions = questionsFor(widget.conceptId);

  int _step = 0;
  int _testIndex = 0;
  int _testCorrect = 0;

  String get _current => _steps[_step];

  void _next() => setState(() => _step++);

  Future<void> _finish() async {
    await showFeedbackPrompt(context, where: 'study session');
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mistake != null ? 'Fix a mistake: ${_concept.name}' : 'Study session: ${_concept.name}'),
      ),
      body: PageScaffold(
        builder: (context, width) => [
          _StepBar(steps: _steps, current: _step),
          const SizedBox(height: 20),
          switch (_current) {
            'Mistake' => _mistakeStep(context),
            'Learn' => _learnStep(context),
            'Practise' => QuestionCard(
                key: const ValueKey('practise'),
                header: 'Practice question · instant feedback',
                question: _practiceQuestion,
                nextLabel: 'Continue to the test',
                onNext: _next,
              ),
            'Test' => _testIndex < _questions.length
                ? QuestionCard(
                    key: ValueKey('test-$_testIndex'),
                    header: 'Test · question ${_testIndex + 1} of ${_questions.length}',
                    question: _questions[_testIndex],
                    nextLabel: _testIndex == _questions.length - 1 ? 'See my review' : 'Next question',
                    onAnswered: (ok) {
                      if (ok) _testCorrect++;
                    },
                    onNext: () {
                      if (_testIndex == _questions.length - 1) {
                        learner.log(
                          ActivityKind.session,
                          'Study session on ${_concept.name}: $_testCorrect of ${_questions.length} correct',
                        );
                        setState(() => _step++);
                      } else {
                        setState(() => _testIndex++);
                      }
                    },
                  )
                : const SizedBox.shrink(),
            _ => _reviewStep(context, p),
          },
          if (_current == 'Mistake' || _current == 'Learn') ...[
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: _next,
                child: Text(_current == 'Mistake' ? 'Fix the concept behind it' : 'Practise it'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  QuizQuestion get _practiceQuestion {
    final missed = widget.mistake?.question;
    return _questions.firstWhere((q) => q != missed, orElse: () => _questions.first);
  }

  Widget _mistakeStep(BuildContext context) {
    final p = context.palette;
    final m = widget.mistake!;
    final q = m.question;
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(q.question, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          OptionTile(label: 'You chose: ${q.options[m.chosen]}', selected: true, state: OptionState.wrong),
          OptionTile(label: 'Correct: ${q.options[q.answer]}', selected: false, state: OptionState.correct),
          const SizedBox(height: 8),
          Pill(label: 'Type of mistake: ${q.kind.label}', color: AppColors.brand),
          const SizedBox(height: 12),
          Text(q.explanation, style: TextStyle(color: p.mutedForeground, height: 1.5)),
          const SizedBox(height: 8),
          SourceTile(passage: passageById(q.passageId)),
        ],
      ),
    );
  }

  Widget _learnStep(BuildContext context) {
    final p = context.palette;
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_concept.name, style: AppTheme.display(24)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: tint(AppColors.brand, 0.1), borderRadius: BorderRadius.circular(AppRadius.base)),
            child: Text('In one line: ${_concept.simple}', style: TextStyle(color: p.primaryText, height: 1.5)),
          ),
          const SizedBox(height: 14),
          Text(_concept.standard, style: const TextStyle(fontSize: 15, height: 1.65)),
          const SizedBox(height: 16),
          const Text('Example', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(_concept.example, style: TextStyle(color: p.mutedForeground, height: 1.55)),
          const SizedBox(height: 16),
          const Text('What your materials say', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          for (final x in passagesFor(widget.conceptId).take(3)) SourceTile(passage: x),
        ],
      ),
    );
  }

  Widget _reviewStep(BuildContext context, AppPalette p) {
    final after = learner.mastery(widget.conceptId);
    final stillGap = learner.isGap(widget.conceptId);
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Session review', style: AppTheme.display(24)),
          const SizedBox(height: 12),
          Text(
            'Test: $_testCorrect of ${_questions.length} correct',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text('Mastery ${percent(_before)}', style: AppTheme.mono(13, color: p.mutedForeground)),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward, size: 16, color: p.subtle),
              const SizedBox(width: 8),
              Text(
                percent(after),
                style: AppTheme.mono(13, color: masteryStyle(after).$2).copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ProgressBar(value: after ?? 0, color: masteryStyle(after).$2, height: 8),
          const SizedBox(height: 16),
          Text(
            stillGap
                ? '${_concept.name} is still a gap. Your plan now schedules another session, and it will come back in Review.'
                : '${_concept.name} is no longer a gap. It moves to short reviews so you keep it.',
            style: TextStyle(color: p.mutedForeground, height: 1.5),
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(onPressed: _finish, child: const Text('Finish session')),
          ),
        ],
      ),
    );
  }
}

class _StepBar extends StatelessWidget {
  const _StepBar({required this.steps, required this.current});

  final List<String> steps;
  final int current;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var i = 0; i < steps.length; i++)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: i == current ? AppColors.brand : (i < current ? tint(AppColors.brand) : p.muted),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (i < current) ...[
                  const Icon(Icons.check, size: 14, color: AppColors.brand),
                  const SizedBox(width: 4),
                ],
                Text(
                  '${i + 1}. ${steps[i]}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: i == current ? Colors.white : (i < current ? AppColors.brand : p.mutedForeground),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
