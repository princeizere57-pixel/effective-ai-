import 'dart:async';

import 'package:flutter/material.dart';

import '../navigation.dart';
import '../services/learner_state.dart';
import '../theme/app_palette.dart';
import '../widgets/common.dart';
import '../widgets/page_turn.dart';
import '../widgets/sidebar.dart';
import 'ask_screen.dart';
import 'connections_screen.dart';
import 'dashboard_screen.dart';
import 'diagnose_screen.dart';
import 'exam_screen.dart';
import 'explain_screen.dart';
import 'help_screen.dart';
import 'library_screen.dart';
import 'loading_view.dart';
import 'plan_screen.dart';
import 'practice_screen.dart';
import 'progress_screen.dart';
import 'search_screen.dart';
import 'session_screen.dart';
import 'settings_screen.dart';

/// Fixed sidebar on wide screens, slide-out drawer on phones.
///
/// Opening a section shows the book loader for [_loadTime], then turns to the
/// section like a book page. The delay stands in for real data loading; once
/// screens fetch from a backend, finish loading when the data arrives instead.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const _loadTime = Duration(milliseconds: 650);
  static const _turnTime = Duration(milliseconds: 550);

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  AppSection _section = AppSection.home;
  bool _loading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    learner.markVisited(AppSection.home.name);
    _timer = Timer(_loadTime, _finishLoading);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _finishLoading() {
    if (mounted) setState(() => _loading = false);
  }

  void _select(AppSection s) {
    _scaffoldKey.currentState?.closeDrawer();
    if (s == _section && !_loading) return;
    learner.markVisited(s.name);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    _timer?.cancel();
    setState(() {
      _section = s;
      _loading = !reduceMotion;
    });
    if (!reduceMotion) _timer = Timer(_loadTime, _finishLoading);
  }

  Widget _page() => switch (_section) {
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
        child: _loading && !reduceMotion
            ? LoadingView(key: ValueKey('loading-${_section.name}'), label: _section.label)
            : KeyedSubtree(key: ValueKey(_section), child: _page()),
      ),
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
            backgroundColor: p.sidebarBg,
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
            backgroundColor: p.sidebarBg,
            child: Sidebar(selected: _section, onSelect: _select, width: 288),
          ),
          body: body,
        );
      },
    );
  }
}
