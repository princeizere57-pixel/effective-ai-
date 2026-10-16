import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/charts.dart';
import '../widgets/common.dart';
import '../widgets/course_card.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/stat_card.dart';
import 'page_scaffold.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.onOpenCourses});

  final VoidCallback onOpenCourses;

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      builder: (context, width) => [
        FadeSlideIn(child: _Header(wide: width >= 900)),
        const SizedBox(height: 24),
        FadeSlideIn(
          delay: const Duration(milliseconds: 80),
          child: ResponsiveGrid(
            minItemWidth: 200,
            children: [for (final s in stats) StatCard(stat: s)],
          ),
        ),
        const SizedBox(height: 32),
        FadeSlideIn(
          delay: const Duration(milliseconds: 160),
          child: SectionHeader(
            title: 'Continue learning',
            action: 'All courses',
            onAction: onOpenCourses,
          ),
        ),
        const SizedBox(height: 12),
        FadeSlideIn(
          delay: const Duration(milliseconds: 200),
          child: ResponsiveGrid(
            minItemWidth: 260,
            children: [for (final c in courses.take(3)) CourseCard(course: c)],
          ),
        ),
        const SizedBox(height: 32),
        FadeSlideIn(
          delay: const Duration(milliseconds: 260),
          child: width >= 900
              ? const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: _StudyTimePanel()),
                    SizedBox(width: 16),
                    Expanded(flex: 2, child: _DeadlinesPanel()),
                  ],
                )
              : const Column(
                  children: [_StudyTimePanel(), SizedBox(height: 16), _DeadlinesPanel()],
                ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.wide});

  final bool wide;

  @override
  Widget build(BuildContext context) {
    final greeting = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Good morning, $userFirstName', style: AppTheme.display(wide ? 34 : 28)),
        const SizedBox(height: 6),
        const Text(
          "You're on a $streakDays-day streak. One lesson today keeps it going.",
          style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
        ),
      ],
    );

    if (!wide) return greeting;

    return Row(
      children: [
        Expanded(child: greeting),
        const SizedBox(width: 280, child: _SearchField()),
        const SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: IconButton(
            onPressed: () => showToast(context, 'No new notifications'),
            icon: const Badge(
              smallSize: 8,
              backgroundColor: AppColors.red,
              child: Icon(Icons.notifications_none, color: AppColors.textSecondary),
            ),
            tooltip: 'Notifications',
          ),
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color c) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c),
        );

    return TextField(
      decoration: InputDecoration(
        hintText: 'Search courses and notes',
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
        prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textMuted),
        filled: true,
        fillColor: AppColors.surface,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: border(AppColors.divider),
        enabledBorder: border(AppColors.divider),
        focusedBorder: border(AppColors.violet),
      ),
    );
  }
}

class _StudyTimePanel extends StatelessWidget {
  const _StudyTimePanel();

  @override
  Widget build(BuildContext context) {
    final total = weeklyHours.fold<double>(0, (sum, d) => sum + d.$2);
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Study time',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${total.toStringAsFixed(1)} hours this week',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Pill(
                label: '+18% vs last week',
                color: AppColors.green,
                background: AppColors.greenPale,
              ),
            ],
          ),
          const SizedBox(height: 24),
          const SizedBox(height: 220, child: WeeklyHoursChart(data: weeklyHours)),
        ],
      ),
    );
  }
}

class _DeadlinesPanel extends StatelessWidget {
  const _DeadlinesPanel();

  @override
  Widget build(BuildContext context) {
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Upcoming', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          for (final d in deadlines) _DeadlineTile(deadline: d),
        ],
      ),
    );
  }
}

class _DeadlineTile extends StatelessWidget {
  const _DeadlineTile({required this.deadline});

  final Deadline deadline;

  (Color, Color) get _colors => switch (deadline.status) {
        DeadlineStatus.overdue => (AppColors.red, AppColors.redPale),
        DeadlineStatus.soon => (AppColors.amber, AppColors.amberPale),
        DeadlineStatus.upcoming => (AppColors.blue, AppColors.bluePale),
        DeadlineStatus.done => (AppColors.green, AppColors.greenPale),
      };

  @override
  Widget build(BuildContext context) {
    final (fg, bg) = _colors;
    final done = deadline.status == DeadlineStatus.done;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  deadline.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: done ? AppColors.textMuted : AppColors.textPrimary,
                    decoration: done ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  deadline.course,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Pill(label: deadline.due, color: fg, background: bg),
        ],
      ),
    );
  }
}
