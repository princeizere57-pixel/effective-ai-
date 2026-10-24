import 'package:flutter/foundation.dart';

/// The signed-in learner, shown in the sidebar, greetings and Settings.
@immutable
class AppUser {
  const AppUser({required this.fullName, required this.email});

  /// "jane.doe@uni.ac.uk" becomes "Jane Doe" when no name was given.
  factory AppUser.fromEmail(String email, {String? fullName}) =>
      AppUser(fullName: (fullName ?? '').trim().isEmpty ? nameFromEmail(email) : fullName!.trim(), email: email);

  /// The sample learner used by the demo library.
  static const demo = AppUser(fullName: 'Alex Morgan', email: 'alex@effective-ai.app');

  final String fullName;
  final String email;

  String get firstName => fullName.split(RegExp(r'\s+')).first;
  String get initial => fullName.isEmpty ? '?' : fullName[0].toUpperCase();
}

String nameFromEmail(String email) {
  final words = email.split('@').first.split(RegExp(r'[._\-+]+')).where((w) => w.isNotEmpty);
  final name = words.map((w) => w[0].toUpperCase() + w.substring(1)).join(' ');
  return name.isEmpty ? 'Student' : name;
}

/// Who is signed in. Starts as the sample learner until someone signs in.
final currentUser = ValueNotifier<AppUser>(AppUser.demo);
