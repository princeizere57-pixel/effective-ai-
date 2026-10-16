import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../theme/app_palette.dart';
import '../theme/theme_controller.dart';
import '../widgets/common.dart';
import '../widgets/fade_slide_in.dart';
import 'page_scaffold.dart';

/// Preferences are kept in memory for now; persist them (for example with
/// shared_preferences or Supabase) when a backend is added.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _dailyReminder = true;
  bool _weeklyReport = true;
  bool _sounds = false;
  int _dailyGoal = 30;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    const sectionTitle = TextStyle(fontSize: 16, fontWeight: FontWeight.w700);
    final sub = TextStyle(color: p.mutedForeground, fontSize: 13);

    return PageScaffold(
      builder: (context, width) => [
        const FadeSlideIn(
          child: PageHeader(
            title: 'Settings',
            subtitle: 'Your goals, appearance, notifications and account.',
          ),
        ),
        const SizedBox(height: 20),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Appearance', style: sectionTitle),
              const SizedBox(height: 4),
              Text('Light, dark, or match your device.', style: sub),
              const SizedBox(height: 16),
              ValueListenableBuilder<ThemeMode>(
                valueListenable: themeMode,
                builder: (context, mode, _) => SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                    ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
                    ButtonSegment(value: ThemeMode.system, label: Text('System')),
                  ],
                  selected: {mode},
                  showSelectedIcon: false,
                  onSelectionChanged: (s) => themeMode.value = s.first,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Daily goal', style: sectionTitle),
              const SizedBox(height: 4),
              Text(
                'How long you want to study each day. Meeting it keeps your streak going.',
                style: sub,
              ),
              const SizedBox(height: 16),
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 15, label: Text('15 min')),
                  ButtonSegment(value: 30, label: Text('30 min')),
                  ButtonSegment(value: 60, label: Text('60 min')),
                ],
                selected: {_dailyGoal},
                showSelectedIcon: false,
                onSelectionChanged: (s) => setState(() => _dailyGoal = s.first),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Panel(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 8, 24, 4),
                child: Text('Notifications', style: sectionTitle),
              ),
              SwitchListTile(
                value: _dailyReminder,
                onChanged: (v) => setState(() => _dailyReminder = v),
                title: const Text('Daily study reminder'),
                subtitle: const Text('A nudge at 18:00 if you have not studied yet'),
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              ),
              SwitchListTile(
                value: _weeklyReport,
                onChanged: (v) => setState(() => _weeklyReport = v),
                title: const Text('Weekly progress report'),
                subtitle: const Text('Every Sunday evening'),
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              ),
              SwitchListTile(
                value: _sounds,
                onChanged: (v) => setState(() => _sounds = v),
                title: const Text('Sounds'),
                subtitle: const Text('Play a sound when you finish a lesson'),
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Panel(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Account', style: sectionTitle),
                    const SizedBox(height: 4),
                    const Text(userFullName),
                    Text(userEmail, style: sub),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => showToast(context, 'Signed out'),
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Sign out'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
