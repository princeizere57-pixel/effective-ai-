import 'package:flutter/material.dart';

import '../services/learner_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_palette.dart';
import 'common.dart';

/// Personal review pop-up: asks for honest feedback after a session or test.
///
/// Entries are kept in the learner's progress memory. TODO: send them to a
/// backend table so the team can see what to change, fix, add or redirect.
Future<void> showFeedbackPrompt(BuildContext context, {required String where}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _FeedbackDialog(where: where),
  );
}

class _FeedbackDialog extends StatefulWidget {
  const _FeedbackDialog({required this.where});

  final String where;

  @override
  State<_FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<_FeedbackDialog> {
  static const _tags = ['Helpful', 'Too easy', 'Too hard', 'Confusing', 'Too slow', 'Loved it'];

  final _controller = TextEditingController();
  final _picked = <String>{};
  int _rating = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    learner.addFeedback(FeedbackEntry(
      where: widget.where,
      rating: _rating,
      tags: _picked.toList(),
      comment: _controller.text.trim(),
    ));
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    messenger.showSnackBar(
      const SnackBar(content: Text('Thanks. Your feedback helps us improve Effective AI.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return AlertDialog(
      title: Text('How was this ${widget.where}?'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your honest opinion decides what we change next.',
                style: TextStyle(color: p.mutedForeground),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  for (var i = 1; i <= 5; i++)
                    IconButton(
                      onPressed: () => setState(() => _rating = i),
                      tooltip: '$i of 5',
                      icon: Icon(
                        i <= _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: AppColors.amber,
                        size: 32,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final t in _tags)
                    FilterChip(
                      label: Text(t),
                      selected: _picked.contains(t),
                      onSelected: (on) => setState(() => on ? _picked.add(t) : _picked.remove(t)),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _controller,
                minLines: 2,
                maxLines: 4,
                decoration: fieldDecoration(context, hint: 'What should we change, fix or add?'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Not now')),
        FilledButton(
          onPressed: _rating == 0 ? null : _send,
          child: const Text('Send feedback'),
        ),
      ],
    );
  }
}
