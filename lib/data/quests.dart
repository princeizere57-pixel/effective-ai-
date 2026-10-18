import 'package:flutter/material.dart';

import '../navigation.dart';
import '../services/learner_state.dart';

/// Get Started checklist, grouped by the Effective AI pipeline:
/// your private knowledge base → understand → practise → plan → measure.
/// Steps tick themselves off as the learner uses each feature.

class QuestStep {
  const QuestStep(this.title, this.detail, this.section, this.isDone);

  final String title;
  final String detail;

  /// Where the "Open" button takes the learner.
  final AppSection section;
  final bool Function(LearnerState s) isDone;
}

enum QuestStatus { notStarted, inProgress, completed }

class Quest {
  const Quest(this.title, this.description, this.steps);

  final String title;
  final String description;
  final List<QuestStep> steps;

  int doneCount(LearnerState s) => steps.where((step) => step.isDone(s)).length;

  QuestStatus status(LearnerState s) {
    final done = doneCount(s);
    if (done == steps.length) return QuestStatus.completed;
    return done == 0 ? QuestStatus.notStarted : QuestStatus.inProgress;
  }

  /// The first step not done yet, or null when the quest is complete.
  QuestStep? nextStep(LearnerState s) {
    for (final step in steps) {
      if (!step.isDone(s)) return step;
    }
    return null;
  }
}

class QuestGroup {
  const QuestGroup(this.title, this.icon, this.summary, this.quests);

  final String title;
  final IconData icon;
  final String summary;
  final List<Quest> quests;

  int completedCount(LearnerState s) =>
      quests.where((q) => q.status(s) == QuestStatus.completed).length;
}

bool _visited(LearnerState s, AppSection a) => s.visited.contains(a.name);

final questGroups = <QuestGroup>[
  QuestGroup('My Knowledge', Icons.folder_copy_outlined, 'Your data becomes a private knowledge base', [
    Quest('Build your private library', 'See your materials and add your own.', [
      QuestStep('Open My Library', 'See the books, notes, slides and past exams already in your library.',
          AppSection.library, (s) => _visited(s, AppSection.library)),
      QuestStep('Add a file', 'Upload a book, your notes, slides, a paper or a past exam.',
          AppSection.library, (s) => s.milestones.contains('uploaded')),
    ]),
    Quest('Ask your first question', 'Get an answer built only from your materials.', [
      QuestStep('Ask about your materials', 'Type a question in Ask My Knowledge, or pick a suggested one.',
          AppSection.ask, (s) => s.milestones.contains('asked')),
      QuestStep('Check where it came from', 'Tap a numbered source to open the exact page and passage.',
          AppSection.ask, (s) => s.milestones.contains('source')),
    ]),
    Quest('Search across everything', 'Find any idea in every document at once.', [
      QuestStep('Search your library', 'Type a word or idea into Smart search.',
          AppSection.search, (s) => s.milestones.contains('searched')),
      QuestStep('Explore a topic', 'Open Topic explorer and pick a concept.',
          AppSection.search, (s) => s.milestones.contains('topic')),
    ]),
  ]),
  QuestGroup('Understand', Icons.lightbulb_outline, 'It understands, analyses and compares your knowledge', [
    Quest('Explain a concept your way', 'Read it at the depth you need.', [
      QuestStep('Open Explain This', 'Pick any concept from your materials.',
          AppSection.explain, (s) => _visited(s, AppSection.explain)),
      QuestStep('Simplify or go deeper', 'Use the buttons to change the level of the explanation.',
          AppSection.explain, (s) => s.milestones.contains('level')),
    ]),
    Quest('See how ideas connect', 'Build a connected picture instead of isolated facts.', [
      QuestStep('Open the knowledge map', 'Tap a concept to see what it links to.',
          AppSection.connections, (s) => _visited(s, AppSection.connections)),
      QuestStep('Compare two sources', 'See where your book and a paper agree or differ.',
          AppSection.connections, (s) => s.milestones.contains('compare')),
    ]),
  ]),
  QuestGroup('Practice', Icons.fitness_center, 'It generates useful practice from your materials', [
    Quest('Find your gaps', 'Know exactly what to work on.', [
      QuestStep('Take the diagnostic', 'Eight questions, one per concept, about four minutes.',
          AppSection.diagnose, (s) => s.diagnosticDone),
      QuestStep('Read your error analysis', 'See which kind of question you get wrong most.',
          AppSection.diagnose, (s) => s.milestones.contains('errors')),
    ]),
    Quest('Practise from your materials', 'Questions written from your own pages.', [
      QuestStep('Finish a practice set', 'Generate a set and answer every question.',
          AppSection.practice, (s) => s.didThisSession(ActivityKind.practice)),
      QuestStep('Check a written answer', 'Write an exam answer and see which marking points you hit.',
          AppSection.practice, (s) => s.didThisSession(ActivityKind.evaluation)),
    ]),
    Quest('Learn with the tutor', 'Reason your way to the answer and keep it.', [
      QuestStep('Try Socratic mode', 'Answer one of the tutor\'s guiding questions.',
          AppSection.practice, (s) => s.milestones.contains('socratic')),
      QuestStep('Review from memory', 'Finish a round of recall review.',
          AppSection.practice, (s) => s.didThisSession(ActivityKind.review)),
    ]),
  ]),
  QuestGroup('My Plan', Icons.calendar_month_outlined, 'It automates your study workflow', [
    Quest('Get your study plan', 'A week built from your gaps and past papers.', [
      QuestStep('Open My Plan', 'See what to study each day and why.',
          AppSection.plan, (s) => _visited(s, AppSection.plan)),
      QuestStep('Set your daily goal', 'Choose 15, 30 or 60 minutes; the plan rebuilds around it.',
          AppSection.plan, (s) => s.milestones.contains('goal')),
    ]),
    Quest('Finish a study session', 'Learn, practise, test and review one topic.', [
      QuestStep('Complete a study session', 'Start from Study Session or from any gap.',
          AppSection.session, (s) => s.didThisSession(ActivityKind.session)),
    ]),
    Quest('Prepare for the exam', 'Use your past papers the smart way.', [
      QuestStep('See what past papers ask', 'Open Exam Prep and look at recurring topics.',
          AppSection.exam, (s) => _visited(s, AppSection.exam)),
      QuestStep('Sit a mock test', 'Timed, no hints, results at the end.',
          AppSection.exam, (s) => s.didThisSession(ActivityKind.mockTest)),
    ]),
  ]),
  QuestGroup('My Progress', Icons.bar_chart, 'It measures your outcomes', [
    Quest('Read your learning report', 'What you know, what you don\'t, and what to do next.', [
      QuestStep('Open My Progress', 'Your report, mastery and history in one place.',
          AppSection.progress, (s) => _visited(s, AppSection.progress)),
    ]),
    Quest('Tell us how it\'s going', 'Your honest review shapes what we build next.', [
      QuestStep('Share feedback', 'Rate your experience in Help & Suggestions.',
          AppSection.help, (s) => s.feedback.isNotEmpty),
    ]),
  ]),
];

int get totalQuests => questGroups.fold(0, (sum, g) => sum + g.quests.length);

int completedQuests(LearnerState s) => questGroups.fold(0, (sum, g) => sum + g.completedCount(s));

bool allQuestsDone(LearnerState s) => completedQuests(s) == totalQuests;

/// A group opens once the group before it has at least one finished quest.
bool isGroupUnlocked(LearnerState s, int index) =>
    index == 0 || questGroups[index - 1].completedCount(s) > 0;
