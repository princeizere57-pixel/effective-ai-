import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/sidebar.dart';
import 'analytics_screen.dart';
import 'courses_screen.dart';
import 'dashboard_screen.dart';

/// Sidebar on wide screens, bottom navigation on phones.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  void _select(int i) => setState(() => _index = i);

  Widget _page() {
    switch (_index) {
      case 1:
        return const CoursesScreen();
      case 2:
        return const AnalyticsScreen();
      default:
        return DashboardScreen(onOpenCourses: () => _select(1));
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: KeyedSubtree(key: ValueKey(_index), child: _page()),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 900) {
          return Scaffold(
            body: Row(
              children: [
                Sidebar(selectedIndex: _index, onSelect: _select),
                Expanded(child: body),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.navy,
            foregroundColor: Colors.white,
            titleSpacing: 16,
            title: const BrandMark(),
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none),
                tooltip: 'Notifications',
              ),
            ],
          ),
          body: body,
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: _select,
            backgroundColor: AppColors.surface,
            indicatorColor: AppColors.violetPale,
            destinations: [
              for (final item in navItems)
                NavigationDestination(icon: Icon(item.icon), label: item.label),
            ],
          ),
        );
      },
    );
  }
}
