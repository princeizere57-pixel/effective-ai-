import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_palette.dart';
import '../theme/app_theme.dart';
import 'common.dart';
import 'progress_bar.dart';

class CourseCard extends StatefulWidget {
  const CourseCard({super.key, required this.course});

  final Course course;

  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final course = widget.course;
    final started = course.lessonsDone > 0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () => showToast(
          context,
          started ? 'Resuming "${course.title}"' : 'Starting "${course.title}"',
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.translationValues(0, _hover ? -2 : 0, 0),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: p.card,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: _hover ? p.cardHoverShadow : p.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: tint(course.accent),
                      borderRadius: BorderRadius.circular(AppRadius.base),
                    ),
                    child: Icon(course.icon, color: course.accent, size: 22),
                  ),
                  const Spacer(),
                  if (course.isNew) ...[
                    Pill(label: 'New', color: p.primaryText, background: tint(AppColors.violet)),
                    const SizedBox(width: 6),
                  ],
                  NeutralPill(course.category),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                course.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, height: 1.3),
              ),
              const SizedBox(height: 4),
              Text(course.instructor, style: TextStyle(color: p.mutedForeground, fontSize: 13)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    '${course.lessonsDone}/${course.lessonsTotal} lessons',
                    style: AppTheme.mono(11, color: p.subtle),
                  ),
                  const Spacer(),
                  Text(
                    started ? '${(course.progress * 100).round()}%' : 'Not started',
                    style: TextStyle(
                      color: started ? course.accent : p.subtle,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ProgressBar(value: course.progress, color: course.accent),
            ],
          ),
        ),
      ),
    );
  }
}
