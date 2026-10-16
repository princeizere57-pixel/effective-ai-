import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';
import '../widgets/fade_slide_in.dart';
import 'page_scaffold.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

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
    OutlineInputBorder border(Color c) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c),
        );

    return PageScaffold(
      builder: (context, width) => [
        const FadeSlideIn(
          child: PageHeader(
            title: 'Help & Suggestions',
            subtitle: 'Answers to common questions, and a place to tell us what to build next.',
          ),
        ),
        const SizedBox(height: 20),
        Panel(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: Column(
              children: [
                for (final (question, answer) in faqs)
                  ExpansionTile(
                    title: Text(question, style: const TextStyle(fontWeight: FontWeight.w600)),
                    iconColor: AppColors.violet,
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    expandedAlignment: Alignment.centerLeft,
                    children: [
                      Text(
                        answer,
                        style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
                      ),
                    ],
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
              const Text(
                'Suggest a feature',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _controller,
                minLines: 3,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: 'What would make Effective AI more useful for you?',
                  hintStyle: const TextStyle(color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.workspace,
                  border: border(AppColors.divider),
                  enabledBorder: border(AppColors.divider),
                  focusedBorder: border(AppColors.violet),
                ),
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
