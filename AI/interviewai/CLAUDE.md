# InterviewAI — Claude Code Project Guidelines

## Project Overview
AI-powered voice interview coaching app. Flutter 3.41.4 + Dart 3.11.1, Riverpod state management, GoRouter navigation.

## Critical Rules

### API Keys — NEVER hardcode
- All API keys live in `lib/core/constants/env.dart` via `String.fromEnvironment`
- Inject at run time: `flutter run --dart-define=OPENAI_API_KEY=... --dart-define=ANTHROPIC_API_KEY=...`
- `.env` and any file containing real keys must be in `.gitignore`

### Deprecations — Flutter 3.41+
- NEVER use `Color.withOpacity()` → use `Color.withValues(alpha: x)` instead
- NEVER use `MaterialStateProperty` → use `WidgetStateProperty` instead

### Code Style
- No comments unless the WHY is non-obvious
- No trailing summaries or docstrings
- Feature-first directory: `features/<name>/screens/`, `features/<name>/models/`, `core/`, `shared/`

## Architecture

```
lib/
  main.dart                  — ProviderScope + App entry
  app.dart                   — GoRouter + MaterialApp.router
  core/
    api/                     — WhisperClient, ClaudeFeedbackClient
    constants/               — Env (dart-define keys)
    errors/                  — sealed AppException hierarchy
    services/                — AudioRecorderService, TtsService
  features/
    interview/
      screens/               — OnboardingScreen, InterviewScreen
    feedback/
      models/                — FeedbackModel
      screens/               — FeedbackScreen
    history/
      screens/               — HistoryScreen (placeholder → Firebase in Step 3)
  shared/
    constants/               — question_bank.dart
    theme/                   — AppTheme (primary #4F46E5, Material 3)
```

## Routing (GoRouter)
| Path | Screen | Extra params |
|---|---|---|
| `/` | OnboardingScreen | — |
| `/interview` | InterviewScreen | `category`, `type`, `count` |
| `/feedback` | FeedbackScreen | `feedback`, `question`, `answer`, `isLast`, `onNext` |
| `/history` | HistoryScreen | — |

## External APIs
| Service | Client | Notes |
|---|---|---|
| OpenAI Whisper | `WhisperClient` | model: whisper-1, lang: ko, m4a format |
| Anthropic Claude | `ClaudeFeedbackClient` | claude-sonnet-4-6, STAR framework, 3 retries |

## Firebase (Step 3 — deferred)
`FirebaseApp.initializeApp()` is intentionally absent from `main.dart` until `google-services.json` is configured.

## Verification Checklist (before each commit)
1. `flutter analyze` → No issues found
2. No hardcoded API keys (`grep -r "sk-" lib/`)
3. No `withOpacity` calls (`grep -r "withOpacity" lib/`)
4. All routes in `app.dart` have corresponding screen files

## Step Status
- [x] Step 1 — Core structure, audio pipeline, Whisper STT, Claude feedback
- [x] Step 2 — Category expansion (100+ jobs), UI polish, question counts (3/5/7/10)
- [x] Step 3 — Firebase auth + Firestore history (requires google-services.json)
- [ ] Step 4 — Analytics, sharing, Play Store prep

## Routing (updated)
| Path | Screen | Extra params |
|---|---|---|
| `/` | OnboardingScreen | — |
| `/login` | LoginScreen | — |
| `/interview` | InterviewScreen | `job`, `type`, `count` |
| `/feedback` | FeedbackScreen | `feedback`, `question`, `answer`, `isLast`, `onNext`, `onFinish` |
| `/result` | ResultScreen | `job`, `results` |
| `/history` | HistoryScreen | — |
| `/session-detail` | SessionDetailScreen | `userId`, `sessionId`, `job`, `score` |
