import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../navigation.dart';
import '../theme/app_colors.dart';
import '../theme/app_palette.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/feedback_prompt.dart';
import 'page_scaffold.dart';

/// Help, the guide to every feature (32 Suggestions), and feedback (31 Personal Review Pop-Up).
class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key, required this.onNavigate});

  final ValueChanged<AppSection> onNavigate;

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    if (_controller.text.trim().isEmpty) {
      showToast(context, 'Write your suggestion first');
      return;
    }
    // TODO: send to a backend (for example a Supabase table) once one is connected.
    _controller.clear();
    showToast(context, 'Thanks for the suggestion');
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final total = featureGuide.fold(0, (sum, g) => sum + g.$2.length);

    return PageScaffold(
      builder: (context, width) => [
        const FadeSlideIn(
          child: PageHeader(
            title: 'Help & Suggestions',
            subtitle: 'Everything Effective AI can do, answers to common questions, and a place to tell us what to change.',
          ),
        ),
        const SizedBox(height: 20),
        Panel(
          child: Row(
            children: [
              Icon(Icons.favorite_border, color: AppColors.brand),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('How is Effective AI working for you?', style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text('Your honest review tells us what to fix, change or build next.',
                        style: TextStyle(color: p.mutedForeground, fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              FilledButton(
                onPressed: () => showFeedbackPrompt(context, where: 'app experience'),
                child: const Text('Give feedback'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SectionHeader(title: 'What Effective AI can do ($total features)'),
        const SizedBox(height: 12),
        for (final (group, features) in featureGuide) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 0, 8),
            child: Text(group.toUpperCase(), style: AppTheme.mono(11, color: p.subtle).copyWith(letterSpacing: 1.2)),
          ),
          Panel(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                for (final (number, name, outcome, section) in features)
                  ListTile(
                    leading: CircleAvatar(
                      radius: 15,
                      backgroundColor: tint(AppColors.brand, 0.16),
                      child: Text('$number', style: TextStyle(fontSize: 12, color: p.primaryText, fontWeight: FontWeight.w700)),
                    ),
                    title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(outcome, style: TextStyle(color: p.mutedForeground, fontSize: 12)),
                    trailing: TextButton(
                      onPressed: () => widget.onNavigate(section),
                      child: Text(section == AppSection.help ? 'Here' : 'Open'),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 16),
        const SectionHeader(title: 'Questions'),
        const SizedBox(height: 12),
        Panel(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: Column(
              children: [
                for (final (question, answer) in faqs)
                  ExpansionTile(
                    title: Text(question, style: const TextStyle(fontWeight: FontWeight.w600)),
                    iconColor: AppColors.brand,
                    collapsedIconColor: p.mutedForeground,
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    expandedAlignment: Alignment.centerLeft,
                    children: [Text(answer, style: TextStyle(color: p.mutedForeground, height: 1.5))],
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Suggest a feature', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              TextField(
                controller: _controller,
                minLines: 3,
                maxLines: 6,
                decoration: fieldDecoration(context, hint: 'What would make Effective AI more useful for you?'),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(onPressed: _send, child: const Text('Send suggestion')),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
