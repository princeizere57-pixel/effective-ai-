# LearnSpace (Flutter)

Flutter port of the LearnSpace Next.js 15 + Tailwind app.

## GitHub Codespaces (no local install)

1. On the repository page, click **Code → Codespaces → Create codespace on main**.
2. Wait for the first build (about 5–10 minutes; it installs Flutter and runs `flutter pub get`).
3. In the terminal run:
   ```bash
   bash .devcontainer/run-web.sh
   ```
4. Open the **Ports** tab and click the globe icon next to port 4028.

Press `r` in the terminal to hot-reload after editing, `R` to restart, `q` to quit.

## Local setup

1. Install Flutter 3.27 or newer: https://docs.flutter.dev/get-started/install
2. Generate the platform folders (web, android, ios, windows…) in this directory:
   ```bash
   flutter create . --project-name learnspace
   ```
   This keeps the existing `lib/` and `pubspec.yaml`.
3. Install dependencies and run:
   ```bash
   flutter pub get
   flutter run -d chrome --web-port 4028
   ```

## Configuration

Copy `env.example.json` to `env.json`, fill in your values, then run with:

```bash
flutter run -d chrome --dart-define-from-file=env.json
```

Only client-safe keys belong here. `OPENAI_API_KEY`, `GEMINI_API_KEY`, `ANTHROPIC_API_KEY`
and `PERPLEXITY_API_KEY` were server-side in Next.js; anything compiled into a Flutter app
can be extracted by users, so call those APIs from a backend (for example a Supabase Edge
Function) instead.

## Project structure

```
lib/
├── main.dart              # App entry (was src/app/layout.tsx)
├── config/env.dart        # --dart-define values (was .env)
├── theme/                 # Tokens from tailwind.config.js
├── data/mock_data.dart    # Sample courses, stats, deadlines
├── widgets/               # Reusable UI (was src/components)
└── screens/               # Dashboard, Courses, Analytics (was src/app/page.tsx)
```

## Next.js → Flutter mapping

| Next.js                    | Flutter                         |
| -------------------------- | ------------------------------- |
| Tailwind theme             | `lib/theme/app_colors.dart`     |
| recharts                   | `fl_chart`                      |
| sonner toasts              | `SnackBar`                      |
| lucide / heroicons         | Material `Icons`                |
| `animate-slide-up`         | `FadeSlideIn` widget            |
| `animate-progress-fill`    | `ProgressBar` widget            |
| ESLint + Prettier          | `analysis_options.yaml`, `dart format` |

## Scripts

- `flutter run -d chrome` – dev server
- `flutter build web` – production build (`build/web`)
- `flutter analyze` – lint
- `dart format lib` – format
