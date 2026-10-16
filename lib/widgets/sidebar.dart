import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../navigation.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'common.dart';

/// Navy sidebar: logo, streak, main sections, help/settings and the signed-in user.
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
    Widget tile(AppSection s) => _SidebarTile(
          section: s,
          selected: s == selected,
          onTap: () => onSelect(s),
        );

    return Container(
      width: width,
      decoration: const BoxDecoration(
        color: AppTokens.sidebarBg,
        boxShadow: AppShadows.sidebar,
      ),
      child: SafeArea(
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
                children: [for (final s in mainSections) tile(s)],
              ),
            ),
            const Divider(color: AppTokens.sidebarBorder, height: 1, thickness: 1),
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
            gradient: const LinearGradient(colors: [AppColors.violet, AppColors.blue]),
            borderRadius: BorderRadius.circular(10),
            boxShadow: AppShadows.violet,
          ),
          child: const Icon(Icons.auto_stories, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 10),
        Text('Effective AI', style: AppTheme.display(20, color: Colors.white)),
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
        color: AppColors.amber.withValues(alpha: 0.08),
        border: Border.all(color: AppColors.amber.withValues(alpha: 0.45)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Row(
        children: [
          Icon(Icons.local_fire_department_outlined, color: AppColors.amber, size: 18),
          SizedBox(width: 8),
          Text(
            '$streakDays-day streak',
            style: TextStyle(color: AppColors.amber, fontWeight: FontWeight.w600),
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
    final color = selected ? AppTokens.sidebarTextActive : AppTokens.sidebarText;
    final badge = section.badge;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          hoverColor: AppTokens.sidebarHover,
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: selected ? AppTokens.sidebarActive : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(section.icon, size: 21, color: selected ? AppColors.violetMuted : color),
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
                      color: AppColors.violet.withValues(alpha: 0.35),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$badge',
                      style: const TextStyle(
                        color: AppColors.violetMuted,
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
              gradient: LinearGradient(colors: [AppColors.violet, AppColors.blue]),
            ),
            child: Text(
              userFullName[0],
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userFullName,
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                ),
                Text(
                  userEmail,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: AppColors.navyText, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => showToast(context, 'Signed out'),
            icon: const Icon(Icons.logout, size: 20, color: AppColors.navyText),
            tooltip: 'Sign out',
          ),
        ],
      ),
    );
  }
}
