import 'package:flutter/material.dart';

import '../data/knowledge.dart';
import '../services/knowledge_engine.dart';
import '../theme/app_palette.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/source_widgets.dart';
import 'page_scaffold.dart';

/// Features 5 and 6: Explain This, with Simplify / Deepen.
class ExplainScreen extends StatefulWidget {
  const ExplainScreen({super.key});

  @override
  State<ExplainScreen> createState() => _ExplainScreenState();
}

class _ExplainScreenState extends State<ExplainScreen> {
  static const _levels = ['Simple', 'Standard', 'Deep'];

  final _passage = TextEditingController();
  String _conceptId = concepts.first.id;
  int _level = 1;

  @override
  void dispose() {
    _passage.dispose();
    super.dispose();
  }

  void _explainPassage() {
    final text = _passage.text.trim();
    if (text.isEmpty) {
      showToast(context, 'Paste a passage, sentence or table caption first');
      return;
    }
    final hits = KnowledgeEngine.search(text);
    if (hits.isEmpty) {
      showToast(context, "Couldn't match this passage to a concept in your library yet");
      return;
    }
    final id = hits.first.passage.concepts.first;
    setState(() {
      _conceptId = id;
      _level = 0;
    });
    showToast(context, 'Your passage is about ${conceptById(id).name}. Starting simple.');
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final concept = conceptById(_conceptId);

    return PageScaffold(
      builder: (context, width) => [
        const FadeSlideIn(
          child: PageHeader(
            title: 'Explain This',
            subtitle: 'Pick a concept, or paste a passage, and read it at the depth you need.',
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final c in concepts)
              ChoiceChip(
                label: Text(c.name),
                selected: c.id == _conceptId,
                onSelected: (_) => setState(() => _conceptId = c.id),
              ),
          ],
        ),
        const SizedBox(height: 20),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(concept.name, style: AppTheme.display(26))),
                  NeutralPill('${_levels[_level]} level'),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  for (var i = 0; i < 3; i++)
                    Expanded(
                      child: Container(
                        height: 4,
                        margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
                        decoration: BoxDecoration(
                          color: i <= _level ? Theme.of(context).colorScheme.primary : p.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Text(
                  concept.explanation(_level),
                  key: ValueKey('$_conceptId-$_level'),
                  style: const TextStyle(fontSize: 16, height: 1.65),
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: _level > 0 ? () => setState(() => _level--) : null,
                    icon: const Icon(Icons.remove, size: 18),
                    label: const Text('Simplify'),
                  ),
                  FilledButton.icon(
                    onPressed: _level < 2 ? () => setState(() => _level++) : null,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Go deeper'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Divider(color: p.border),
              const SizedBox(height: 12),
              const Text('Example', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(concept.example, style: TextStyle(color: p.mutedForeground, height: 1.55)),
              const SizedBox(height: 16),
              const Text('From your materials', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              for (final x in passagesFor(_conceptId).take(3)) SourceTile(passage: x),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Explain a passage', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(
                'Paste a sentence, paragraph, table caption or diagram label from your materials.',
                style: TextStyle(color: p.mutedForeground, fontSize: 13),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passage,
                minLines: 3,
                maxLines: 6,
                decoration: fieldDecoration(context, hint: 'Paste the text you find difficult'),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(onPressed: _explainPassage, child: const Text('Explain this')),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
