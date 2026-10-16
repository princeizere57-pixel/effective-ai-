import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../theme/app_palette.dart';
import '../widgets/common.dart';
import '../widgets/course_card.dart';
import '../widgets/fade_slide_in.dart';
import 'page_scaffold.dart';

/// All enrolled courses, filterable by category. New courses carry a "New" label.
class KnowledgeScreen extends StatefulWidget {
  const KnowledgeScreen({super.key});

  @override
  State<KnowledgeScreen> createState() => _KnowledgeScreenState();
}

class _KnowledgeScreenState extends State<KnowledgeScreen> {
  String _category = categories.first;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final visible = _category == 'All'
        ? courses
        : courses.where((c) => c.category == _category).toList();
    final newCount = courses.where((c) => c.isNew).length;

    return PageScaffold(
      builder: (context, width) => [
        FadeSlideIn(
          child: PageHeader(
            title: 'My Knowledge',
            subtitle: '${courses.length} courses · $newCount new since your last visit',
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final c in categories)
              ChoiceChip(
                label: Text(c),
                selected: c == _category,
                onSelected: (_) => setState(() => _category = c),
                showCheckmark: false,
                selectedColor: p.foreground,
                backgroundColor: p.card,
                side: BorderSide(color: c == _category ? p.foreground : p.border),
                labelStyle: TextStyle(
                  color: c == _category ? p.background : p.mutedForeground,
                  fontWeight: FontWeight.w600,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
              ),
          ],
        ),
        const SizedBox(height: 20),
        FadeSlideIn(
          key: ValueKey(_category),
          child: ResponsiveGrid(
            minItemWidth: 260,
            children: [for (final c in visible) CourseCard(course: c)],
          ),
        ),
      ],
    );
  }
}
