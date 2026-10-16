import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../navigation.dart';
import '../services/learner_state.dart';
import '../services/session.dart';
import '../theme/app_colors.dart';
import '../theme/app_palette.dart';
import '../theme/app_theme.dart';
import 'common.dart';

/// Sidebar: logo, streak, main sections, help/settings and the signed-in user.
/// Used as a fixed column on wide screens and inside a Drawer on phones.
class Sidebar extends StatelessWidget {
  const Sidebar({
    super.key,
    required this.selected,
    required this.onSelect,
    this.width = 264,
  });

  final AppSection selected;
  final ValueChanged<AppSection> onSelect;
  final double width;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    Widget tile(AppSection s) => _SidebarTile(
          section: s,
          selected: s == selected,
          onTap: () => onSelect(s),
        );

    return Container(
      width: width,
      decoration: BoxDecoration(color: p.sidebarBg, boxShadow: AppShadows.sidebar),
      // Rebuild when gaps or reviews change so the badges stay current.
      child: ListenableBuilder(
        listenable: learner,
        builder: (context, _) => SafeArea(
        right: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: BrandMark(),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(12, 24, 12, 12),
              child: StreakPill(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  for (final (label, sections) in sidebarGroups) ...[
                    if (label != null)
                      Padding(
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
            Divider(color: p.sidebarBorder, height: 1, thickness: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
              child: Column(
                children: [
                  for (final s in footerSections) tile(s),
                  const SizedBox(height: 12),
                  const _UserTile(),
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

class BrandMark extends StatelessWidget {
  const BrandMark({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.brand, AppColors.brand]),
            borderRadius: BorderRadius.circular(10),
            boxShadow: AppShadows.brand,
          ),
          child: const Icon(Icons.auto_stories, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 10),
        Text('Effective AI', style: AppTheme.display(20, color: context.palette.sidebarTextActive)),
      ],
    );
  }
}

class StreakPill extends StatelessWidget {
  const StreakPill({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: tint(AppColors.brand, 0.08),
        border: Border.all(color: AppColors.brand.withValues(alpha: 0.45)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Row(
        children: [
          Icon(Icons.local_fire_department_outlined, color: AppColors.brand, size: 18),
          SizedBox(width: 8),
          Text(
            '$streakDays-day streak',
            style: TextStyle(color: AppColors.brand, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _SidebarTile extends StatelessWidget {
  const _SidebarTile({required this.section, required this.selected, required this.onTap});

  final AppSection section;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final color = selected ? p.sidebarTextActive : p.sidebarText;
    final badge = section.badge;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          hoverColor: p.sidebarHover,
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: selected ? p.sidebarActive : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(section.icon, size: 21, color: selected ? AppColors.brand : color),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    section.label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
                if (badge != null && badge > 0)
                  Container(
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: tint(AppColors.brand, 0.14),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$badge',
                      style: const TextStyle(
                        color: AppColors.brand,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [AppColors.brand, AppColors.brand]),
            ),
            child: Text(
              userFullName[0],
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userFullName,
                  style: TextStyle(
                    color: p.sidebarTextActive,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  userEmail,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: p.sidebarText, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: signOut,
            icon: Icon(Icons.logout, size: 20, color: p.sidebarText),
            tooltip: 'Sign out',
          ),
        ],
      ),
    );
  }
}
