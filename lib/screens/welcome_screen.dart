import 'package:flutter/material.dart';

import '../data/quests.dart';
import '../navigation.dart';
import '../services/learner_state.dart';
import '../services/session.dart';
import '../theme/app_colors.dart';
import '../theme/app_palette.dart';
import '../theme/app_theme.dart';
import '../theme/breakpoints.dart';
import '../widgets/hop.dart';
import '../widgets/progress_bar.dart';
import '../widgets/sidebar.dart';
import 'get_started_screen.dart';

/// First page, before signing up, laid out like an app workspace: a soft
/// sidebar with the path to an A, and a white main panel with the headline,
/// the promise, and the journey as quests (the same ones learners complete
/// inside the app).
///
/// Desktop: sidebar + framed main panel. Tablet and phone: top bar, content,
/// then the sign-up card.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

/// Features inside each stage, for the sidebar tree.
const _stageFeatures = <String, List<(AppSection, String)>>{
  'My Knowledge': [
    (AppSection.library, 'My Library'),
    (AppSection.ask, 'Ask My Knowledge'),
    (AppSection.search, 'Search & Explore'),
  ],
  'Understand': [(AppSection.explain, 'Explain This'), (AppSection.connections, 'Connections')],
  'Practice': [(AppSection.diagnose, 'Diagnose & Improve'), (AppSection.practice, 'Practice')],
  'My Plan': [(AppSection.plan, 'My Plan'), (AppSection.session, 'Study Session'), (AppSection.exam, 'Exam Prep')],
  'My Progress': [(AppSection.progress, 'My Progress')],
};

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _controller = TextEditingController();
  final _askFocus = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _askFocus.dispose();
    super.dispose();
  }

  void _ask() {
    final q = _controller.text.trim();
    enterApp(question: q.isEmpty ? null : q, section: AppSection.ask);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final canvas = isLight ? const Color(0xFFF4F6FF) : const Color(0xFF080C18);

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = ScreenSize.of(constraints.maxWidth);
        final content = _Content(controller: _controller, focus: _askFocus, onAsk: _ask, size: size);

        if (size.isDesktop) {
          return Scaffold(
            backgroundColor: canvas,
            body: Row(
              children: [
                _WelcomeSidebar(onSearch: () => _askFocus.requestFocus()),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: p.card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: p.border),
                      ),
                      child: Column(
                        children: [
                          const _TopBar(showBrand: false, compact: false),
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(16, 44, 16, 56),
                              child: Center(child: content),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          backgroundColor: p.card,
          body: SafeArea(
            child: Column(
              children: [
                _TopBar(showBrand: true, compact: size.isPhone),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(16, size.isPhone ? 24 : 32, 16, 32),
                    child: Center(
                      child: Column(
                        children: [
                          content,
                          const SizedBox(height: 8),
                          const ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 680),
                            child: _SignUpChecklistCard(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Slim bar along the top of the main panel: page name (or logo on smaller
/// screens), Log in, and the call to action.
class _TopBar extends StatelessWidget {
  const _TopBar({required this.showBrand, required this.compact});

  final bool showBrand;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final padding = compact ? const EdgeInsets.symmetric(horizontal: 12) : null;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 16, vertical: 10),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: p.border))),
      child: Row(
        children: [
          Expanded(
            child: showBrand
                ? Align(alignment: Alignment.centerLeft, child: BrandMark(showName: !compact))
                : const Text('Get Started', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          ),
          OutlinedButton(
            onPressed: () => showAccountDialog(context, signUp: false),
            style: OutlinedButton.styleFrom(padding: padding),
            child: const Text('Log in'),
          ),
          SizedBox(width: compact ? 6 : 8),
          FilledButton(
            onPressed: () => showAccountDialog(context, signUp: true),
            style: FilledButton.styleFrom(padding: padding),
            child: const Text('Start your path to an A'),
          ),
        ],
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.controller, required this.focus, required this.onAsk, required this.size});

  final TextEditingController controller;
  final FocusNode focus;
  final VoidCallback onAsk;
  final ScreenSize size;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final headline = switch (size) {
      ScreenSize.phone => 30.0,
      ScreenSize.tablet => 34.0,
      ScreenSize.desktop => 40.0,
    };

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 680),
      child: ListenableBuilder(
        listenable: learner,
        builder: (context, _) {
          final done = completedQuests(learner);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('You’re closer to that A than you think.', style: AppTheme.display(headline)),
              const SizedBox(height: 12),
              Text(
                'Your private study assistant learns from your books, notes and past exams, shows you '
                'exactly what’s holding you back, and guides you step by step to the grade '
                'you’ve been working for.',
                style: TextStyle(color: p.foreground, fontSize: size.isPhone ? 16 : 17, height: 1.55),
              ),
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.fromLTRB(8, 6, 6, 6),
                decoration: BoxDecoration(
                  color: p.card,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: p.border),
                  boxShadow: p.cardHoverShadow,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => enterApp(section: AppSection.library),
                      icon: const Icon(Icons.upload_file),
                      tooltip: 'Add your materials',
                    ),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        focusNode: focus,
                        onSubmitted: (_) => onAsk(),
                        textInputAction: TextInputAction.send,
                        decoration: InputDecoration(
                          hintText: 'Ask a question about your course materials',
                          hintStyle: TextStyle(color: p.foreground.withValues(alpha: 0.6)),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton.filled(onPressed: onAsk, icon: const Icon(Icons.arrow_upward), tooltip: 'Ask'),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Your path to an A', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                        const SizedBox(height: 2),
                        Text(
                          '${questGroups.length} stages · $totalQuests quests · $done completed',
                          style: TextStyle(color: p.mutedForeground, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 44,
                    height: 44,
                    child: CircularProgressIndicator(
                      value: totalQuests == 0 ? 0 : done / totalQuests,
                      strokeWidth: 5,
                      backgroundColor: tint(AppColors.brand, 0.15),
                      color: AppColors.brand,
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              QuestGroupList(onOpen: (section) => enterApp(section: section), openLabel: 'Try it'),
            ],
          );
        },
      ),
    );
  }
}

class _WelcomeSidebar extends StatelessWidget {
  const _WelcomeSidebar({required this.onSearch});

  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    Widget item(IconData? icon, String label, VoidCallback onTap, {bool child = false}) => HopRegion(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              hoverColor: p.sidebarHover,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: EdgeInsets.fromLTRB(child ? 36 : 10, 6, 10, 6),
                child: Row(
                  children: [
                    if (icon != null) ...[
                      HopIcon(height: 5, child: Icon(icon, size: 18, color: AppColors.brand)),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: Text(
                        label,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: child ? 13 : 14, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

    return SizedBox(
      width: 256,
      child: SafeArea(
        right: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 18, 10, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(padding: EdgeInsets.fromLTRB(8, 0, 8, 14), child: BrandMark()),
              item(Icons.search, 'Search your materials', onSearch),
              item(Icons.edit_outlined, 'New question', () => enterApp(section: AppSection.ask)),
              Expanded(
                child: ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 16, 10, 4),
                      child: Text(
                        'Your path to an A',
                        style: TextStyle(color: p.mutedForeground, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                    for (final g in questGroups) ...[
                      item(g.icon, g.title, () => enterApp(section: _stageFeatures[g.title]!.first.$1)),
                      for (final (section, label) in _stageFeatures[g.title]!)
                        item(null, label, () => enterApp(section: section), child: true),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const _SignUpChecklistCard(),
              const SizedBox(height: 8),
              item(Icons.help_outline, 'Support', () => enterApp(section: AppSection.help)),
              item(Icons.auto_awesome_outlined, 'What it can do', () => enterApp(section: AppSection.help)),
              item(Icons.login, 'Log in', () => showAccountDialog(context, signUp: false)),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Complete these steps…" card with progress and Sign up free.
class _SignUpChecklistCard extends StatelessWidget {
  const _SignUpChecklistCard();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final progress = totalQuests == 0 ? 0.0 : completedQuests(learner) / totalQuests;
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
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HopIcon(child: Icon(Icons.rocket_launch_outlined, size: 18, color: AppColors.brand)),
                  const SizedBox(height: 8),
                  const Text(
                    'Complete these steps to reach the grade you’ve been working for',
                    style: TextStyle(fontSize: 12, height: 1.4),
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
                onTap: () => showAccountDialog(context, signUp: true),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(AppRadius.base)),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  child: Row(
                    children: [
                      Text('Sign up free', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                      Spacer(),
                      Icon(Icons.arrow_forward, size: 16),
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

/// Accounts need the backend; until then both buttons explain that and offer the demo.
Future<void> showAccountDialog(BuildContext context, {required bool signUp}) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(signUp ? 'Create your account' : 'Log in'),
      content: const SizedBox(
        width: 420,
        child: Text(
          'Accounts open once the Effective AI backend is connected. Until then you can '
          'explore every feature with a sample Machine Learning library.',
          style: TextStyle(height: 1.5),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Not now')),
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            enterApp();
          },
          child: const Text('Explore the demo'),
        ),
      ],
    ),
  );
}
