import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../data/quests.dart';
import '../navigation.dart';
import '../services/learner_state.dart';
import '../services/session.dart';
import '../theme/app_colors.dart';
import '../theme/app_palette.dart';
import '../theme/app_theme.dart';
import 'hop.dart';
import 'logo_mark.dart';
import 'progress_bar.dart';

/// Sidebar: logo, streak, main sections, help/settings and the signed-in user.
///
/// Desktop shows it full width with labels, tablet shows it as a slim icon
/// rail ([compact]), and phones put the full version inside a Drawer.
class Sidebar extends StatelessWidget {
  const Sidebar({
    super.key,
    required this.selected,
    required this.onSelect,
    this.width = 264,
    this.compact = false,
  });

  final AppSection selected;
  final ValueChanged<AppSection> onSelect;
  final double width;

  /// Icon-only rail for tablets; labels appear as tooltips.
  final bool compact;

  static const railWidth = 76.0;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    Widget tile(AppSection s) => _SidebarTile(
          section: s,
          selected: s == selected,
          compact: compact,
          onTap: () => onSelect(s),
        );

    return Container(
      width: compact ? railWidth : width,
      decoration: BoxDecoration(
        color: p.sidebarBg,
        border: Border(right: BorderSide(color: p.sidebarBorder)),
      ),
      // Rebuild when gaps or reviews change so the badges stay current.
      child: ListenableBuilder(
        listenable: learner,
        builder: (context, _) => SafeArea(
          right: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: compact ? const EdgeInsets.only(top: 20) : const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: compact ? const Center(child: BrandMark(showName: false)) : const BrandMark(),
              ),
              Padding(
                padding: compact ? const EdgeInsets.fromLTRB(10, 16, 10, 8) : const EdgeInsets.fromLTRB(12, 24, 12, 12),
                child: StreakPill(compact: compact),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 12),
                  children: [
                    for (final (label, sections) in sidebarGroups) ...[
                      if (label != null)
                        compact
                            ? Divider(height: 18, color: p.sidebarBorder)
                            : Padding(
                                padding: const EdgeInsets.fromLTRB(14, 14, 0, 6),
                                child: Text(
                                  label,
                                  style: AppTheme.mono(10, color: p.sidebarText.withValues(alpha: 0.7))
                                      .copyWith(letterSpacing: 1.4),
                                ),
                              ),
                      for (final s in sections) tile(s),
                    ],
                  ],
                ),
              ),
              if (!allQuestsDone(learner))
                Padding(
                  padding: compact ? const EdgeInsets.fromLTRB(10, 8, 10, 10) : const EdgeInsets.fromLTRB(12, 8, 12, 12),
                  child: _ChecklistCard(compact: compact, onOpen: () => onSelect(AppSection.getStarted)),
                ),
              Divider(color: p.sidebarBorder, height: 1, thickness: 1),
              Padding(
                padding: compact ? const EdgeInsets.fromLTRB(10, 10, 10, 12) : const EdgeInsets.fromLTRB(12, 12, 12, 16),
                child: Column(
                  children: [
                    for (final s in footerSections) tile(s),
                    const SizedBox(height: 8),
                    _UserTile(compact: compact),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom-of-sidebar nudge: how far through the Get Started checklist the learner is.
class _ChecklistCard extends StatelessWidget {
  const _ChecklistCard({required this.compact, required this.onOpen});

  final bool compact;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final done = completedQuests(learner);
    final total = totalQuests;
    final progress = total == 0 ? 0.0 : done / total;

    if (compact) {
      return Tooltip(
        message: 'Get started: $done of $total quests',
        child: InkWell(
          onTap: onOpen,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 44,
            height: 44,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 3,
                  backgroundColor: tint(AppColors.brand, 0.15),
                  color: AppColors.brand,
                ),
                HopIcon(child: Icon(Icons.rocket_launch_outlined, size: 18, color: AppColors.brand)),
              ],
            ),
          ),
        ),
      );
    }

    return HopRegion(
      child: Container(
        decoration: BoxDecoration(
          color: p.card,
          borderRadius: BorderRadius.circular(AppRadius.base),
          border: Border.all(color: p.sidebarBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HopIcon(child: Icon(Icons.rocket_launch_outlined, size: 18, color: AppColors.brand)),
                  const SizedBox(height: 8),
                  Text(
                    'Complete the remaining steps in the checklist to get started',
                    style: TextStyle(color: p.sidebarText, fontSize: 12, height: 1.4),
                  ),
                  const SizedBox(height: 10),
                  ProgressBar(value: progress, height: 5),
                ],
              ),
            ),
            Material(
              color: p.sidebarHover,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(AppRadius.base)),
              child: InkWell(
                onTap: onOpen,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(AppRadius.base)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  child: Row(
                    children: [
                      Text('Get started', style: TextStyle(color: p.sidebarTextActive, fontWeight: FontWeight.w700, fontSize: 13)),
                      const Spacer(),
                      Icon(Icons.arrow_forward, size: 16, color: p.sidebarTextActive),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.showName = true});

  /// Phones and the tablet rail show only the logo.
  final bool showName;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const LogoMark(),
        if (showName) ...[
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              'Effective AI',
              overflow: TextOverflow.ellipsis,
              style: AppTheme.display(20, color: context.palette.sidebarTextActive),
            ),
          ),
        ],
      ],
    );
  }
}

class StreakPill extends StatelessWidget {
  const StreakPill({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final pill = Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 0 : 16, vertical: compact ? 8 : 10),
      decoration: BoxDecoration(
        color: tint(AppColors.brand, 0.08),
        border: Border.all(color: AppColors.brand.withValues(alpha: 0.45)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_fire_department_outlined, color: AppColors.brand, size: 18),
          SizedBox(width: compact ? 2 : 8),
          Flexible(
            child: Text(
              compact ? '$streakDays' : '$streakDays-day streak',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: AppColors.brand, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
    return compact ? Tooltip(message: '$streakDays-day streak', child: pill) : pill;
  }
}

class _SidebarTile extends StatelessWidget {
  const _SidebarTile({
    required this.section,
    required this.selected,
    required this.compact,
    required this.onTap,
  });

  final AppSection section;
  final bool selected;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final color = selected ? p.sidebarTextActive : p.sidebarText;
    final badge = section.badge;
    final hasBadge = badge != null && badge > 0;

    final Widget content = compact
        ? Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              HopIcon(child: Icon(section.icon, size: 22, color: color)),
              if (hasBadge)
                Positioned(
                  top: -6,
                  right: -10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(color: AppColors.brand, borderRadius: BorderRadius.circular(999)),
                    child: Text(
                      '$badge',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
            ],
          )
        : Row(
            children: [
              HopIcon(child: Icon(section.icon, size: 21, color: color)),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  section.label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
              if (hasBadge)
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: tint(AppColors.brand, 0.14), shape: BoxShape.circle),
                  child: Text(
                    '$badge',
                    style: TextStyle(color: AppColors.brand, fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
            ],
          );

    final tileBody = Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          hoverColor: p.sidebarHover,
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: compact ? const EdgeInsets.symmetric(vertical: 12) : const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: selected ? p.sidebarActive : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: content,
          ),
        ),
      ),
    );
    final hopping = HopRegion(child: tileBody);
    return compact ? Tooltip(message: section.label, preferBelow: false, child: hopping) : hopping;
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final avatar = Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.brand),
      child: Text(
        userFullName[0],
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
      ),
    );
    final logout = IconButton(
      onPressed: signOut,
      icon: Icon(Icons.logout, size: 20, color: p.sidebarText),
      tooltip: 'Sign out',
    );

    if (compact) {
      return Column(
        children: [Tooltip(message: '$userFullName\n$userEmail', child: avatar), logout],
      );
    }
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Row(
        children: [
          avatar,
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userFullName,
                  style: TextStyle(color: p.sidebarTextActive, fontSize: 14, fontWeight: FontWeight.w600),
                ),
                Text(
                  userEmail,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: p.sidebarText, fontSize: 12),
                ),
              ],
            ),
          ),
          logout,
        ],
      ),
    );
  }
}
