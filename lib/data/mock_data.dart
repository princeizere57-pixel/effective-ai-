import 'package:flutter/material.dart';

// Sample profile and activity data. The learning content itself lives in
// knowledge.dart and the learner's results in services/learner_state.dart.

const userFirstName = 'Alex';
const userFullName = 'Alex Morgan';
const userEmail = 'alex@effective-ai.app';
const streakDays = 12;

/// Days until the next exam, used in the plan and on Home.
const daysToExam = 12;

class Stat {
  const Stat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.delta,
  });

  final String label;
  final String value;
  final String? delta;
  final IconData icon;
  final Color color;
}

/// Hours studied per day, Monday to Sunday.
const weeklyHours = <(String, double)>[
  ('Mon', 1.5),
  ('Tue', 2.0),
  ('Wed', 3.2),
  ('Thu', 1.0),
  ('Fri', 2.8),
  ('Sat', 2.5),
  ('Sun', 1.5),
];

/// Average quiz score over the last 8 weeks.
const quizScores = <double>[72, 75, 74, 80, 83, 81, 86, 88];

enum DeadlineStatus { overdue, soon, upcoming, done }

class Deadline {
  const Deadline({
    required this.title,
    required this.course,
    required this.due,
    required this.status,
  });

  final String title;
  final String course;
  final String due;
  final DeadlineStatus status;
}

const deadlines = <Deadline>[
  Deadline(
    title: 'Read chapter 6: Eigenvectors',
    course: 'Linear Algebra for ML',
    due: 'Overdue',
    status: DeadlineStatus.overdue,
  ),
  Deadline(
    title: 'Quiz: Backpropagation',
    course: 'Neural Networks Fundamentals',
    due: 'Tomorrow',
    status: DeadlineStatus.soon,
  ),
  Deadline(
    title: 'Machine Learning exam',
    course: 'Neural Networks Fundamentals',
    due: 'In $daysToExam days',
    status: DeadlineStatus.upcoming,
  ),
  Deadline(
    title: 'Upload Week 6 notes',
    course: 'Neural Networks Fundamentals',
    due: 'Done',
    status: DeadlineStatus.done,
  ),
];

const faqs = <(String, String)>[
  (
    'Where do answers come from?',
    'Only from the documents you choose in Ask My Knowledge. Every point links to the page '
        'and section it came from, so you can check it yourself.',
  ),
  (
    'Can I upload my own files?',
    'Yes. Add books, notes, slides, papers and past exams in My Library. New uploads become '
        'searchable once the AI backend indexes them; the sample library works right away.',
  ),
  (
    'How are my learning gaps found?',
    'Every answer in the diagnostic, practice, reviews and mock tests updates your mastery of '
        'that concept. Concepts below 60%, or not tested yet, show up as gaps.',
  ),
  (
    'Does my study plan change?',
    'Yes. It is rebuilt from your latest results, past papers and daily goal, and My Plan tells '
        'you what changed and why.',
  ),
  (
    'What is Socratic mode?',
    'Instead of giving you the answer, the tutor asks guiding questions so you reason your way '
        'to it. Find it under Practice.',
  ),
  (
    'How is my streak counted?',
    'Your streak grows by one each day you finish at least one session, practice set or review. '
        'Missing a day resets it to zero.',
  ),
];
