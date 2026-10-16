import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_palette.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/progress_bar.dart';
import 'page_scaffold.dart';

/// Study sessions for the coming days, grouped by day, each with a checkbox.
class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  final _done = <int>{};

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final days = <String>[];
    for (final s in planSessions) {
      if (!days.contains(s.day)) days.add(s.day);
    }
    final totalMinutes = planSessions.fold<int>(0, (sum, s) => sum + s.minutes);

    return PageScaffold(
      builder: (context, width) => [
        FadeSlideIn(
          child: PageHeader(
            title: 'My Plan',
            subtitle: '${planSessions.length} sessions · $totalMinutes minutes planned',
          ),
        ),
        const SizedBox(height: 20),
        Panel(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('This week', style: TextStyle(fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Text(
                    '${_done.length} of ${planSessions.length} done',
                    style: AppTheme.mono(12, color: p.mutedForeground),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ProgressBar(value: _done.length / planSessions.length, height: 8),
            ],
          ),
        ),
        const SizedBox(height: 16),
        for (final day in days) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 12, 0, 8),
            child: Text(
              day.toUpperCase(),
              style: AppTheme.mono(11, color: p.subtle).copyWith(letterSpacing: 1.2),
            ),
          ),
          Panel(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                for (var i = 0; i < planSessions.length; i++)
                  if (planSessions[i].day == day)
                    CheckboxListTile(
                      value: _done.contains(i),
                      onChanged: (v) => setState(() => v == true ? _done.add(i) : _done.remove(i)),
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: AppColors.violet,
                      title: Text(
                        planSessions[i].title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _done.contains(i) ? p.subtle : null,
                          decoration: _done.contains(i) ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      subtitle: Text(
                        '${planSessions[i].time} · ${planSessions[i].course}',
                        style: TextStyle(color: p.mutedForeground, fontSize: 12),
                      ),
                      secondary: NeutralPill('${planSessions[i].minutes} min'),
                    ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
