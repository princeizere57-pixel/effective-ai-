import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class Course {
  const Course({
    required this.title,
    required this.instructor,
    required this.category,
    required this.lessonsDone,
    required this.lessonsTotal,
    required this.accent,
    required this.icon,
    this.isNew = false,
  });

  final String title;
  final String instructor;
  final bool isNew;
  final String category;
  final int lessonsDone;
  final int lessonsTotal;
  final Color accent;
  final IconData icon;

  double get progress => lessonsTotal == 0 ? 0 : lessonsDone / lessonsTotal;
}

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

class Skill {
  const Skill(this.name, this.mastery, this.color);

  final String name;
  final double mastery;
  final Color color;
}

const userFirstName = 'Alex';
const userFullName = 'Alex Morgan';
const userEmail = 'alex@effective-ai.app';
const streakDays = 12;

const categories = ['All', 'AI & ML', 'Programming', 'Design', 'Math'];

const courses = <Course>[
  Course(
    title: 'Neural Networks Fundamentals',
    instructor: 'Dr. Priya Raman',
    category: 'AI & ML',
    lessonsDone: 13,
    lessonsTotal: 20,
    accent: AppColors.violet,
    icon: Icons.psychology_outlined,
  ),
  Course(
    title: 'Data Structures in Dart',
    instructor: 'Marcus Lee',
    category: 'Programming',
    lessonsDone: 8,
    lessonsTotal: 20,
    accent: AppColors.blue,
    icon: Icons.account_tree_outlined,
  ),
  Course(
    title: 'UX Research Methods',
    instructor: 'Sofia Alvarez',
    category: 'Design',
    lessonsDone: 14,
    lessonsTotal: 17,
    accent: AppColors.green,
    icon: Icons.person_search_outlined,
  ),
  Course(
    title: 'Linear Algebra for ML',
    instructor: 'Prof. Daniel Okafor',
    category: 'Math',
    lessonsDone: 3,
    lessonsTotal: 15,
    accent: AppColors.amber,
    icon: Icons.functions,
  ),
  Course(
    title: 'Prompt Engineering Basics',
    instructor: 'Hana Kim',
    category: 'AI & ML',
    lessonsDone: 9,
    lessonsTotal: 12,
    accent: AppColors.violetDark,
    icon: Icons.chat_bubble_outline,
    isNew: true,
  ),
  Course(
    title: 'Typography Essentials',
    instructor: 'Jonas Becker',
    category: 'Design',
    lessonsDone: 0,
    lessonsTotal: 10,
    accent: AppColors.red,
    icon: Icons.text_fields,
    isNew: true,
  ),
];

class PracticeSet {
  const PracticeSet({
    required this.title,
    required this.course,
    required this.questions,
    required this.minutes,
    required this.difficulty,
    required this.accent,
    required this.sampleQuestion,
    required this.options,
    required this.answer,
  });

  final String title;
  final String course;
  final int questions;
  final int minutes;
  final String difficulty;
  final Color accent;
  final String sampleQuestion;
  final List<String> options;
  final int answer;
}

const practiceSets = <PracticeSet>[
  PracticeSet(
    title: 'Backpropagation drill',
    course: 'Neural Networks Fundamentals',
    questions: 10,
    minutes: 12,
    difficulty: 'Medium',
    accent: AppColors.violet,
    sampleQuestion: 'What does backpropagation compute?',
    options: [
      'The gradient of the loss with respect to each weight',
      'The final prediction of the network',
      'The best learning rate for training',
    ],
    answer: 0,
  ),
  PracticeSet(
    title: 'Graph traversal',
    course: 'Data Structures in Dart',
    questions: 8,
    minutes: 10,
    difficulty: 'Easy',
    accent: AppColors.blue,
    sampleQuestion: 'Which traversal visits nodes level by level using a queue?',
    options: ['Depth-first search', 'Breadth-first search', 'In-order traversal'],
    answer: 1,
  ),
  PracticeSet(
    title: 'Eigenvectors check-in',
    course: 'Linear Algebra for ML',
    questions: 6,
    minutes: 8,
    difficulty: 'Hard',
    accent: AppColors.amber,
    sampleQuestion: 'If Av = λv for a non-zero vector v, what is v?',
    options: ['An eigenvalue of A', 'An eigenvector of A', 'The inverse of A'],
    answer: 1,
  ),
];

class PlanSession {
  const PlanSession(this.day, this.time, this.title, this.course, this.minutes);

  final String day;
  final String time;
  final String title;
  final String course;
  final int minutes;
}

const planSessions = <PlanSession>[
  PlanSession('Today', '18:00', 'Lesson 14: Backpropagation', 'Neural Networks Fundamentals', 30),
  PlanSession('Today', '19:00', 'Practice: Backpropagation drill', 'Neural Networks Fundamentals', 12),
  PlanSession('Tomorrow', '10:00', 'Lesson 9: Graph traversal', 'Data Structures in Dart', 40),
  PlanSession('Tomorrow', '11:00', 'Re-read chapter 4', 'Linear Algebra for ML', 25),
  PlanSession('Sunday', '16:00', 'Synthesis workshop', 'UX Research Methods', 35),
  PlanSession('Monday', '18:30', 'Lesson 10: Few-shot prompts', 'Prompt Engineering Basics', 20),
];

const suggestedTopics = ['Gradient descent', 'Big-O notation', 'Eigenvalues', 'Usability testing'];

const faqs = <(String, String)>[
  (
    'How is my streak counted?',
    'Your streak grows by one each day you finish at least one lesson or practice set. '
        'Missing a day resets it to zero.',
  ),
  (
    'What does Understand do?',
    'Ask about any concept from your courses and get a step-by-step explanation, '
        'a worked example and a quick check question.',
  ),
  (
    'How are practice sets chosen?',
    'Practice sets focus on the topics where your quiz scores are lowest, '
        'spaced over the week so you review before you forget.',
  ),
  (
    'Where does My Plan come from?',
    'Sessions are built from your courses and upcoming deadlines. '
        'Tick them off as you finish them.',
  ),
];

const stats = <Stat>[
  Stat(
    label: 'Day streak',
    value: '$streakDays',
    delta: '+3',
    icon: Icons.local_fire_department_outlined,
    color: AppColors.amber,
  ),
  Stat(
    label: 'Hours this week',
    value: '14.5',
    delta: '+18%',
    icon: Icons.schedule,
    color: AppColors.violet,
  ),
  Stat(
    label: 'Courses completed',
    value: '7',
    icon: Icons.workspace_premium_outlined,
    color: AppColors.green,
  ),
  Stat(
    label: 'Avg. quiz score',
    value: '88%',
    delta: '+4',
    icon: Icons.task_alt,
    color: AppColors.blue,
  ),
];

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

const deadlines = <Deadline>[
  Deadline(
    title: 'Read chapter 4: Eigenvectors',
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
    title: 'Assignment: Graph traversal',
    course: 'Data Structures in Dart',
    due: 'In 3 days',
    status: DeadlineStatus.upcoming,
  ),
  Deadline(
    title: 'Peer review: Interview notes',
    course: 'UX Research Methods',
    due: 'Done',
    status: DeadlineStatus.done,
  ),
];

const skills = <Skill>[
  Skill('Machine learning', 0.72, AppColors.violet),
  Skill('Algorithms', 0.48, AppColors.blue),
  Skill('User research', 0.85, AppColors.green),
  Skill('Linear algebra', 0.31, AppColors.amber),
];
