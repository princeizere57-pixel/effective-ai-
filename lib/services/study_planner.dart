import '../data/knowledge.dart';
import 'learner_state.dart';

enum PlanItemKind { study, review, mock }

class PlanItem {
  const PlanItem({
    required this.key,
    required this.kind,
    required this.title,
    required this.reason,
    required this.minutes,
    this.conceptId,
  });

  final String key;
  final PlanItemKind kind;
  final String title;

  /// Why this item is in the plan, in plain language.
  final String reason;
  final int minutes;
  final String? conceptId;
}

class PlanDay {
  const PlanDay(this.label, this.items);

  final String label;
  final List<PlanItem> items;

  int get minutes => items.fold(0, (sum, i) => sum + i.minutes);
}

class StudyPlan {
  const StudyPlan(this.days, this.unscheduled);

  final List<PlanDay> days;

  /// Sessions that did not fit into the week at the current daily goal.
  final int unscheduled;
}

/// Builds a 7-day plan from mastery, past-paper frequency and the daily goal.
/// It is rebuilt from current results every time, so it adapts automatically.
abstract final class StudyPlanner {
  static const _weekdays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
  ];

  static StudyPlan build(LearnerState s, {DateTime? today}) {
    final now = today ?? DateTime.now();
    String label(int i) => switch (i) {
          0 => 'Today',
          1 => 'Tomorrow',
          _ => _weekdays[now.add(Duration(days: i)).weekday - 1],
        };

    // Weak concepts that appear in past papers come first.
    double weight(Concept c) => (1 - (s.mastery(c.id) ?? 0.3)) * (1 + s.examFrequency(c.id));
    final ranked = [...concepts]..sort((a, b) => weight(b).compareTo(weight(a)));

    final queue = <PlanItem>[];
    for (var round = 0; round < 3; round++) {
      for (final c in ranked) {
        final gap = s.isGap(c.id);
        final papers = s.examFrequency(c.id);
        final repeats = gap ? (papers > 0 ? 3 : 2) : 1;
        if (round >= repeats) continue;
        final m = s.mastery(c.id);
        if (gap) {
          queue.add(PlanItem(
            key: '${c.id}-$round',
            kind: PlanItemKind.study,
            conceptId: c.id,
            minutes: 20,
            title: switch (round) {
              0 => 'Study session: ${c.name}',
              1 => 'Practise: ${c.name}',
              _ => 'Past-paper question: ${c.name}',
            },
            reason: [
              m == null ? 'Not tested yet' : 'Mastery ${percent(m)}',
              if (papers > 0) 'in $papers past paper${papers == 1 ? '' : 's'}',
            ].join(' · '),
          ));
        } else {
          queue.add(PlanItem(
            key: '${c.id}-review',
            kind: PlanItemKind.review,
            conceptId: c.id,
            minutes: 10,
            title: 'Quick review: ${c.name}',
            reason: 'Strong at ${percent(m)}; a short review keeps it that way',
          ));
        }
      }
    }

    final days = <PlanDay>[];
    var next = 0;
    for (var d = 0; d < 7; d++) {
      final items = <PlanItem>[];
      if (d == 5) {
        items.add(const PlanItem(
          key: 'mock',
          kind: PlanItemKind.mock,
          minutes: 30,
          title: 'Mock test',
          reason: 'Check your progress under exam conditions',
        ));
      } else {
        var left = s.dailyGoal;
        while (next < queue.length && (queue[next].minutes <= left || items.isEmpty)) {
          final item = queue[next++];
          items.add(item);
          left -= item.minutes;
        }
      }
      days.add(PlanDay(label(d), items));
    }
    return StudyPlan(days, queue.length - next);
  }
}
