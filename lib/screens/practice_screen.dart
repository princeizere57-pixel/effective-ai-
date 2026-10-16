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
import '../widgets/progress_bar.dart';
import '../widgets/question_card.dart';
import '../widgets/source_widgets.dart';
import 'page_scaffold.dart';

/// Features 15, 16, 17, 18 and 29: Practice Generator, Active Recall and Knowledge
/// Review, Socratic Mode, and Answer Evaluation.
class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      builder: (context, width) => [
        const FadeSlideIn(
          child: PageHeader(
            title: 'Practice',
            subtitle: 'Questions from your own materials, recall that strengthens memory, and a tutor that makes you think.',
          ),
        ),
        const SizedBox(height: 20),
        TabSwitch(
          labels: const ['Generate', 'Answer check', 'Review', 'Socratic'],
          index: _tab,
          onChanged: (i) => setState(() => _tab = i),
        ),
        const SizedBox(height: 20),
        switch (_tab) {
          0 => const _GeneratorView(),
          1 => const _AnswerCheckView(),
          2 => const _ReviewView(),
          _ => const _SocraticView(),
        },
      ],
    );
  }
}

// ── 15 Practice Generator ───────────────────────────────────────────────────

class _GeneratorView extends StatefulWidget {
  const _GeneratorView();

  @override
  State<_GeneratorView> createState() => _GeneratorViewState();
}

class _GeneratorViewState extends State<_GeneratorView> {
  Set<String> _docs = {};
  int _count = 5;
  List<QuizQuestion>? _set;
  int _index = 0;
  int _correct = 0;

  void _generate() {
    final pool = questionBank
        .where((q) => _docs.isEmpty || _docs.contains(passageById(q.passageId).docId))
        .toList()
      ..shuffle(math.Random());
    if (pool.isEmpty) {
      showToast(context, 'No questions come from those materials yet. Select more.');
      return;
    }
    setState(() {
      _set = pool.take(_count).toList();
      _index = 0;
      _correct = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final set = _set;
    if (set == null) {
      return Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Build questions from', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            MaterialSelector(selected: _docs, onChanged: (s) => setState(() => _docs = s)),
            const SizedBox(height: 16),
            const Text('Number of questions', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 3, label: Text('3')),
                ButtonSegment(value: 5, label: Text('5')),
                ButtonSegment(value: 8, label: Text('8')),
              ],
              selected: {_count},
              showSelectedIcon: false,
              onSelectionChanged: (s) => setState(() => _count = s.first),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _generate,
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: const Text('Generate practice set'),
            ),
            const SizedBox(height: 10),
            Text(
              'Every question is written from a page in your materials and links back to it.',
              style: TextStyle(color: p.subtle, fontSize: 12),
            ),
          ],
        ),
      );
    }
    if (_index >= set.length) {
      return Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$_correct of ${set.length} correct', style: AppTheme.display(24)),
            const SizedBox(height: 8),
            Text('Your mastery and gaps were updated.', style: TextStyle(color: p.mutedForeground)),
            const SizedBox(height: 16),
            FilledButton(onPressed: () => setState(() => _set = null), child: const Text('New practice set')),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProgressBar(value: _index / set.length, height: 6),
        const SizedBox(height: 16),
        QuestionCard(
          key: ValueKey('gen-$_index-${set[_index].question}'),
          header: 'Question ${_index + 1} of ${set.length} · ${conceptById(set[_index].conceptId).name}',
          question: set[_index],
          nextLabel: _index == set.length - 1 ? 'Finish' : 'Next question',
          onAnswered: (ok) {
            if (ok) _correct++;
          },
          onNext: () {
            if (_index == set.length - 1) {
              learner.log(ActivityKind.practice, 'Practice set: $_correct of ${set.length} correct');
            }
            setState(() => _index++);
          },
        ),
      ],
    );
  }
}

// ── 18 Answer Evaluation ────────────────────────────────────────────────────

class _AnswerCheckView extends StatefulWidget {
  const _AnswerCheckView();

  @override
  State<_AnswerCheckView> createState() => _AnswerCheckViewState();
}

class _AnswerCheckViewState extends State<_AnswerCheckView> {
  final _controller = TextEditingController();
  int _rubric = 0;
  Evaluation? _result;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _check() {
    if (_controller.text.trim().length < 20) {
      showToast(context, 'Write a fuller answer first (at least a sentence or two)');
      return;
    }
    final rubric = rubrics[_rubric];
    final result = KnowledgeEngine.evaluate(rubric, _controller.text);
    learner.record(rubric.conceptId, result.fraction >= 0.5);
    learner.log(
      ActivityKind.evaluation,
      'Answer check on ${passageById(rubric.passageId).section}: ${result.score}/${rubric.marks}',
    );
    setState(() => _result = result);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final rubric = rubrics[_rubric];
    final question = passageById(rubric.passageId);
    final result = _result;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < rubrics.length; i++)
              ChoiceChip(
                label: Text(
                  '${learner.docById(passageById(rubrics[i].passageId).docId)?.title.replaceFirst('Past exam: ', '')} · '
                  '${passageById(rubrics[i].passageId).section.split(' (').first}',
                ),
                selected: i == _rubric,
                onSelected: (_) => setState(() {
                  _rubric = i;
                  _result = null;
                  _controller.clear();
                }),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(question.section, style: AppTheme.mono(12, color: p.subtle)),
              const SizedBox(height: 6),
              Text(question.text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.5)),
              const SizedBox(height: 14),
              TextField(
                controller: _controller,
                minLines: 5,
                maxLines: 12,
                decoration: fieldDecoration(context, hint: 'Write your answer as you would in the exam'),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: _check,
                  icon: const Icon(Icons.rate_review_outlined, size: 18),
                  label: const Text('Check my answer'),
                ),
              ),
            ],
          ),
        ),
        if (result != null) ...[
          const SizedBox(height: 16),
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text('${result.score} / ${rubric.marks} marks', style: AppTheme.display(24))),
                    Pill(
                      label: result.fraction >= 0.75 ? 'Strong answer' : result.fraction >= 0.5 ? 'Partly there' : 'Needs work',
                      color: result.fraction >= 0.75
                          ? AppColors.green
                          : result.fraction >= 0.5
                              ? AppColors.amber
                              : AppColors.red,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ProgressBar(value: result.fraction, height: 8),
                const SizedBox(height: 16),
                for (var i = 0; i < rubric.points.length; i++) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        result.covered[i] ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: result.covered[i] ? AppColors.green : AppColors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${rubric.points[i].text} (${rubric.points[i].marks} marks)',
                          style: TextStyle(fontWeight: result.covered[i] ? FontWeight.w400 : FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  if (!result.covered[i])
                    Padding(
                      padding: const EdgeInsets.fromLTRB(30, 6, 0, 0),
                      child: SourceTile(passage: passageById(rubric.points[i].passageId)),
                    ),
                  const SizedBox(height: 10),
                ],
                Text(
                  'Checked against marking points taken from your materials. Missing points link to where '
                  'the answer is. An AI model will also judge the quality of your reasoning.',
                  style: TextStyle(color: p.subtle, fontSize: 12, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// ── 16 Active Recall + 29 Knowledge Review ──────────────────────────────────

class _ReviewView extends StatefulWidget {
  const _ReviewView();

  @override
  State<_ReviewView> createState() => _ReviewViewState();
}

class _ReviewViewState extends State<_ReviewView> {
  final _attempt = TextEditingController();
  bool _revealed = false;

  @override
  void dispose() {
    _attempt.dispose();
    super.dispose();
  }

  void _rate(String conceptId, bool remembered) {
    learner.markReviewed(conceptId, remembered: remembered);
    if (learner.reviewQueue.isEmpty) {
      learner.log(ActivityKind.review, 'Finished a review of ${learner.reviewedThisSession.length} concepts');
    }
    setState(() {
      _revealed = false;
      _attempt.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final queue = learner.reviewQueue;
    if (queue.isEmpty) {
      return Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('All reviewed for now', style: AppTheme.display(24)),
            const SizedBox(height: 8),
            Text(
              'Weak and forgotten concepts come back here first next time.',
              style: TextStyle(color: p.mutedForeground),
            ),
          ],
        ),
      );
    }
    final c = queue.first;
    final wasGap = learner.isGap(c.id);
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text('${queue.length} to review', style: AppTheme.mono(12, color: p.subtle)),
              const Spacer(),
              if (wasGap) const Pill(label: 'Weak spot', color: AppColors.red),
            ],
          ),
          const SizedBox(height: 12),
          Text('Explain ${c.name.toLowerCase()} in your own words.', style: AppTheme.display(22)),
          const SizedBox(height: 6),
          Text(
            'Answer from memory before you look. Retrieving it is what makes it stick.',
            style: TextStyle(color: p.mutedForeground, fontSize: 13),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _attempt,
            minLines: 2,
            maxLines: 5,
            decoration: fieldDecoration(context, hint: 'Type or say your answer (optional)'),
          ),
          const SizedBox(height: 14),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: _revealed ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: Align(
              alignment: Alignment.centerLeft,
              child: FilledButton(onPressed: () => setState(() => _revealed = true), child: const Text('Show answer')),
            ),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: tint(AppColors.violet, 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.base),
                  ),
                  child: Text(c.standard, style: const TextStyle(height: 1.6)),
                ),
                const SizedBox(height: 10),
                SourceTile(passage: passageById(c.keyPassage)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton(onPressed: () => _rate(c.id, false), child: const Text("I didn't remember")),
                    FilledButton(onPressed: () => _rate(c.id, true), child: const Text('I remembered')),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── 17 Socratic Mode ────────────────────────────────────────────────────────

class _SocraticView extends StatefulWidget {
  const _SocraticView();

  @override
  State<_SocraticView> createState() => _SocraticViewState();
}

class _SocraticViewState extends State<_SocraticView> {
  final _controller = TextEditingController();
  late SocraticScript _script;
  final _chat = <(bool, String)>[];
  int _step = 0;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _start(socraticScripts.first);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _start(SocraticScript script) {
    _script = script;
    _chat
      ..clear()
      ..add((true, script.opening))
      ..add((true, script.steps.first.question));
    _step = 0;
    _done = false;
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _chat.add((false, text));
      _controller.clear();
      final hint = _script.steps[_step].hint;
      if (_step < _script.steps.length - 1) {
        _chat.add((true, 'Good. Check your thinking against this: $hint'));
        _step++;
        _chat.add((true, _script.steps[_step].question));
      } else {
        _chat.add((true, 'Check your thinking against this: $hint'));
        _chat.add((true, _script.conclusion));
        _done = true;
        learner.record(_script.conceptId, true);
      }
    });
  }

  void _stuck() => setState(() => _chat.add((true, 'A hint: ${_script.steps[_step].hint}')));

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final s in socraticScripts)
              ChoiceChip(
                label: Text(conceptById(s.conceptId).name),
                selected: s == _script,
                onSelected: (_) => setState(() => _start(s)),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (fromTutor, text) in _chat)
                Align(
                  alignment: fromTutor ? Alignment.centerLeft : Alignment.centerRight,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: fromTutor ? p.muted : tint(AppColors.violet, 0.18),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(text, style: const TextStyle(height: 1.5)),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              if (_done)
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton(
                    onPressed: () => setState(() {
                      final next = socraticScripts[(socraticScripts.indexOf(_script) + 1) % socraticScripts.length];
                      _start(next);
                    }),
                    child: const Text('Try another concept'),
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        onSubmitted: (_) => _send(),
                        decoration: fieldDecoration(context, hint: 'Your answer'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(onPressed: _send, icon: const Icon(Icons.send), tooltip: 'Send'),
                    TextButton(onPressed: _stuck, child: const Text("I'm stuck")),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}
