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
  });

  final String title;
  final String instructor;
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
    required this.paleColor,
    this.delta,
  });

  final String label;
  final String value;
  final String? delta;
  final IconData icon;
  final Color color;
  final Color paleColor;
}

class Skill {
  const Skill(this.name, this.mastery, this.color);

  final String name;
  final double mastery;
  final Color color;
}

const userFirstName = 'Alex';
const userFullName = 'Alex Morgan';
const userEmail = 'alex@learnspace.app';
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
  ),
  Course(
    title: 'Typography Essentials',
    instructor: 'Jonas Becker',
    category: 'Design',
    lessonsDone: 0,
    lessonsTotal: 10,
    accent: AppColors.red,
    icon: Icons.text_fields,
  ),
];

const stats = <Stat>[
  Stat(
    label: 'Day streak',
    value: '$streakDays',
    delta: '+3',
    icon: Icons.local_fire_department_outlined,
    color: AppColors.amber,
    paleColor: AppColors.amberPale,
  ),
  Stat(
    label: 'Hours this week',
    value: '14.5',
    delta: '+18%',
    icon: Icons.schedule,
    color: AppColors.violet,
    paleColor: AppColors.violetPale,
  ),
  Stat(
    label: 'Courses completed',
    value: '7',
    icon: Icons.workspace_premium_outlined,
    color: AppColors.green,
    paleColor: AppColors.greenPale,
  ),
  Stat(
    label: 'Avg. quiz score',
    value: '88%',
    delta: '+4',
    icon: Icons.task_alt,
    color: AppColors.blue,
    paleColor: AppColors.bluePale,
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
