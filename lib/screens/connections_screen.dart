import 'package:flutter/material.dart';

import '../data/knowledge.dart';
import '../services/learner_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_palette.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/knowledge_map.dart';
import '../widgets/source_widgets.dart';
import 'page_scaffold.dart';

/// Features 7, 8 and 9: Concept Connections, Compare Sources, Knowledge Map.
class ConnectionsScreen extends StatefulWidget {
  const ConnectionsScreen({super.key});

  @override
  State<ConnectionsScreen> createState() => _ConnectionsScreenState();
}

class _ConnectionsScreenState extends State<ConnectionsScreen> {
  int _tab = 0;
  String _selected = 'gd';
  String _compare = comparisons.first.conceptId;

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      builder: (context, width) => [
        const FadeSlideIn(
          child: PageHeader(
            title: 'Connections',
            subtitle: 'See how ideas fit together, and where your sources agree or disagree.',
          ),
        ),
        const SizedBox(height: 20),
        TabSwitch(
          labels: const ['Knowledge map', 'Compare sources'],
          index: _tab,
          onChanged: (i) => setState(() => _tab = i),
        ),
        const SizedBox(height: 20),
        if (_tab == 0) ..._map(context, width) else ..._compareView(context),
      ],
    );
  }

  List<Widget> _map(BuildContext context, double width) {
    final p = context.palette;
    final concept = conceptById(_selected);
    final (label, color) = masteryStyle(learner.mastery(_selected));
    return [
      Panel(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            SizedBox(
              height: width < 600 ? 380 : 420,
              child: KnowledgeMap(selected: _selected, onSelect: (id) => setState(() => _selected = id)),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children: [
                for (final m in [0.9, 0.7, 0.3, null])
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(color: masteryStyle(m).$2, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Text(masteryStyle(m).$1, style: TextStyle(color: p.mutedForeground, fontSize: 12)),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(concept.name, style: AppTheme.display(22))),
                Pill(label: label, color: color),
              ],
            ),
            const SizedBox(height: 8),
            Text(concept.simple, style: TextStyle(color: p.mutedForeground, height: 1.5)),
            const SizedBox(height: 16),
            const Text('How it connects', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            for (final link in linksFor(_selected))
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.base),
                  onTap: () => setState(() => _selected = link.from == _selected ? link.to : link.from),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.link, size: 18, color: AppColors.brand),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '${conceptById(link.from == _selected ? link.to : link.from).name}: ',
                                  style: const TextStyle(fontWeight: FontWeight.w700),
                                ),
                                TextSpan(text: link.how),
                              ],
                            ),
                            style: const TextStyle(height: 1.45),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _compareView(BuildContext context) {
    final p = context.palette;
    final comparison = comparisons.firstWhere((c) => c.conceptId == _compare);
    return [
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final c in comparisons)
            ChoiceChip(
              label: Text(conceptById(c.conceptId).name),
              selected: c.conceptId == _compare,
              onSelected: (_) => setState(() => _compare = c.conceptId),
            ),
        ],
      ),
      const SizedBox(height: 20),
      ResponsiveGrid(
        minItemWidth: 280,
        children: [
          for (final view in comparison.views)
            Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    learner.docById(passageById(view.passageId).docId)?.title ?? '',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  Text('"${view.claim}"', style: const TextStyle(fontSize: 15, height: 1.55)),
                  const SizedBox(height: 12),
                  SourceTile(passage: passageById(view.passageId)),
                ],
              ),
            ),
        ],
      ),
      const SizedBox(height: 16),
      _Verdict(
        icon: Icons.check_circle_outline,
        color: AppColors.brand,
        title: 'Where they agree',
        text: comparison.agreement,
      ),
      const SizedBox(height: 12),
      _Verdict(
        icon: Icons.compare_arrows,
        color: AppColors.brand,
        title: 'Where they differ',
        text: comparison.difference,
      ),
      const SizedBox(height: 8),
      Text(
        'Comparisons are prepared from your sample materials. With the AI backend they are generated for any concept.',
        style: TextStyle(color: p.subtle, fontSize: 12),
      ),
    ];
  }
}

class _Verdict extends StatelessWidget {
  const _Verdict({required this.icon, required this.color, required this.title, required this.text});

  final IconData icon;
  final Color color;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Panel(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(text, style: TextStyle(color: context.palette.mutedForeground, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
