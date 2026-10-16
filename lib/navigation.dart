import 'package:flutter/material.dart';

import 'services/learner_state.dart';

/// Every destination in the sidebar.
enum AppSection {
  home('Home', Icons.home_outlined),
  library('My Library', Icons.folder_copy_outlined),
  ask('Ask My Knowledge', Icons.forum_outlined),
  search('Search & Explore', Icons.travel_explore),
  explain('Explain This', Icons.lightbulb_outline),
  connections('Connections', Icons.hub_outlined),
  diagnose('Diagnose & Improve', Icons.track_changes),
  practice('Practice', Icons.fitness_center),
  exam('Exam Prep', Icons.assignment_outlined),
  session('Study Session', Icons.school_outlined),
  plan('My Plan', Icons.calendar_month_outlined),
  progress('My Progress', Icons.bar_chart),
  help('Help & Suggestions', Icons.help_outline),
  settings('Settings', Icons.settings_outlined);

  const AppSection(this.label, this.icon);

  final String label;
  final IconData icon;

  /// Count shown in the sidebar badge, or null for none.
  int? get badge => switch (this) {
        AppSection.diagnose => learner.gaps.length,
        AppSection.practice => learner.dueReviews,
        _ => null,
      };
}

/// Sidebar groups, following the platform's pipeline:
/// your data → navigate → understand → improve → exams → study → track.
const sidebarGroups = <(String?, List<AppSection>)>[
  (null, [AppSection.home]),
  ('LIBRARY', [AppSection.library]),
  ('NAVIGATE', [AppSection.ask, AppSection.search]),
  ('UNDERSTAND', [AppSection.explain, AppSection.connections]),
  ('IMPROVE', [AppSection.diagnose, AppSection.practice]),
  ('EXAMS', [AppSection.exam]),
  ('STUDY', [AppSection.session, AppSection.plan]),
  ('TRACK', [AppSection.progress]),
];

const footerSections = [AppSection.help, AppSection.settings];

/// The 32 features, grouped by what they do for the student, and where to find each.
const featureGuide = <(String, List<(int, String, String, AppSection)>)>[
  ('Your data', [
    (1, 'Private Knowledge Library', 'All your learning material in one searchable place', AppSection.library),
  ]),
  ('Knowledge navigation', [
    (2, 'Ask My Knowledge', 'Relevant answers without searching through documents', AppSection.ask),
    (3, 'Source Verification', 'See the exact page and section behind every answer', AppSection.ask),
    (4, 'Smart Search', 'Find any idea across your whole library', AppSection.search),
    (11, 'Topic Explorer', 'Every section about a topic, from every document', AppSection.search),
    (17, 'Socratic Mode', 'Guiding questions that develop deeper reasoning', AppSection.practice),
    (22, 'Past Paper Intelligence', 'What your past papers keep asking, and how', AppSection.exam),
  ]),
  ('Knowledge comprehension', [
    (5, 'Explain This', 'Understand a concept or passage faster', AppSection.explain),
    (6, 'Simplify / Deepen', 'Learn at the depth you actually need', AppSection.explain),
    (7, 'Concept Connections', 'How ideas relate across chapters and documents', AppSection.connections),
    (8, 'Compare Sources', 'Where your materials agree, differ or contradict', AppSection.connections),
    (13, 'Diagnostic Workflow', 'Measure understanding before studying blindly', AppSection.diagnose),
    (15, 'Practice Generator', 'Questions from your actual materials', AppSection.practice),
    (18, 'Answer Evaluation', "Know what's missing from your written answer", AppSection.practice),
    (21, 'Exam Preparation Workflow', 'A prep sequence built from past papers and your gaps', AppSection.exam),
  ]),
  ('Personalisation', [
    (9, 'Knowledge Map', 'See the structure of a subject', AppSection.connections),
    (10, 'Ask Across Documents', 'Answers that combine several sources', AppSection.ask),
    (12, 'Learning Gap Detection', 'Know what you actually need to work on', AppSection.diagnose),
    (14, 'Targeted Learning Workflow', 'Study exactly where the weakness is', AppSection.diagnose),
    (16, 'Active Recall', 'Strengthen memory by answering before you see the answer', AppSection.practice),
    (19, 'Error Analysis', "Understand why you're getting questions wrong", AppSection.diagnose),
    (24, 'Post-Test Analysis', 'Know what to study after a test', AppSection.exam),
    (26, 'Study Plan Generator', 'Know what to study and when', AppSection.plan),
    (27, 'Adaptive Study Plan', 'More time where it produces the most improvement', AppSection.plan),
    (28, 'Progress Memory', 'Never start from zero', AppSection.progress),
    (30, 'Personal Learning Report', 'What you know, what you don\'t, what to do next', AppSection.progress),
    (32, 'Suggestions', 'Discover what Effective AI can do for you', AppSection.home),
  ]),
  ('Knowledge application', [
    (20, 'Remediation Workflow', 'Turn each mistake into targeted learning', AppSection.diagnose),
    (23, 'Mock Test Workflow', 'Test yourself under realistic conditions', AppSection.exam),
    (25, 'Study Session Workflow', 'Learn, practise, test and review in one session', AppSection.session),
  ]),
  ('Follow-up', [
    (29, 'Knowledge Review', 'Revisit weak or forgotten concepts over time', AppSection.practice),
    (31, 'Personal Review Pop-Up', 'Tell us honestly what to change', AppSection.help),
  ]),
];
