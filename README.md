# Effective AI (Flutter)

A private knowledge layer for learning: your data → private knowledge base → specialised AI →
understand, analyse and compare → useful outputs → automated workflows → measured outcomes.
In short: knowledge compression, knowledge navigation and knowledge application.

## Features

All 32 features have working screens. They run on a sample Machine Learning library
(`lib/data/knowledge.dart`): every answer, search result, question and comparison is drawn
from those passages and cites the document, page and section.

| Section | Features |
| --- | --- |
| Home | 32 Suggestions |
| My Library | 1 Private Knowledge Library (upload books, notes, slides, papers, past exams) |
| Ask My Knowledge | 2 Ask My Knowledge · 3 Source Verification · 10 Ask Across Documents |
| Search & Explore | 4 Smart Search · 11 Topic Explorer |
| Explain This | 5 Explain This · 6 Simplify / Deepen |
| Connections | 7 Concept Connections · 8 Compare Sources · 9 Knowledge Map |
| Diagnose & Improve | 12 Learning Gap Detection · 13 Diagnostic · 14 Targeted Learning · 19 Error Analysis · 20 Remediation |
| Practice | 15 Practice Generator · 16 Active Recall · 17 Socratic Mode · 18 Answer Evaluation · 29 Knowledge Review |
| Exam Prep | 21 Exam Preparation · 22 Past Paper Intelligence · 23 Mock Test · 24 Post-Test Analysis |
| Study Session | 25 Study Session Workflow (learn → practise → test → review) |
| My Plan | 26 Study Plan Generator · 27 Adaptive Study Plan |
| My Progress | 28 Progress Memory · 30 Personal Learning Report |
| Help & Suggestions | Guide to all features · 31 Personal Review Pop-Up (also shown after sessions and tests) |

### What is real and what needs the AI backend

- `lib/services/knowledge_engine.dart` is a sample engine: keyword retrieval, extractive
  answers with citations, keyword-based marking and past-paper analysis. Replace it with
  embeddings + an LLM on a server (for example Supabase pgvector + an Edge Function) without
  changing the screens.
- Uploaded files are added to the library but are not parsed or indexed until that backend exists.
- Progress memory, feedback and the plan live in memory (`lib/services/learner_state.dart`) and
  reset on restart; persist them to the backend next.

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
   flutter create . --project-name effective_ai
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
├── navigation.dart        # Sections, sidebar groups, guide to all 32 features
├── theme/                 # Tokens from tailwind.config.js, light and dark palettes
├── data/knowledge.dart    # Sample library: documents, passages, concepts, questions
├── data/mock_data.dart    # Profile, deadlines, FAQs
├── services/              # Knowledge engine, learner memory, study planner
├── widgets/               # Reusable UI (was src/components)
└── screens/               # One file per section, plus the study session workflow
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
