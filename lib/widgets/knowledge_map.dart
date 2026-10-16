import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/knowledge.dart';
import '../services/learner_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_palette.dart';

/// Feature 9: concepts as nodes, colored by mastery, with lines for every connection.
class KnowledgeMap extends StatelessWidget {
  const KnowledgeMap({super.key, required this.selected, required this.onSelect});

  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        const nodeW = 112.0;
        const nodeH = 44.0;
        final rx = math.max(w / 2 - nodeW / 2 - 8, 40.0);
        final ry = math.max(h / 2 - nodeH / 2 - 8, 40.0);
        final positions = <String, Offset>{
          for (var i = 0; i < concepts.length; i++)
            concepts[i].id: Offset(
              w / 2 + rx * math.cos(-math.pi / 2 + i * 2 * math.pi / concepts.length),
              h / 2 + ry * math.sin(-math.pi / 2 + i * 2 * math.pi / concepts.length),
            ),
        };

        return Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _EdgePainter(
                  positions: positions,
                  selected: selected,
                  base: p.border,
                  highlight: AppColors.violet,
                ),
              ),
            ),
            for (final c in concepts)
              Positioned(
                left: positions[c.id]!.dx - nodeW / 2,
                top: positions[c.id]!.dy - nodeH / 2,
                width: nodeW,
                height: nodeH,
                child: _Node(
                  concept: c,
                  selected: c.id == selected,
                  onTap: () => onSelect(c.id),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _Node extends StatelessWidget {
  const _Node({required this.concept, required this.selected, required this.onTap});

  final Concept concept;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final (_, color) = masteryStyle(learner.mastery(concept.id));
    return Material(
      color: selected ? AppColors.violet : p.card,
      shape: StadiumBorder(side: BorderSide(color: color, width: 2)),
      elevation: selected ? 4 : 1,
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Center(
            child: Text(
              concept.name,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.2,
                color: selected ? Colors.white : p.foreground,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EdgePainter extends CustomPainter {
  _EdgePainter({
    required this.positions,
    required this.selected,
    required this.base,
    required this.highlight,
  });

  final Map<String, Offset> positions;
  final String selected;
  final Color base;
  final Color highlight;

  @override
  void paint(Canvas canvas, Size size) {
    for (final link in conceptLinks) {
      final active = link.from == selected || link.to == selected;
      final paint = Paint()
        ..color = active ? highlight : base
        ..strokeWidth = active ? 2.5 : 1.5
        ..style = PaintingStyle.stroke;
      canvas.drawLine(positions[link.from]!, positions[link.to]!, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _EdgePainter old) =>
      old.selected != selected || old.base != base || old.positions != positions;
}
