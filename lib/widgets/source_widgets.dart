import 'package:flutter/material.dart';

import '../data/knowledge.dart';
import '../services/knowledge_engine.dart';
import '../services/learner_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_palette.dart';
import '../theme/app_theme.dart';
import 'progress_bar.dart';

/// Colored icon for a document type.
class DocTypeBadge extends StatelessWidget {
  const DocTypeBadge(this.type, {super.key, this.size = 40});

  final DocType type;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: tint(type.color),
        borderRadius: BorderRadius.circular(AppRadius.base),
      ),
      child: Icon(type.icon, color: type.color, size: size * 0.5),
    );
  }
}

/// A citation: document, page and section. Tapping opens the exact passage.
class SourceTile extends StatelessWidget {
  const SourceTile({super.key, required this.passage, this.index, this.highlight = const {}});

  final Passage passage;
  final int? index;
  final Set<String> highlight;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final doc = learner.docById(passage.docId);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: p.muted,
        borderRadius: BorderRadius.circular(AppRadius.base),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.base),
          onTap: () => showSourceSheet(context, passage, highlight: highlight),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                if (index != null) ...[
                  CitationMarker(index!),
                  const SizedBox(width: 10),
                ] else if (doc != null) ...[
                  DocTypeBadge(doc.type, size: 28),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doc?.title ?? 'Unknown document',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      Text(
                        'p. ${passage.page} · ${passage.section}',
                        style: AppTheme.mono(11, color: p.subtle),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: p.subtle, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CitationMarker extends StatelessWidget {
  const CitationMarker(this.number, {super.key, this.onTap});

  final int number;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final marker = Container(
      width: 20,
      height: 20,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: tint(AppColors.brand, 0.2), shape: BoxShape.circle),
      child: Text(
        '$number',
        style: TextStyle(
          color: context.palette.primaryText,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
    return onTap == null ? marker : InkWell(onTap: onTap, customBorder: const CircleBorder(), child: marker);
  }
}

/// Source verification: shows the exact passage an answer or question came from.
Future<void> showSourceSheet(BuildContext context, Passage passage, {Set<String> highlight = const {}}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) {
      final p = context.palette;
      final doc = learner.docById(passage.docId);
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (doc != null) DocTypeBadge(doc.type),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doc?.title ?? 'Unknown document',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          'Page ${passage.page} · ${passage.section}',
                          style: AppTheme.mono(12, color: p.mutedForeground),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                decoration: BoxDecoration(
                  color: p.muted,
                  border: Border(left: BorderSide(color: AppColors.brand, width: 3)),
                ),
                child: Text.rich(
                  TextSpan(children: highlightSpans(context, passage.text, highlight)),
                  style: const TextStyle(fontSize: 15, height: 1.6),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'This is the exact passage from your document.',
                style: TextStyle(color: p.subtle, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Splits [text] into spans, marking words whose stem is in [terms].
List<TextSpan> highlightSpans(BuildContext context, String text, Set<String> terms) {
  if (terms.isEmpty) return [TextSpan(text: text)];
  final mark = TextStyle(
    fontWeight: FontWeight.w700,
    backgroundColor: tint(AppColors.brand, 0.3),
  );
  return [
    for (final m in RegExp(r'[A-Za-zλ]+|[^A-Za-zλ]+').allMatches(text))
      TextSpan(
        text: m.group(0),
        style: terms.contains(KnowledgeEngine.stemOf(m.group(0)!)) ? mark : null,
      ),
  ];
}

/// Tabs inside a screen.
class TabSwitch extends StatelessWidget {
  const TabSwitch({super.key, required this.labels, required this.index, required this.onChanged});

  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SegmentedButton<int>(
        segments: [
          for (var i = 0; i < labels.length; i++) ButtonSegment(value: i, label: Text(labels[i])),
        ],
        selected: {index},
        showSelectedIcon: false,
        onSelectionChanged: (s) => onChanged(s.first),
      ),
    );
  }
}

/// Choose which documents a feature may use. An empty selection means all.
class MaterialSelector extends StatelessWidget {
  const MaterialSelector({super.key, required this.selected, required this.onChanged});

  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilterChip(
          label: const Text('All materials'),
          selected: selected.isEmpty,
          onSelected: (_) => onChanged({}),
          showCheckmark: false,
          selectedColor: tint(AppColors.brand, 0.2),
          labelStyle: TextStyle(color: selected.isEmpty ? p.primaryText : p.mutedForeground),
        ),
        for (final d in learner.indexedDocs)
          FilterChip(
            avatar: Icon(d.type.icon, size: 16, color: d.type.color),
            label: Text(d.title),
            selected: selected.contains(d.id),
            showCheckmark: false,
            selectedColor: tint(AppColors.brand, 0.2),
            labelStyle: TextStyle(color: selected.contains(d.id) ? p.primaryText : p.mutedForeground),
            onSelected: (on) {
              final next = {...selected};
              on ? next.add(d.id) : next.remove(d.id);
              onChanged(next);
            },
          ),
      ],
    );
  }
}

/// Concept name, mastery bar and label on one row.
class MasteryRow extends StatelessWidget {
  const MasteryRow({super.key, required this.concept, this.trailing});

  final Concept concept;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final m = learner.mastery(concept.id);
    final (label, color) = masteryStyle(m);
    final a = learner.attemptsOf(concept.id);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(concept.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      a == null ? label : '$label · ${a.$1}/${a.$2}',
                      style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ProgressBar(value: m ?? 0, color: color, height: 6),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 16), trailing!],
          if (trailing == null) ...[
            const SizedBox(width: 12),
            Text(percent(m), style: AppTheme.mono(12, color: p.mutedForeground)),
          ],
        ],
      ),
    );
  }
}
