import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_palette.dart';
import '../widgets/common.dart';
import '../widgets/fade_slide_in.dart';
import 'page_scaffold.dart';

/// Ask about a concept and get an explanation.
///
/// Answers are placeholders until an AI backend is connected. Call it from a
/// server (for example a Supabase Edge Function), never with an API key in the app.
class UnderstandScreen extends StatefulWidget {
  const UnderstandScreen({super.key});

  @override
  State<UnderstandScreen> createState() => _UnderstandScreenState();
}

class _UnderstandScreenState extends State<UnderstandScreen> {
  final _controller = TextEditingController();
  final _answers = <(String, String)>[
    (
      'What is gradient descent?',
      'Gradient descent finds the lowest point of a loss function by repeatedly stepping '
          'downhill. At each step it measures the slope (the gradient) of the loss for every '
          'weight, then moves each weight a little in the opposite direction. The step size is '
          'the learning rate: too large and it overshoots, too small and training crawls.',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _ask([String? topic]) {
    final question = (topic ?? _controller.text).trim();
    if (question.isEmpty) {
      showToast(context, 'Type a question or pick a topic first');
      return;
    }
    setState(() {
      _answers.insert(0, (
        question,
        'Sample answer. Once an AI service is connected, you will get a short summary of '
            '"$question", a worked example and a quick question to check your understanding.',
      ));
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return PageScaffold(
      builder: (context, width) => [
        const FadeSlideIn(
          child: PageHeader(
            title: 'Understand',
            subtitle: 'Ask about any concept and get a step-by-step explanation.',
          ),
        ),
        const SizedBox(height: 20),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _controller,
                minLines: 2,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _ask(),
                decoration: fieldDecoration(context, hint: 'What do you want to understand?'),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final t in suggestedTopics)
                    ActionChip(
                      label: Text(t),
                      onPressed: () => _ask(t),
                      backgroundColor: tint(AppColors.violet),
                      side: BorderSide.none,
                      labelStyle: TextStyle(color: p.primaryText, fontWeight: FontWeight.w600),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: _ask,
                  icon: const Icon(Icons.auto_awesome, size: 18),
                  label: const Text('Explain'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        for (final (question, answer) in _answers)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.help_outline, color: AppColors.violet, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          question,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(answer, style: TextStyle(color: p.mutedForeground, height: 1.55)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
