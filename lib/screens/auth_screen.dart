import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/current_user.dart';
import '../services/session.dart';
import '../theme/app_palette.dart';
import '../theme/app_theme.dart';
import '../widgets/logo_mark.dart';

final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');

/// Opens the sign-in screen: Continue with Google, or email and password.
/// [signUp] picks "Create your account" over "Log in"; the learner can switch.
Future<void> showAuthDialog(BuildContext context, {required bool signUp}) {
  return showDialog<void>(
    context: context,
    builder: (context) => _AuthDialog(signUp: signUp),
  );
}

class _AuthDialog extends StatefulWidget {
  const _AuthDialog({required this.signUp});

  final bool signUp;

  @override
  State<_AuthDialog> createState() => _AuthDialogState();
}

class _AuthDialogState extends State<_AuthDialog> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  late bool _signUp = widget.signUp;
  bool _showPassword = false;
  bool _busy = false;
  String? _error;
  String? _info;

  AuthService get _auth => AuthService.instance;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _signedIn(AppUser user, String message) {
    currentUser.value = user;
    Navigator.of(context).pop();
    enterApp();
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
      _info = null;
    });
    try {
      await action();
    } on AuthFailure catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _google() => _run(() async {
        final user = await _auth.signInWithGoogle();
        if (!mounted) return;
        if (user != null) {
          _signedIn(user, 'Signed in with Google as ${user.email}');
        } else {
          setState(() => _info = 'Finish signing in with Google in the window that opened.');
        }
      });

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final email = _email.text.trim();
    await _run(() async {
      final user = _signUp
          ? await _auth.signUpWithEmail(_name.text.trim(), email, _password.text)
          : await _auth.signInWithEmail(email, _password.text);
      if (!mounted) return;
      _signedIn(user, _signUp ? 'Welcome to Effective AI, ${user.firstName}' : 'Logged in as ${user.email}');
    });
  }

  Future<void> _forgot() async {
    final email = _email.text.trim();
    if (!_emailPattern.hasMatch(email)) {
      setState(() => _error = 'Enter your email address first, then choose “Forgot password?”.');
      return;
    }
    await _run(() async {
      await _auth.sendPasswordReset(email);
      if (mounted) setState(() => _info = 'Password reset link sent to $email.');
    });
  }

  void _switchMode() => setState(() {
        _signUp = !_signUp;
        _error = null;
        _info = null;
        _form.currentState?.reset();
      });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    Widget label(String text) => Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 6),
          child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        );
    InputDecoration field(String hint, {Widget? suffix}) => InputDecoration(
          hintText: hint,
          isDense: true,
          filled: true,
          fillColor: p.muted,
          suffixIcon: suffix,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: p.border)),
          enabledBorder:
              OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: p.border)),
          focusedBorder:
              OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: p.foreground)),
        );

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(child: LogoMark(size: 44)),
                const SizedBox(height: 8),
                Text(_signUp ? 'Create your account' : 'Welcome back',
                    textAlign: TextAlign.center, style: AppTheme.display(22)),
                const SizedBox(height: 4),
                Text(
                  _signUp ? 'Start your path to an A. It’s free.' : 'Log in to pick up where you left off.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: p.mutedForeground),
                ),
                const SizedBox(height: 18),
                OutlinedButton(
                  onPressed: _busy ? null : _google,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: p.foreground,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: p.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/google_g.png', width: 18, height: 18, semanticLabel: 'Google'),
                      const SizedBox(width: 10),
                      const Flexible(
                        child: Text('Continue with Google', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(child: Divider(color: p.border)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('or ${_signUp ? 'sign up' : 'log in'} with email',
                        style: TextStyle(color: p.subtle, fontSize: 12)),
                  ),
                  Expanded(child: Divider(color: p.border)),
                ]),
                if (_signUp) ...[
                  label('Full name'),
                  TextFormField(
                    controller: _name,
                    autofillHints: const [AutofillHints.name],
                    textInputAction: TextInputAction.next,
                    decoration: field('Jane Doe'),
                  ),
                ],
                label('Email'),
                TextFormField(
                  controller: _email,
                  autofillHints: const [AutofillHints.email],
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: field('you@university.edu'),
                  validator: (v) => _emailPattern.hasMatch((v ?? '').trim())
                      ? null
                      : 'Enter a valid email address, like you@university.edu.',
                ),
                Row(children: [
                  Expanded(child: label('Password')),
                  if (!_signUp)
                    TextButton(
                      onPressed: _busy ? null : _forgot,
                      style: TextButton.styleFrom(foregroundColor: p.foreground, padding: EdgeInsets.zero),
                      child: const Text('Forgot password?', style: TextStyle(decoration: TextDecoration.underline)),
                    ),
                ]),
                TextFormField(
                  controller: _password,
                  obscureText: !_showPassword,
                  autofillHints: [_signUp ? AutofillHints.newPassword : AutofillHints.password],
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  decoration: field(
                    _signUp ? 'At least 8 characters' : 'Your password',
                    suffix: TextButton(
                      onPressed: () => setState(() => _showPassword = !_showPassword),
                      style: TextButton.styleFrom(foregroundColor: p.foreground),
                      child: Text(_showPassword ? 'Hide' : 'Show'),
                    ),
                  ),
                  validator: (v) {
                    final value = v ?? '';
                    if (_signUp && value.length < 8) return 'Use at least 8 characters for your password.';
                    if (!_signUp && value.isEmpty) return 'Enter your password.';
                    return null;
                  },
                ),
                if (_error != null || _info != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: p.muted, borderRadius: BorderRadius.circular(8)),
                    child: Text(_error ?? _info!, style: const TextStyle(fontSize: 13)),
                  ),
                ],
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _busy ? null : _submit,
                  style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: _busy
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(_signUp ? 'Create account' : 'Log in'),
                ),
                const SizedBox(height: 12),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(_signUp ? 'Already have an account?' : 'New to Effective AI?'),
                    TextButton(
                      onPressed: _busy ? null : _switchMode,
                      style: TextButton.styleFrom(foregroundColor: p.foreground),
                      child: Text(_signUp ? 'Log in' : 'Create an account',
                          style: const TextStyle(decoration: TextDecoration.underline, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                if (_auth.isDemo)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_outline, size: 14, color: p.subtle),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Demo mode: sign-in is simulated until accounts are connected.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: p.subtle, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
