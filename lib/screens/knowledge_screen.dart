import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../theme/app_colors.dart';
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
                selectedColor: AppColors.navy,
                backgroundColor: AppColors.surface,
                side: BorderSide(color: c == _category ? AppColors.navy : AppColors.divider),
                labelStyle: TextStyle(
                  color: c == _category ? Colors.white : AppColors.textSecondary,
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
