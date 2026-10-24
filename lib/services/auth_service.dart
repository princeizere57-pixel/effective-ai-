import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../config/env.dart';
import 'current_user.dart';
import 'session.dart';

/// A sign-in problem to show the learner, in plain words.
class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Signing in with Google or with email and password.
///
/// With real Supabase keys (see `Env.hasSupabase` and env.example.json) this
/// uses Supabase Auth. Without them it runs in demo mode: sign-in is simulated
/// and nothing leaves the device, so the app can be explored before the
/// backend exists.
abstract class AuthService {
  static AuthService instance = Env.hasSupabase ? SupabaseAuthService() : DemoAuthService();

  /// True when sign-in is simulated.
  bool get isDemo;

  /// Starts the service before the app runs (Supabase needs initialising).
  Future<void> init() async {}

  /// Signs in with Google. Returns the learner when sign-in finished here, or
  /// null when it continues in the browser and completes when the learner
  /// comes back (the app is then entered automatically).
  Future<AppUser?> signInWithGoogle();

  Future<AppUser> signInWithEmail(String email, String password);

  /// Creates an account. Throws [AuthFailure] when the email must be
  /// confirmed first.
  Future<AppUser> signUpWithEmail(String fullName, String email, String password);

  Future<void> sendPasswordReset(String email);

  Future<void> signOut();
}

/// Simulated sign-in for the demo: accepts any well-formed details.
class DemoAuthService extends AuthService {
  static const _delay = Duration(milliseconds: 600);

  @override
  bool get isDemo => true;

  @override
  Future<AppUser?> signInWithGoogle() async {
    await Future<void>.delayed(_delay);
    return AppUser.demo;
  }

  @override
  Future<AppUser> signInWithEmail(String email, String password) async {
    await Future<void>.delayed(_delay);
    return AppUser.fromEmail(email);
  }

  @override
  Future<AppUser> signUpWithEmail(String fullName, String email, String password) async {
    await Future<void>.delayed(_delay);
    return AppUser.fromEmail(email, fullName: fullName);
  }

  @override
  Future<void> sendPasswordReset(String email) => Future<void>.delayed(_delay);

  @override
  Future<void> signOut() async {}
}

/// Real sign-in with Supabase Auth (Google OAuth and email/password).
class SupabaseAuthService extends AuthService {
  sb.GoTrueClient get _auth => sb.Supabase.instance.client.auth;

  @override
  bool get isDemo => false;

  @override
  Future<void> init() async {
    await sb.Supabase.initialize(url: Env.supabaseUrl, publishableKey: Env.supabaseAnonKey);
    // Already signed in from a previous visit: open the app straight away.
    final user = _auth.currentUser;
    if (user != null) {
      currentUser.value = _toAppUser(user);
      enterApp();
    }
    // Google sign-in finishes after the browser round trip.
    _auth.onAuthStateChange.listen((state) {
      final user = state.session?.user;
      if (state.event == sb.AuthChangeEvent.signedIn && user != null) {
        currentUser.value = _toAppUser(user);
        if (!signedIn.value) enterApp();
      }
    });
  }

  @override
  Future<AppUser?> signInWithGoogle() => _guard(() async {
        await _auth.signInWithOAuth(
          sb.OAuthProvider.google,
          redirectTo: kIsWeb ? null : Env.authRedirectUrl,
        );
        return null;
      });

  @override
  Future<AppUser> signInWithEmail(String email, String password) => _guard(() async {
        final res = await _auth.signInWithPassword(email: email, password: password);
        return _toAppUser(res.user!);
      });

  @override
  Future<AppUser> signUpWithEmail(String fullName, String email, String password) => _guard(() async {
        final res = await _auth.signUp(email: email, password: password, data: {'full_name': fullName});
        if (res.session == null) {
          throw const AuthFailure('Check your inbox to confirm your email, then log in.');
        }
        return _toAppUser(res.user!);
      });

  @override
  Future<void> sendPasswordReset(String email) => _guard(() => _auth.resetPasswordForEmail(email));

  @override
  Future<void> signOut() => _auth.signOut();

  static AppUser _toAppUser(sb.User user) {
    final meta = user.userMetadata ?? const {};
    final name = (meta['full_name'] ?? meta['name']) as String?;
    return AppUser.fromEmail(user.email ?? '', fullName: name);
  }

  /// Turns Supabase errors into short, plain messages.
  static Future<T> _guard<T>(Future<T> Function() run) async {
    try {
      return await run();
    } on AuthFailure {
      rethrow;
    } on sb.AuthException catch (e) {
      final m = e.message.toLowerCase();
      if (m.contains('invalid login')) throw const AuthFailure('That email and password don’t match. Try again.');
      if (m.contains('already registered')) throw const AuthFailure('An account with this email already exists. Log in instead.');
      if (m.contains('not confirmed')) throw const AuthFailure('Confirm your email first: check your inbox for the link.');
      throw AuthFailure(e.message);
    } catch (_) {
      throw const AuthFailure('Couldn’t reach the sign-in service. Check your connection and try again.');
    }
  }
}
