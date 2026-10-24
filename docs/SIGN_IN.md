# Turning on real sign-in (Google and email)

Pressing **Log in**, **Start your path to an A** or **Sign up free** opens the sign-in screen (`lib/screens/auth_screen.dart`): **Continue with Google**, or email and password, with "Forgot password?" and a switch between logging in and creating an account.

Until real Supabase keys are supplied, the app runs in **demo mode**. Sign-in is simulated, nothing leaves the device, and the screen says so. The website preview (`site/index.html`) is always demo mode, because it has no backend.

## Steps

1. **Create a Supabase project** at https://supabase.com (the free plan is enough).
2. **Turn on email sign-in.** Go to Authentication → Sign In / Providers → **Email** and switch it on. If "Confirm email" is on, new accounts must click the link in their inbox before logging in. The app tells them this.
3. **Turn on Google sign-in.**
   1. In Google Cloud Console, create an **OAuth client ID** of type "Web application".
   2. Add Supabase's callback URL (shown on the Google provider page in Supabase) to the client's **Authorized redirect URIs**.
   3. In Supabase, go to Authentication → Sign In / Providers → **Google** and paste the client ID and secret.
4. **Allow the app's return addresses.** In Supabase, go to Authentication → URL Configuration → **Redirect URLs** and add:
   - your website, for example `https://princeizere57-pixel.github.io/effective-ai-/`
   - `io.effectiveai.app://login-callback`, for the desktop and mobile apps (or your own `AUTH_REDIRECT_URL`)
5. **Add your keys.** Copy `env.example.json` to `env.json` (git ignores it) and fill in `SUPABASE_URL` and `SUPABASE_ANON_KEY`. Both are on Project Settings → API; the anon key is the "publishable" one, safe for apps.
6. **Run the app with the keys:**
   ```
   flutter run -d chrome --dart-define-from-file=env.json
   ```

With the keys in place, `AuthService` (`lib/services/auth_service.dart`) switches from demo mode to Supabase automatically:

- **Email:** logs in, creates accounts and sends reset links through Supabase.
- **Google:** opens Google's sign-in page and returns to the app.
- **Returning learners:** someone who is already signed in goes straight into the app on their next visit.

The desktop and mobile apps also need the `io.effectiveai.app` link scheme registered to receive the Google redirect. That is a separate platform setup step, and the web app works without it.
