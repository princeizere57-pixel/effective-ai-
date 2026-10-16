import 'dart:math';

import 'package:flutter/foundation.dart';

import '../data/mock_data.dart';
import '../navigation.dart';

/// Whether the learner has entered the app from the welcome page.
///
/// There are no real accounts yet: entering opens the sample library. Replace
/// this with the backend's auth state (for example Supabase Auth) when it exists.
final signedIn = ValueNotifier<bool>(false);

/// Where the app opens after the welcome page, and a question typed there.
AppSection? startSection;
String? pendingQuestion;

/// Greeting shown on Home, chosen once each time the learner enters.
String homeGreeting = '';

/// Welcome page headlines; one is picked at random on every visit.
const welcomeMessages = [
  'Where should we begin?',
  'What are you studying today?',
  'Which topic should we master first?',
  'Ready to turn your notes into knowledge?',
  'What would you like to understand better?',
  "Got an exam coming up? Let's prepare.",
];

final _random = Random();

String pickWelcomeMessage() => welcomeMessages[_random.nextInt(welcomeMessages.length)];

void enterApp({AppSection? section, String? question}) {
  startSection = question != null ? AppSection.ask : section;
  pendingQuestion = question;
  final hour = DateTime.now().hour;
  final timeOfDay = hour < 12 ? 'Good morning' : (hour < 18 ? 'Good afternoon' : 'Good evening');
  final greetings = [
    '$timeOfDay, $userFirstName',
    'Welcome back, $userFirstName',
    'Good to see you again, $userFirstName',
    'Ready when you are, $userFirstName',
    "Let's keep your streak going, $userFirstName",
  ];
  homeGreeting = greetings[_random.nextInt(greetings.length)];
  signedIn.value = true;
}

void signOut() {
  startSection = null;
  pendingQuestion = null;
  signedIn.value = false;
}
