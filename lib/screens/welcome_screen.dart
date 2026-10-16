import 'package:flutter/material.dart';

import '../navigation.dart';
import '../services/session.dart';
import '../theme/app_colors.dart';
import '../theme/app_palette.dart';
import '../theme/app_theme.dart';
import '../widgets/sidebar.dart';

/// First page, before signing up: what Effective AI is for, a different welcome
/// each visit, and a question box that goes straight into the app.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _controller = TextEditingController();
  late final String _message = pickWelcomeMessage();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _ask() {
    final q = _controller.text.trim();
    enterApp(question: q.isEmpty ? null : q, section: AppSection.ask);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        final main = _Main(message: _message, controller: _controller, onAsk: _ask, wide: wide);

        if (wide) {
          return Scaffold(
            body: Row(
              children: [
                const _WelcomeSidebar(),
                Expanded(child: main),
              ],
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(
            backgroundColor: p.background,
            foregroundColor: p.foreground,
            surfaceTintColor: Colors.transparent,
            title: const BrandMark(),
            actions: const [_AccountButtons(compact: true), SizedBox(width: 8)],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 32, 16, 24),
            child: Column(
              children: [
                main,
                const SizedBox(height: 32),
                const _ValueCard(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Main extends StatelessWidget {
  const _Main({required this.message, required this.controller, required this.onAsk, required this.wide});

  final String message;
  final TextEditingController controller;
  final VoidCallback onAsk;
  final bool wide;

  static const _outcomes = <(IconData, String)>[
    (Icons.verified_outlined, 'Answers with sources from your own notes'),
    (Icons.track_changes, "Find exactly what you don't understand yet"),
    (Icons.assignment_outlined, 'Practise with your real past papers'),
    (Icons.calendar_month_outlined, 'A study plan that adapts to your results'),
  ];

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final content = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 720),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center, style: AppTheme.display(wide ? 40 : 30)),
          const SizedBox(height: 12),
          Text(
            'Your private study assistant. It learns from your books, notes and past exams, '
            'shows you what you don\'t understand yet, and plans what to study next.',
            textAlign: TextAlign.center,
            style: TextStyle(color: p.foreground, fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 28),
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
                  icon: const Icon(Icons.add),
                  tooltip: 'Add your materials',
                ),
                Expanded(
                  child: TextField(
                    controller: controller,
                    onSubmitted: (_) => onAsk(),
                    textInputAction: TextInputAction.send,
                    decoration: InputDecoration(
                      hintText: 'Ask about your course materials',
                      hintStyle: TextStyle(color: p.foreground.withValues(alpha: 0.6)),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton.filled(
                  onPressed: onAsk,
                  icon: const Icon(Icons.arrow_upward),
                  tooltip: 'Ask',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 18,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              for (final (icon, text) in _outcomes)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(color: tint(AppColors.brand), borderRadius: BorderRadius.circular(9)),
                      child: Icon(icon, size: 16, color: AppColors.brand),
                    ),
                    const SizedBox(width: 8),
                    Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
            ],
          ),
        ],
      ),
    );

    if (!wide) return content;
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: Align(alignment: Alignment.centerRight, child: _AccountButtons()),
        ),
        Expanded(child: Center(child: Padding(padding: const EdgeInsets.all(24), child: content))),
      ],
    );
  }
}

class _WelcomeSidebar extends StatelessWidget {
  const _WelcomeSidebar();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    Widget item(IconData icon, String label, VoidCallback onTap) => ListTile(
          leading: Icon(icon, color: AppColors.brand),
          title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          dense: true,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.base)),
          hoverColor: p.sidebarHover,
          onTap: onTap,
        );

    return Container(
      width: 272,
      decoration: BoxDecoration(color: p.sidebarBg, border: Border(right: BorderSide(color: p.sidebarBorder))),
      child: SafeArea(
        right: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 24, 12, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(padding: EdgeInsets.only(left: 8, bottom: 24), child: BrandMark()),
              item(Icons.edit_outlined, 'New question', () => enterApp(section: AppSection.ask)),
              item(Icons.upload_file, 'Add your materials', () => enterApp(section: AppSection.library)),
              item(Icons.auto_awesome_outlined, 'What it can do', () => enterApp(section: AppSection.help)),
              item(Icons.help_outline, 'Help', () => enterApp(section: AppSection.help)),
              const Spacer(),
              const _ValueCard(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Lower-left card: the outcome of signing up, in a phrase or two.
class _ValueCard extends StatelessWidget {
  const _ValueCard();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.muted,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Learn from your own materials', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text(
            'Sign up to upload your books, notes and past exams. Get answers with sources, '
            'find your gaps, and follow a plan that adapts to you.',
            style: TextStyle(height: 1.5),
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: () => showAccountDialog(context, signUp: true),
            child: const Text('Sign up free'),
          ),
        ],
      ),
    );
  }
}

class _AccountButtons extends StatelessWidget {
  const _AccountButtons({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        OutlinedButton(
          onPressed: () => showAccountDialog(context, signUp: false),
          child: const Text('Log in'),
        ),
        const SizedBox(width: 8),
        FilledButton(
          onPressed: () => showAccountDialog(context, signUp: true),
          child: Text(compact ? 'Sign up' : 'Sign up for free'),
        ),
      ],
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
