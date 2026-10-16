import 'package:flutter/material.dart';

import 'data/mock_data.dart';

/// Every destination in the sidebar.
enum AppSection {
  home('Home', Icons.home_outlined),
  knowledge('My Knowledge', Icons.menu_book_outlined),
  understand('Understand', Icons.chat_bubble_outline),
  practice('Practice', Icons.fitness_center),
  plan('My Plan', Icons.calendar_month_outlined),
  progress('My Progress', Icons.bar_chart),
  help('Help & Suggestions', Icons.help_outline),
  settings('Settings', Icons.settings_outlined);

  const AppSection(this.label, this.icon);

  final String label;
  final IconData icon;

  /// Count shown in the sidebar badge, or null for none.
  int? get badge => switch (this) {
        AppSection.knowledge => courses.where((c) => c.isNew).length,
        AppSection.practice => practiceSets.length,
        _ => null,
      };
}

const mainSections = [
  AppSection.home,
  AppSection.knowledge,
  AppSection.understand,
  AppSection.practice,
  AppSection.plan,
  AppSection.progress,
];

const footerSections = [AppSection.help, AppSection.settings];
