import 'package:flutter/material.dart';

import '../data/knowledge.dart';
import '../services/knowledge_engine.dart';
import '../services/learner_state.dart';
import '../theme/app_palette.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/source_widgets.dart';
import 'page_scaffold.dart';

/// Features 4 and 11: Smart Search and Topic Explorer.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  int _tab = 0;
  String _query = '';
  String _topic = concepts.first.id;

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      builder: (context, width) => [
        const FadeSlideIn(
          child: PageHeader(
            title: 'Search & Explore',
            subtitle: 'Find any idea across your whole library, or explore a topic from every angle.',
          ),
        ),
        const SizedBox(height: 20),
        TabSwitch(
          labels: const ['Smart search', 'Topic explorer'],
          index: _tab,
          onChanged: (i) => setState(() => _tab = i),
        ),
        const SizedBox(height: 20),
        if (_tab == 0) ..._search(context) else ..._explore(context),
      ],
    );
  }

  List<Widget> _search(BuildContext context) {
    final p = context.palette;
    final hits = KnowledgeEngine.search(_query);
    final docCount = hits.map((h) => h.passage.docId).toSet().length;
    return [
      TextField(
        autofocus: true,
        onChanged: (v) {
          if (v.trim().isNotEmpty) learner.markMilestone('searched');
          setState(() => _query = v);
        },
        decoration: fieldDecoration(
          context,
          hint: 'Search concepts across every document',
          prefixIcon: Icon(Icons.search, size: 20, color: p.subtle),
          fill: p.card,
        ),
      ),
      const SizedBox(height: 14),
      Text(
        _query.trim().isEmpty
            ? 'Try "chain rule", "variance" or "validation".'
            : '${hits.length} passage${hits.length == 1 ? '' : 's'} in $docCount document${docCount == 1 ? '' : 's'}',
        style: TextStyle(color: p.mutedForeground),
      ),
      const SizedBox(height: 14),
      for (final hit in hits)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _HitCard(hit: hit),
        ),
    ];
  }

  List<Widget> _explore(BuildContext context) {
    final p = context.palette;
    final concept = conceptById(_topic);
    final found = passagesFor(_topic);
    final byDoc = <String, List<Passage>>{};
    for (final x in found) {
      byDoc.putIfAbsent(x.docId, () => []).add(x);
    }
    return [
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final c in concepts)
            ChoiceChip(
              label: Text(c.name),
              selected: c.id == _topic,
              onSelected: (_) {
                learner.markMilestone('topic');
                setState(() => _topic = c.id);
              },
            ),
        ],
      ),
      const SizedBox(height: 20),
      Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(concept.name, style: AppTheme.display(24)),
            const SizedBox(height: 10),
            Text(concept.standard, style: const TextStyle(height: 1.6)),
            const SizedBox(height: 14),
            Text(
              'Found in ${found.length} sections across ${byDoc.length} documents',
              style: TextStyle(color: p.mutedForeground, fontSize: 13),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      for (final entry in byDoc.entries) ...[
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 0, 8),
          child: Text(
            learner.docById(entry.key)?.title ?? '',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        for (final x in entry.value) SourceTile(passage: x),
      ],
    ];
  }
}

class _HitCard extends StatelessWidget {
  const _HitCard({required this.hit});

  final SearchHit hit;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final doc = learner.docById(hit.passage.docId);
    return Panel(
      padding: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => showSourceSheet(context, hit.passage, highlight: hit.terms),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (doc != null) DocTypeBadge(doc.type, size: 30),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(doc?.title ?? '', style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                  Text('p. ${hit.passage.page}', style: AppTheme.mono(11, color: p.subtle)),
                ],
              ),
              const SizedBox(height: 4),
              Text(hit.passage.section, style: TextStyle(color: p.mutedForeground, fontSize: 13)),
              const SizedBox(height: 10),
              Text.rich(
                TextSpan(children: highlightSpans(context, hit.passage.text, hit.terms)),
                style: const TextStyle(height: 1.55),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
