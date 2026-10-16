import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/course_card.dart';
import '../widgets/fade_slide_in.dart';
import 'page_scaffold.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  String _category = categories.first;

  @override
  Widget build(BuildContext context) {
    final visible = _category == 'All'
        ? courses
        : courses.where((c) => c.category == _category).toList();

    return PageScaffold(
      builder: (context, width) => [
        FadeSlideIn(child: Text('My courses', style: AppTheme.display(width >= 600 ? 34 : 28))),
        const SizedBox(height: 6),
        Text(
          '${courses.length} enrolled · ${courses.where((c) => c.lessonsDone == 0).length} not started',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 15),
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
