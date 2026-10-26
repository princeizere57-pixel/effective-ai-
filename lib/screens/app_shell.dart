
import 'package:flutter/material.dart';

import '../navigation.dart';
import '../services/learner_state.dart';
import '../services/session.dart';
import '../theme/app_palette.dart';
import '../theme/breakpoints.dart';
import '../widgets/common.dart';
import '../widgets/page_turn.dart';
import '../widgets/sidebar.dart';
import 'ask_screen.dart';
import 'connections_screen.dart';
import 'dashboard_screen.dart';
import 'diagnose_screen.dart';
import 'exam_screen.dart';
import 'explain_screen.dart';
import 'get_started_screen.dart';
import 'help_screen.dart';
import 'library_screen.dart';
import 'plan_screen.dart';
import 'practice_screen.dart';
import 'progress_screen.dart';
import 'search_screen.dart';
import 'session_screen.dart';
import 'settings_screen.dart';

/// Fixed sidebar on wide screens, slide-out drawer on phones.
///
/// Pages open straight away. Moving between pages turns to the new one like a
/// book page; entering from the landing page and reduced motion show it at once.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const _turnTime = Duration(milliseconds: 550);

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  AppSection _section = startSection ?? AppSection.home;

  @override
  void initState() {
    super.initState();
    learner.markVisited(AppSection.home.name);
  }

  void _select(AppSection s) {
    _scaffoldKey.currentState?.closeDrawer();
    if (s == _section) return;
    learner.markVisited(s.name);
    setState(() => _section = s);
  }

  Widget _page() => switch (_section) {
        AppSection.getStarted => GetStartedScreen(onNavigate: _select),
        AppSection.home => DashboardScreen(onNavigate: _select),
        AppSection.library => const LibraryScreen(),
        AppSection.ask => const AskScreen(),
        AppSection.search => const SearchScreen(),
        AppSection.explain => const ExplainScreen(),
        AppSection.connections => const ConnectionsScreen(),
        AppSection.diagnose => const DiagnoseScreen(),
        AppSection.practice => const PracticeScreen(),
        AppSection.exam => const ExamScreen(),
        AppSection.session => const SessionScreen(),
        AppSection.plan => const PlanScreen(),
        AppSection.progress => ProgressScreen(onNavigate: _select),
        AppSection.help => HelpScreen(onNavigate: _select),
        AppSection.settings => const SettingsScreen(),
      };

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    final body = ClipRect(
      child: AnimatedSwitcher(
        duration: reduceMotion ? Duration.zero : _turnTime,
        transitionBuilder: (child, animation) => PageTurnTransition(animation: animation, child: child),
        layoutBuilder: (current, previous) => Stack(
          fit: StackFit.expand,
          children: [...previous, if (current != null) current],
        ),
        child: KeyedSubtree(key: ValueKey(_section), child: _page()),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        // Desktop: full sidebar. Tablet: icon rail. Phone: top bar + slide-out menu.
        final size = ScreenSize.of(constraints.maxWidth);
        if (!size.isPhone) {
          return Scaffold(
            key: _scaffoldKey,
            body: Row(
              children: [
                Sidebar(selected: _section, onSelect: _select, compact: !size.isDesktop),
                Expanded(child: body),
              ],
            ),
          );
        }

        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            backgroundColor: p.sidebarBg,
            foregroundColor: p.sidebarTextActive,
            surfaceTintColor: Colors.transparent,
            shape: Border(bottom: BorderSide(color: p.sidebarBorder)),
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
            backgroundColor: p.sidebarBg,
            child: Sidebar(selected: _section, onSelect: _select, width: 288),
          ),
          body: body,
        );
      },
    );
  }
}
