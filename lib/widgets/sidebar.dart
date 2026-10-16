import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'common.dart';

class NavItem {
  const NavItem(this.label, this.icon);

  final String label;
  final IconData icon;
}

const navItems = <NavItem>[
  NavItem('Dashboard', Icons.space_dashboard_outlined),
  NavItem('Courses', Icons.menu_book_outlined),
  NavItem('Analytics', Icons.insights_outlined),
];

class Sidebar extends StatelessWidget {
  const Sidebar({super.key, required this.selectedIndex, required this.onSelect});

  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 248,
      color: AppColors.navy,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BrandMark(),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.only(left: 12, bottom: 8),
            child: Text(
              'MENU',
              style: AppTheme.mono(10, color: AppColors.navyMuted).copyWith(letterSpacing: 1.4),
            ),
          ),
          for (var i = 0; i < navItems.length; i++)
            _SidebarTile(
              item: navItems[i],
              selected: i == selectedIndex,
              onTap: () => onSelect(i),
            ),
          const Spacer(),
          const _UpgradeCard(),
          const SizedBox(height: 16),
          const _UserTile(),
        ],
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
          child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 10),
        Text('LearnSpace', style: AppTheme.display(20, color: Colors.white)),
      ],
    );
  }
}

class _SidebarTile extends StatelessWidget {
  const _SidebarTile({required this.item, required this.selected, required this.onTap});

  final NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? Colors.white : AppColors.navyText;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              color: selected ? AppColors.navyLighter : Colors.transparent,
              border: Border.all(color: selected ? AppColors.navyBorder : Colors.transparent),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(item.icon, size: 20, color: selected ? AppColors.violetLight : color),
                const SizedBox(width: 12),
                Text(
                  item.label,
                  style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UpgradeCard extends StatelessWidget {
  const _UpgradeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.navyLight,
        border: Border.all(color: AppColors.navyBorder),
        borderRadius: BorderRadius.circular(AppRadius.xl2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Go Pro',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            'Unlock the AI tutor and offline lessons.',
            style: TextStyle(color: AppColors.navyText, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => showToast(context, 'Pro plans are coming soon'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.violet,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Upgrade'),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.violet,
          child: Text(
            userFullName[0],
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userFullName,
                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
              ),
              Text(userEmail, style: TextStyle(color: AppColors.navyText, fontSize: 11)),
            ],
          ),
        ),
        const Icon(Icons.more_horiz, color: AppColors.navyText),
      ],
    );
  }
}
