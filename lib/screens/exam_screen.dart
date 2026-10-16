import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/knowledge.dart';
import '../services/knowledge_engine.dart';
import '../services/learner_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_palette.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/feedback_prompt.dart';
import '../widgets/progress_bar.dart';
import '../widgets/question_card.dart';
import '../widgets/source_widgets.dart';
import 'page_scaffold.dart';
import 'study_session_screen.dart';

/// Features 21, 22, 23 and 24: Exam Preparation, Past Paper Intelligence,
/// Mock Test and Post-Test Analysis.
class ExamScreen extends StatefulWidget {
  const ExamScreen({super.key});

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: learner,
      builder: (context, _) => PageScaffold(
        builder: (context, width) => [
          const FadeSlideIn(
            child: PageHeader(
              title: 'Exam Prep',
              subtitle: 'Prepare from what your past papers actually ask, then test yourself for real.',
            ),
          ),
          const SizedBox(height: 20),
          TabSwitch(
            labels: const ['Past papers', 'Prep plan', 'Mock test'],
            index: _tab,
            onChanged: (i) => setState(() => _tab = i),
          ),
          const SizedBox(height: 20),
          switch (_tab) {
            0 => const _PastPapersView(),
            1 => _PrepPlanView(onMockTest: () => setState(() => _tab = 2)),
            _ => const _MockTestView(),
          },
        ],
      ),
    );
  }
}

PastPaperReport _report() => KnowledgeEngine.analysePastPapers(
      learner.indexedDocs.where((d) => d.type == DocType.pastExam).map((d) => d.id).toSet(),
    );

// ── 22 Past Paper Intelligence ──────────────────────────────────────────────

class _PastPapersView extends StatelessWidget {
  const _PastPapersView();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final report = _report();
    if (report.paperCount == 0) {
      return Panel(
        child: Text(
          'Upload past exams in My Library to see recurring topics and question types.',
          style: TextStyle(color: p.mutedForeground),
        ),
      );
    }
    final topWord = report.commandWords.entries.isEmpty ? null : report.commandWords.entries.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${report.paperCount} past papers · ${report.questionCount} questions analysed',
          style: TextStyle(color: p.mutedForeground),
        ),
        const SizedBox(height: 12),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Recurring topics', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('How often each concept is assessed, and how many marks it carries.',
                  style: TextStyle(color: p.mutedForeground, fontSize: 13)),
              const SizedBox(height: 8),
              for (final t in report.topics)
                Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    title: Text(t.concept.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'In ${t.papers} of ${report.paperCount} papers · ${t.marks} marks · mastery ${percent(learner.mastery(t.concept.id))}',
                            style: AppTheme.mono(11, color: p.subtle),
                          ),
                          const SizedBox(height: 6),
                          ProgressBar(
                            value: t.papers / report.paperCount,
                            color: t.papers == report.paperCount ? AppColors.brand : AppColors.brand,
                            height: 6,
                          ),
                        ],
                      ),
                    ),
                    children: [for (final q in t.questions) SourceTile(passage: q)],
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
              const Text('Question types', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              for (final e in report.commandWords.entries) ...[
                Row(
                  children: [
                    Expanded(child: Text(e.key)),
                    Text('${e.value} of ${report.questionCount}', style: AppTheme.mono(12, color: p.mutedForeground)),
                  ],
                ),
                const SizedBox(height: 6),
                ProgressBar(value: e.value / report.questionCount, color: AppColors.brand, height: 6),
                const SizedBox(height: 12),
              ],
              if (topWord != null)
                Text(
                  '"${topWord.key}" questions come up most. Practise writing full answers in Practice → '
                  'Answer check, not only multiple choice.',
                  style: TextStyle(color: p.mutedForeground, height: 1.5),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── 21 Exam Preparation Workflow ────────────────────────────────────────────

class _PrepPlanView extends StatelessWidget {
  const _PrepPlanView({required this.onMockTest});

  final VoidCallback onMockTest;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final report = _report();
    double priority(TopicFrequency t) => t.papers * (1 - (learner.mastery(t.concept.id) ?? 0.3));
    final steps = [...report.topics]..sort((a, b) => priority(b).compareTo(priority(a)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Ordered by how often a topic is assessed and how weak you are in it.',
          style: TextStyle(color: p.mutedForeground),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < steps.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Panel(
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: tint(AppColors.brand, 0.2),
                    child: Text('${i + 1}', style: TextStyle(color: p.primaryText, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(steps[i].concept.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(
                          'In ${steps[i].papers} of ${report.paperCount} papers · ${steps[i].marks} marks · '
                          'mastery ${percent(learner.mastery(steps[i].concept.id))}',
                          style: TextStyle(color: p.mutedForeground, fontSize: 13),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          learner.isGap(steps[i].concept.id)
                              ? 'Study it, then answer the past-paper question below.'
                              : 'You know this. Answer the past-paper question to practise exam wording.',
                          style: const TextStyle(height: 1.4),
                        ),
                        const SizedBox(height: 10),
                        for (final q in steps[i].questions) SourceTile(passage: q),
                        const SizedBox(height: 4),
                        FilledButton.tonal(
                          onPressed: () => StudySessionScreen.open(context, steps[i].concept.id),
                          child: const Text('Start study session'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        Panel(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: tint(AppColors.brand, 0.2),
                child: Text('${steps.length + 1}', style: const TextStyle(color: AppColors.brand, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text('Sit a mock test under exam conditions', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
              FilledButton(onPressed: onMockTest, child: const Text('Go')),
            ],
          ),
        ),
      ],
    );
  }
}

// ── 23 Mock Test + 24 Post-Test Analysis ────────────────────────────────────

class _MockTestView extends StatefulWidget {
  const _MockTestView();

  @override
  State<_MockTestView> createState() => _MockTestViewState();
}

class _MockTestViewState extends State<_MockTestView> {
  static const _secondsPerQuestion = 60;

  Set<String> _docs = {};
  int _count = 8;
  List<QuizQuestion>? _test;
  List<int?> _answers = [];
  int _index = 0;
  int _secondsLeft = 0;
  int _secondsUsed = 0;
  bool _submitted = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    final pool = questionBank
        .where((q) => _docs.isEmpty || _docs.contains(passageById(q.passageId).docId))
        .toList()
      ..shuffle(math.Random());
    if (pool.isEmpty) {
      showToast(context, 'No questions come from those materials yet. Select more.');
      return;
    }
    final test = pool.take(_count).toList();
    setState(() {
      _test = test;
      _answers = List<int?>.filled(test.length, null);
      _index = 0;
      _submitted = false;
      _secondsLeft = test.length * _secondsPerQuestion;
      _secondsUsed = 0;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _secondsLeft--;
        _secondsUsed++;
      });
      if (_secondsLeft <= 0) _submit();
    });
  }

  void _submit() {
    final test = _test;
    if (test == null || _submitted) return;
    _timer?.cancel();
    var correct = 0;
    for (var i = 0; i < test.length; i++) {
      final a = _answers[i];
      if (a == null) {
        learner.record(test[i].conceptId, false);
      } else if (learner.answer(test[i], a)) {
        correct++;
      }
    }
    learner.log(ActivityKind.mockTest, 'Mock test: $correct of ${test.length} correct');
    setState(() => _submitted = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) showFeedbackPrompt(context, where: 'mock test');
    });
  }

  String _clock(int s) => '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final test = _test;
    if (test == null) return _setup(context);
    if (_submitted) return _analysis(context, test);
    return _running(context, test);
  }

  Widget _setup(BuildContext context) {
    final p = context.palette;
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Mock test', style: AppTheme.display(24)),
          const SizedBox(height: 6),
          Text(
            'Timed, no hints, answers revealed only at the end. Questions come only from the materials you authorise.',
            style: TextStyle(color: p.mutedForeground, height: 1.5),
          ),
          const SizedBox(height: 16),
          const Text('Authorised materials', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          MaterialSelector(selected: _docs, onChanged: (s) => setState(() => _docs = s)),
          const SizedBox(height: 16),
          const Text('Length', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 5, label: Text('5 questions · 5 min')),
              ButtonSegment(value: 8, label: Text('8 questions · 8 min')),
            ],
            selected: {_count},
            showSelectedIcon: false,
            onSelectionChanged: (s) => setState(() => _count = s.first),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(onPressed: _start, icon: const Icon(Icons.timer_outlined), label: const Text('Start mock test')),
        ],
      ),
    );
  }

  Widget _running(BuildContext context, List<QuizQuestion> test) {
    final p = context.palette;
    final q = test[_index];
    final low = _secondsLeft <= 30;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text('Question ${_index + 1} of ${test.length}', style: const TextStyle(fontWeight: FontWeight.w700)),
            const Spacer(),
            Icon(Icons.timer_outlined, size: 18, color: low ? AppColors.brand : p.mutedForeground),
            const SizedBox(width: 6),
            Text(_clock(_secondsLeft), style: AppTheme.mono(14, color: low ? AppColors.brand : p.foreground)),
          ],
        ),
        const SizedBox(height: 10),
        ProgressBar(value: _answers.where((a) => a != null).length / test.length, height: 6),
        const SizedBox(height: 16),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(q.question, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, height: 1.35)),
              const SizedBox(height: 16),
              for (var i = 0; i < q.options.length; i++)
                OptionTile(
                  label: q.options[i],
                  selected: _answers[_index] == i,
                  state: OptionState.open,
                  onTap: () => setState(() => _answers[_index] = i),
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  TextButton(
                    onPressed: _index > 0 ? () => setState(() => _index--) : null,
                    child: const Text('Previous'),
                  ),
                  const Spacer(),
                  if (_index < test.length - 1)
                    FilledButton(onPressed: () => setState(() => _index++), child: const Text('Next'))
                  else
                    FilledButton(onPressed: _submit, child: const Text('Submit test')),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _analysis(BuildContext context, List<QuizQuestion> test) {
    final p = context.palette;
    var correct = 0;
    final perConcept = <String, (int, int)>{};
    for (var i = 0; i < test.length; i++) {
      final ok = _answers[i] == test[i].answer;
      if (ok) correct++;
      final prev = perConcept[test[i].conceptId] ?? (0, 0);
      perConcept[test[i].conceptId] = (prev.$1 + (ok ? 1 : 0), prev.$2 + 1);
    }
    final weak = perConcept.entries.where((e) => e.value.$1 < e.value.$2).toList()
      ..sort((a, b) => (a.value.$1 / a.value.$2).compareTo(b.value.$1 / b.value.$2));
    final score = correct / test.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$correct of ${test.length} · ${(score * 100).round()}%', style: AppTheme.display(28)),
              const SizedBox(height: 6),
              Text(
                'Time used ${_clock(_secondsUsed)} of ${_clock(test.length * _secondsPerQuestion)} · '
                '${_answers.where((a) => a == null).length} unanswered',
                style: TextStyle(color: p.mutedForeground),
              ),
              const SizedBox(height: 12),
              ProgressBar(
                value: score,
                color: score >= 0.75 ? AppColors.brand : score >= 0.5 ? AppColors.brand : AppColors.brand,
                height: 8,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('What to study next', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              if (weak.isEmpty)
                Text('Full marks. Keep it fresh with Review.', style: TextStyle(color: p.mutedForeground)),
              for (final e in weak)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${conceptById(e.key).name}: ${e.value.$1} of ${e.value.$2} correct',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      TextButton(
                        onPressed: () => StudySessionScreen.open(context, e.key),
                        child: const Text('Study this'),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text('Your answers', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        for (var i = 0; i < test.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Panel(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        _answers[i] == test[i].answer ? Icons.check_circle : Icons.cancel,
                        color: _answers[i] == test[i].answer ? AppColors.brand : AppColors.brand,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(test[i].question, style: const TextStyle(fontWeight: FontWeight.w600))),
                    ],
                  ),
                  if (_answers[i] != test[i].answer) ...[
                    const SizedBox(height: 6),
                    Text(
                      'You: ${_answers[i] == null ? 'no answer' : test[i].options[_answers[i]!]} · '
                      'Correct: ${test[i].options[test[i].answer]}',
                      style: TextStyle(color: p.mutedForeground, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    SourceTile(passage: passageById(test[i].passageId)),
                  ],
                ],
              ),
            ),
          ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton(onPressed: () => setState(() => _test = null), child: const Text('New mock test')),
        ),
      ],
    );
  }
}
