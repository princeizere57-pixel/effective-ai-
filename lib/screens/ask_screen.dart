import 'package:flutter/material.dart';

import '../services/knowledge_engine.dart';
import '../services/learner_state.dart';
import '../services/session.dart';
import '../theme/app_colors.dart';
import '../theme/app_palette.dart';
import '../widgets/common.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/source_widgets.dart';
import 'page_scaffold.dart';

/// Features 2, 3 and 10: Ask My Knowledge, Source Verification, Ask Across Documents.
class AskScreen extends StatefulWidget {
  const AskScreen({super.key});

  @override
  State<AskScreen> createState() => _AskScreenState();
}

class _AskScreenState extends State<AskScreen> {
  static const _suggestions = [
    'How do I choose a learning rate?',
    'Why does a model overfit and how do I fix it?',
    'How are eigenvectors used in PCA?',
    'How does backpropagation help gradient descent?',
  ];

  final _controller = TextEditingController();
  Set<String> _selected = {};
  String? _question;
  GroundedAnswer? _answer;

  @override
  void initState() {
    super.initState();
    // A question typed on the welcome page is answered as soon as the screen opens.
    final q = pendingQuestion;
    if (q != null) {
      pendingQuestion = null;
      _controller.text = q;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _ask(q);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _ask([String? preset]) {
    final question = (preset ?? _controller.text).trim();
    if (question.isEmpty) {
      showToast(context, 'Type a question or pick one below');
      return;
    }
    final ids = _selected.isEmpty ? learner.indexedDocs.map((d) => d.id).toSet() : _selected;
    setState(() {
      _controller.text = question;
      _question = question;
      _answer = KnowledgeEngine.answer(question, ids);
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return PageScaffold(
      builder: (context, width) => [
        const FadeSlideIn(
          child: PageHeader(
            title: 'Ask My Knowledge',
            subtitle: 'Answers come only from the materials you choose, with the exact source for every point.',
          ),
        ),
        const SizedBox(height: 20),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Answer from', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              MaterialSelector(selected: _selected, onChanged: (s) => setState(() => _selected = s)),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 3,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _ask(),
                decoration: fieldDecoration(context, hint: 'Ask a question about your materials'),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final s in _suggestions)
                    ActionChip(
                      label: Text(s),
                      onPressed: () => _ask(s),
                      backgroundColor: tint(AppColors.brand),
                      side: BorderSide.none,
                      labelStyle: TextStyle(color: p.primaryText, fontWeight: FontWeight.w600),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: _ask,
                  icon: const Icon(Icons.auto_awesome, size: 18),
                  label: const Text('Ask'),
                ),
              ),
            ],
          ),
        ),
        if (_answer != null) ...[
          const SizedBox(height: 20),
          FadeSlideIn(
            key: ValueKey(_question),
            child: _AnswerCard(question: _question!, answer: _answer!),
          ),
        ],
      ],
    );
  }
}

class _AnswerCard extends StatelessWidget {
  const _AnswerCard({required this.question, required this.answer});

  final String question;
  final GroundedAnswer answer;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final highlight = KnowledgeEngine.terms(question).toSet();
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.forum_outlined, color: AppColors.brand, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(question, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (answer.isEmpty)
            Text(
              'Nothing in the selected materials answers this. Select more materials, '
              'rephrase the question, or upload a document that covers it.',
              style: TextStyle(color: p.mutedForeground, height: 1.5),
            )
          else ...[
            if (answer.documentCount > 1) ...[
              Pill(
                label: 'Combined from ${answer.documentCount} documents',
                color: AppColors.brand,
              ),
              const SizedBox(height: 12),
            ],
            Text.rich(
              TextSpan(
                children: [
                  for (final (sentence, source) in answer.parts) ...[
                    TextSpan(text: '$sentence '),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: CitationMarker(
                        source + 1,
                        onTap: () => showSourceSheet(context, answer.sources[source], highlight: highlight),
                      ),
                    ),
                    const TextSpan(text: '  '),
                  ],
                ],
              ),
              style: const TextStyle(fontSize: 15, height: 1.7),
            ),
            const SizedBox(height: 18),
            const Text('Sources', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            for (var i = 0; i < answer.sources.length; i++)
              SourceTile(passage: answer.sources[i], index: i + 1, highlight: highlight),
            const SizedBox(height: 6),
            Text(
              'Built from the exact sentences in your documents. Tap a number to check the source. '
              'Connecting an AI model will turn these into fully written answers with the same citations.',
              style: TextStyle(color: p.subtle, fontSize: 12, height: 1.4),
            ),
          ],
        ],
      ),
    );
  }
}
