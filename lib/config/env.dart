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
}
