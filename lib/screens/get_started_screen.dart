import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../data/quests.dart';
import '../navigation.dart';
import '../services/learner_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_palette.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/hop.dart';
import 'page_scaffold.dart';

/// Get Started: a checklist of quests grouped by the Effective AI pipeline.
/// Steps complete themselves as the learner uses each feature; later groups
/// unlock as earlier ones progress.
class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen({super.key, required this.onNavigate});

  final ValueChanged<AppSection> onNavigate;

  @override
  State<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen> {
  /// Quests the learner opened or closed by hand; otherwise the current one is open.
  final _toggled = <String, bool>{};

  bool _isOpen(Quest q, bool isCurrent) => _toggled[q.title] ?? isCurrent;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: learner,
      builder: (context, _) {
        final done = completedQuests(learner);
        final total = totalQuests;
        // The current quest is the first unfinished one in the first open group.
        Quest? current;
        for (var i = 0; i < questGroups.length && current == null; i++) {
          if (!isGroupUnlocked(learner, i)) break;
          for (final q in questGroups[i].quests) {
            if (q.status(learner) != QuestStatus.completed) {
              current = q;
              break;
            }
          }
        }

        return PageScaffold(
          builder: (context, width) => [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FadeSlideIn(child: _Header(done: done, total: total)),
                    const SizedBox(height: 20),
                    for (var i = 0; i < questGroups.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: FadeSlideIn(
                          delay: Duration(milliseconds: 60 * i),
                          child: _GroupPanel(
                            group: questGroups[i],
                            unlocked: isGroupUnlocked(learner, i),
                            previous: i == 0 ? null : questGroups[i - 1].title,
                            current: current,
                            isOpen: _isOpen,
                            onToggle: (q, open) => setState(() => _toggled[q.title] = open),
                            onNavigate: widget.onNavigate,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.done, required this.total});

  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final finished = done == total;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                finished ? 'You’re all set, $userFirstName' : 'You’re on your way, $userFirstName',
                style: AppTheme.display(24),
              ),
              const SizedBox(height: 4),
              Text('$done of $total completed', style: TextStyle(color: p.mutedForeground)),
            ],
          ),
        ),
        SizedBox(
          width: 44,
          height: 44,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: total == 0 ? 0 : done / total),
            duration: const Duration(milliseconds: 900),
            curve: AppTheme.easeOutExpo,
            builder: (context, v, _) => CircularProgressIndicator(
              value: v,
              strokeWidth: 5,
              backgroundColor: tint(AppColors.brand, 0.15),
              color: AppColors.brand,
              strokeCap: StrokeCap.round,
            ),
          ),
        ),
      ],
    );
  }
}

class _GroupPanel extends StatelessWidget {
  const _GroupPanel({
    required this.group,
    required this.unlocked,
    required this.previous,
    required this.current,
    required this.isOpen,
    required this.onToggle,
    required this.onNavigate,
  });

  final QuestGroup group;
  final bool unlocked;
  final String? previous;
  final Quest? current;
  final bool Function(Quest q, bool isCurrent) isOpen;
  final void Function(Quest q, bool open) onToggle;
  final ValueChanged<AppSection> onNavigate;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final header = Row(
      children: [
        HopIcon(child: Icon(group.icon, size: 20, color: AppColors.brand)),
        const SizedBox(width: 10),
        Text(group.title, style: AppTheme.display(20)),
        const SizedBox(width: 10),
        Text('${group.quests.length} quests', style: TextStyle(color: p.mutedForeground, fontSize: 12)),
        const Spacer(),
        if (unlocked)
          Text('${group.completedCount(learner)}/${group.quests.length}', style: AppTheme.mono(12, color: p.mutedForeground))
        else
          Icon(Icons.lock_outline, size: 18, color: p.mutedForeground),
      ],
    );

    return HopRegion(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: p.muted, borderRadius: BorderRadius.circular(AppRadius.lg)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (unlocked)
              Padding(padding: const EdgeInsets.fromLTRB(6, 4, 6, 10), child: header)
            else
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.base),
                  onTap: () => showToast(context, 'Finish a quest in $previous to unlock ${group.title}'),
                  child: Padding(padding: const EdgeInsets.fromLTRB(6, 6, 6, 6), child: header),
                ),
              ),
            if (unlocked)
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 0, 6, 10),
                child: Text(group.summary, style: TextStyle(color: p.mutedForeground, fontSize: 13)),
              ),
            if (unlocked)
              for (final q in group.quests)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _QuestCard(
                    quest: q,
                    open: isOpen(q, q == current),
                    onToggle: (open) => onToggle(q, open),
                    onNavigate: onNavigate,
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _QuestCard extends StatelessWidget {
  const _QuestCard({required this.quest, required this.open, required this.onToggle, required this.onNavigate});

  final Quest quest;
  final bool open;
  final ValueChanged<bool> onToggle;
  final ValueChanged<AppSection> onNavigate;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final status = quest.status(learner);
    final done = quest.doneCount(learner);
    final next = quest.nextStep(learner);
    final (statusIcon, statusLabel) = switch (status) {
      QuestStatus.completed => (Icons.check_circle_outline, 'Completed'),
      QuestStatus.inProgress => (Icons.timelapse, 'In progress'),
      QuestStatus.notStarted => (Icons.circle_outlined, 'Not started'),
    };

    return HopRegion(
      child: Container(
        decoration: BoxDecoration(
          color: p.card,
          borderRadius: BorderRadius.circular(AppRadius.base),
          border: Border.all(color: p.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.base),
                onTap: () => onToggle(!open),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
                  child: Row(
                    children: [
                      HopIcon(height: 5, child: Icon(statusIcon, size: 20, color: AppColors.brand)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(quest.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 2),
                            Text(quest.description, style: TextStyle(color: p.mutedForeground, fontSize: 12)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Pill(
                        label: statusLabel,
                        color: AppColors.brand,
                        background: status == QuestStatus.completed ? tint(AppColors.brand, 0.18) : tint(AppColors.brand, 0.08),
                      ),
                      Icon(open ? Icons.expand_less : Icons.expand_more, color: p.mutedForeground),
                    ],
                  ),
                ),
              ),
            ),
            if (open)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // One segment per step, filled as steps are done.
                    Row(
                      children: [
                        for (var i = 0; i < quest.steps.length; i++)
                          Expanded(
                            child: Container(
                              height: 4,
                              margin: EdgeInsets.only(right: i < quest.steps.length - 1 ? 6 : 0),
                              decoration: BoxDecoration(
                                color: i < done ? AppColors.brand : tint(AppColors.brand, 0.15),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    for (final step in quest.steps)
                      if (step == next)
                        _CurrentStep(step: step, onOpen: () => onNavigate(step.section))
                      else
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                          child: Row(
                            children: [
                              Icon(
                                step.isDone(learner) ? Icons.check_circle_outline : Icons.circle_outlined,
                                size: 18,
                                color: AppColors.brand,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  step.title,
                                  style: TextStyle(
                                    decoration: step.isDone(learner) ? TextDecoration.lineThrough : null,
                                    decorationColor: AppColors.brand,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The next thing to do, highlighted, with a button that goes straight there.
class _CurrentStep extends StatelessWidget {
  const _CurrentStep({required this.step, required this.onOpen});

  final QuestStep step;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.fromLTRB(10, 6, 6, 10),
      decoration: BoxDecoration(
        color: tint(AppColors.brand, 0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.radio_button_checked, size: 18, color: AppColors.brand),
              const SizedBox(width: 10),
              Expanded(child: Text(step.title, style: const TextStyle(fontWeight: FontWeight.w600))),
              TextButton.icon(
                onPressed: onOpen,
                icon: const Icon(Icons.open_in_new, size: 16),
                label: const Text('Open'),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 28, right: 8),
            child: Text(step.detail, style: TextStyle(color: p.mutedForeground, fontSize: 13, height: 1.4)),
          ),
        ],
      ),
    );
  }
}
