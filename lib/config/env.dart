/// Runtime configuration passed with `--dart-define-from-file=env.json`.
///
/// Mirrors the public values from the Next.js `.env`. Server secrets
/// (OpenAI, Gemini, Anthropic, Perplexity keys) must stay on a backend.
abstract final class Env {
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://dummy.supabase.co',
  );
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const gaMeasurementId = String.fromEnvironment('GA_MEASUREMENT_ID');
  static const stripePublishableKey = String.fromEnvironment('STRIPE_PUBLISHABLE_KEY');
  static const siteUrl = String.fromEnvironment(
    'SITE_URL',
    defaultValue: 'https://learnspace3105.builtwithrocket.new',
  );

  /// Where Google sends the learner back after signing in on desktop and
  /// mobile (the web app returns to the page it started from). Add it to the
  /// Supabase project's Auth → URL configuration → Redirect URLs.
  static const authRedirectUrl = String.fromEnvironment(
    'AUTH_REDIRECT_URL',
    defaultValue: 'io.effectiveai.app://login-callback',
  );

  /// True when real Supabase keys were supplied. Without them sign-in runs in
  /// demo mode: it is simulated and nothing leaves the device.
  static bool get hasSupabase =>
      supabaseAnonKey.isNotEmpty && !supabaseUrl.contains('dummy') && !supabaseAnonKey.contains('dummy');
}
