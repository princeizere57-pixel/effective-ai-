import 'package:flutter/material.dart';

import '../data/knowledge.dart';
import '../theme/app_colors.dart';

/// A question the learner got wrong. Feeds error analysis and remediation.
class Mistake {
  const Mistake(this.question, this.chosen, this.when);

  final QuizQuestion question;
  final int chosen;
  final DateTime when;
}

enum ActivityKind {
  upload(Icons.upload_file),
  diagnostic(Icons.track_changes),
  session(Icons.school_outlined),
  mockTest(Icons.timer_outlined),
  practice(Icons.fitness_center),
  review(Icons.replay),
  evaluation(Icons.rate_review_outlined),
  feedback(Icons.favorite_border);

  const ActivityKind(this.icon);

  final IconData icon;
}

class Activity {
  const Activity(this.kind, this.text, this.when);

  final ActivityKind kind;
  final String text;
  final DateTime when;
}

class FeedbackEntry {
  const FeedbackEntry({
    required this.where,
    required this.rating,
    required this.tags,
    required this.comment,
  });

  final String where;
  final int rating;
  final List<String> tags;
  final String comment;
}

/// Progress memory: everything the app knows about the learner.
///
/// Kept in memory with sample history so every feature has something to show.
/// Persist it to a backend (for example Supabase) so it survives restarts and devices.
class LearnerState extends ChangeNotifier {
  LearnerState() {
    _seed();
  }

  final List<LibraryDoc> docs = [...sampleDocs];
  final Map<String, (int, int)> _attempts = {};
  final List<Mistake> mistakes = [];
  final List<Activity> history = [];
  final List<FeedbackEntry> feedback = [];

  /// Plain-language notes about how the study plan adapted to new results.
  final List<String> planUpdates = [];
  final Set<String> planDone = {};
  final Set<String> reviewedThisSession = {};

  /// Sections the learner has opened, so suggestions can point at unexplored features.
  final Set<String> visited = {};

  int dailyGoal = 30;
  bool diagnosticDone = false;

  void _seed() {
    _attempts.addAll({
      'gd': (4, 5),
      'lr': (1, 4),
      'backprop': (3, 4),
      'loss': (5, 5),
      'overfitting': (2, 5),
      'regularization': (1, 3),
      'eigen': (2, 2),
    });
    final now = DateTime.now();
    QuizQuestion q(String concept, int i) => questionsFor(concept)[i];
    mistakes.addAll([
      Mistake(q('lr', 0), 0, now.subtract(const Duration(days: 1))),
      Mistake(q('overfitting', 0), 0, now.subtract(const Duration(days: 2))),
      Mistake(q('lr', 1), 0, now.subtract(const Duration(days: 2))),
      Mistake(q('regularization', 1), 0, now.subtract(const Duration(days: 3))),
      Mistake(q('overfitting', 1), 1, now.subtract(const Duration(days: 4))),
    ]);
    history.addAll([
      Activity(ActivityKind.upload, 'Added two past exams (2024 and 2025)', now.subtract(const Duration(days: 1))),
      Activity(ActivityKind.practice, 'Practice set on optimisation: 3 of 5 correct', now.subtract(const Duration(days: 2))),
      Activity(ActivityKind.review, 'Reviewed 4 recall cards, remembered 2', now.subtract(const Duration(days: 3))),
      Activity(ActivityKind.session, 'Study session on Loss function: 2 of 2 correct', now.subtract(const Duration(days: 5))),
    ]);
  }

  // ── Library ──────────────────────────────────────────────────────────────

  List<LibraryDoc> get indexedDocs => docs.where((d) => d.indexed).toList();

  LibraryDoc? docById(String id) {
    for (final d in docs) {
      if (d.id == id) return d;
    }
    return null;
  }

  void addDocs(List<LibraryDoc> added) {
    docs.insertAll(0, added);
    log(ActivityKind.upload, 'Added ${added.length} file${added.length == 1 ? '' : 's'} to your library');
  }

  /// Number of past papers that ask about [conceptId].
  int examFrequency(String conceptId) {
    final papers = <String>{};
    for (final p in passagesFor(conceptId)) {
      if (docById(p.docId)?.type == DocType.pastExam) papers.add(p.docId);
    }
    return papers.length;
  }

  int get pastPaperCount => docs.where((d) => d.type == DocType.pastExam && d.indexed).length;

  // ── Mastery ──────────────────────────────────────────────────────────────

  (int, int)? attemptsOf(String conceptId) => _attempts[conceptId];

  double? mastery(String conceptId) {
    final a = _attempts[conceptId];
    if (a == null || a.$2 == 0) return null;
    return a.$1 / a.$2;
  }

  bool isGap(String conceptId) {
    final m = mastery(conceptId);
    return m == null || m < 0.6;
  }

  /// Weakest first; untested concepts last.
  List<Concept> get gaps {
    final list = concepts.where((c) => isGap(c.id)).toList();
    list.sort((a, b) => (mastery(a.id) ?? 2).compareTo(mastery(b.id) ?? 2));
    return list;
  }

  List<Concept> get strong => concepts.where((c) => (mastery(c.id) ?? 0) >= 0.8).toList();

  List<Concept> get learning => concepts.where((c) {
        final m = mastery(c.id);
        return m != null && m >= 0.6 && m < 0.8;
      }).toList();

  int get totalAnswers => _attempts.values.fold(0, (sum, a) => sum + a.$2);

  void record(String conceptId, bool correct) {
    final wasGap = isGap(conceptId);
    final a = _attempts[conceptId] ?? (0, 0);
    _attempts[conceptId] = (a.$1 + (correct ? 1 : 0), a.$2 + 1);
    final nowGap = isGap(conceptId);
    if (wasGap != nowGap) {
      final name = conceptById(conceptId).name;
      planUpdates.insert(
        0,
        nowGap
            ? '$name became a gap, so your plan now gives it full study sessions.'
            : '$name is no longer a gap, so your plan now gives it a short review instead.',
      );
    }
    notifyListeners();
  }

  /// Records a multiple-choice answer and remembers it if it was wrong.
  bool answer(QuizQuestion q, int chosen) {
    final correct = chosen == q.answer;
    if (!correct) mistakes.insert(0, Mistake(q, chosen, DateTime.now()));
    record(q.conceptId, correct);
    return correct;
  }

  // ── Review ───────────────────────────────────────────────────────────────

  /// Concepts to revisit: gaps first, then anything not reviewed this session.
  List<Concept> get reviewQueue {
    final queue = [...gaps, ...concepts.where((c) => !isGap(c.id))];
    return queue.where((c) => !reviewedThisSession.contains(c.id)).toList();
  }

  int get dueReviews => reviewQueue.length;

  void markReviewed(String conceptId, {required bool remembered}) {
    reviewedThisSession.add(conceptId);
    record(conceptId, remembered);
  }

  // ── Plan, history and feedback ───────────────────────────────────────────

  void togglePlanItem(String key) {
    planDone.contains(key) ? planDone.remove(key) : planDone.add(key);
    notifyListeners();
  }

  void setDailyGoal(int minutes) {
    dailyGoal = minutes;
    planUpdates.insert(0, 'Daily goal changed to $minutes minutes, so the plan was rebuilt.');
    notifyListeners();
  }

  void log(ActivityKind kind, String text) {
    history.insert(0, Activity(kind, text, DateTime.now()));
    notifyListeners();
  }

  void addFeedback(FeedbackEntry entry) {
    feedback.insert(0, entry);
    log(ActivityKind.feedback, 'Shared feedback on ${entry.where} (${entry.rating}/5)');
  }

  void markVisited(String section) => visited.add(section);
}

final learner = LearnerState();

/// Label and color for a mastery level.
(String, Color) masteryStyle(double? m) {
  if (m == null) return ('Not tested', const Color(0xFF8A93A8));
  if (m >= 0.8) return ('Strong', AppColors.green);
  if (m >= 0.6) return ('Getting there', AppColors.blue);
  return ('Gap', AppColors.red);
}

String percent(double? m) => m == null ? '—' : '${(m * 100).round()}%';

String timeAgo(DateTime when) {
  final d = DateTime.now().difference(when);
  if (d.inMinutes < 1) return 'Just now';
  if (d.inHours < 1) return '${d.inMinutes} min ago';
  if (d.inDays < 1) return '${d.inHours} h ago';
  if (d.inDays == 1) return 'Yesterday';
  return '${d.inDays} days ago';
}
