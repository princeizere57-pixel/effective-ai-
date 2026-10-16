import 'package:flutter/material.dart';

import '../navigation.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';
import '../widgets/sidebar.dart';
import 'analytics_screen.dart';
import 'dashboard_screen.dart';
import 'help_screen.dart';
import 'knowledge_screen.dart';
import 'plan_screen.dart';
import 'practice_screen.dart';
import 'settings_screen.dart';
import 'understand_screen.dart';

/// Fixed sidebar on wide screens, slide-out drawer on phones.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  AppSection _section = AppSection.home;

  void _select(AppSection s) {
    _scaffoldKey.currentState?.closeDrawer();
    setState(() => _section = s);
  }

  Widget _page() => switch (_section) {
        AppSection.home => DashboardScreen(onOpenKnowledge: () => _select(AppSection.knowledge)),
        AppSection.knowledge => const KnowledgeScreen(),
        AppSection.understand => const UnderstandScreen(),
        AppSection.practice => const PracticeScreen(),
        AppSection.plan => const PlanScreen(),
        AppSection.progress => const AnalyticsScreen(),
        AppSection.help => const HelpScreen(),
        AppSection.settings => const SettingsScreen(),
      };

  @override
  Widget build(BuildContext context) {
    final body = AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: KeyedSubtree(key: ValueKey(_section), child: _page()),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 900) {
          return Scaffold(
            key: _scaffoldKey,
            body: Row(
              children: [
                Sidebar(selected: _section, onSelect: _select),
                Expanded(child: body),
              ],
            ),
          );
        }

        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            backgroundColor: AppColors.navy,
            foregroundColor: Colors.white,
            title: const BrandMark(),
            actions: [
              IconButton(
                onPressed: () => showToast(context, 'No new notifications'),
                icon: const Icon(Icons.notifications_none),
                tooltip: 'Notifications',
              ),
            ],
          ),
          drawer: Drawer(
            width: 288,
            backgroundColor: AppColors.navy,
            child: Sidebar(selected: _section, onSelect: _select, width: 288),
          ),
          body: body,
        );
      },
    );
  }
}
