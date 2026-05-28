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
  main.dart                     — ProviderScope + Firebase init + App entry
  app.dart                      — GoRouter (7 routes) + MaterialApp.router
  core/
    api/                        — WhisperClient, ClaudeFeedbackClient
    constants/                  — Env (dart-define keys)
    errors/                     — sealed AppException hierarchy
    services/                   — AudioRecorderService, TtsService, StreakService
  features/
    auth/
      repositories/             — AuthRepository (Google + email/pw + reset)
      screens/                  — LoginScreen (탭바: 로그인/회원가입)
    interview/
      models/                   — SessionModel (QuestionResult, SessionSummary)
      repositories/             — SessionRepository (Firestore CRUD)
      screens/                  — OnboardingScreen (스트릭 뱃지), InterviewScreen
    feedback/
      models/                   — FeedbackModel
      screens/                  — FeedbackScreen (점수 게이지 + STAR 힌트 바텀시트)
    history/
      screens/                  — HistoryScreen (꺾은선 그래프 + 취약점 태그)
                                  SessionDetailScreen (레이더 차트 + 답변 카드)
    result/
      screens/                  — ResultScreen (전체 결과 + 클립보드 공유)
  shared/
    constants/                  — question_bank.dart (100+ 질문, 직군별)
    theme/                      — AppTheme (primary #4F46E5, Material 3)
```

## Routing (GoRouter)
| Path | Screen | Extra params |
|---|---|---|
| `/` | OnboardingScreen | — |
| `/login` | LoginScreen | — |
| `/interview` | InterviewScreen | `job`, `type`, `count` |
| `/feedback` | FeedbackScreen | `feedback`, `question`, `answer`, `isLast`, `onNext`, `onFinish` |
| `/result` | ResultScreen | `job`, `results` |
| `/history` | HistoryScreen | — |
| `/session-detail` | SessionDetailScreen | `userId`, `sessionId`, `job`, `score` |

## External APIs
| Service | Client | Notes |
|---|---|---|
| OpenAI Whisper | `WhisperClient` | model: whisper-1, lang: ko, m4a format |
| Anthropic Claude | `ClaudeFeedbackClient` | claude-sonnet-4-6, STAR framework, 3 retries |

## Firebase
Firebase initialized in `main.dart` wrapped in try/catch — app runs without `google-services.json` for local dev. Provide the file for Firestore/Auth to be fully functional.

Firestore schema: `users/{uid}/sessions/{sid}` + `questionAnswers` subcollection.

## Verification Checklist (before each commit)
1. `flutter analyze` → No issues found
2. No hardcoded API keys (`grep -r "sk-" lib/`)
3. No `withOpacity` calls (`grep -r "withOpacity" lib/`)
4. All routes in `app.dart` have corresponding screen files

## Step Status — 전체 완료 ✅
- [x] Step 1 — Core structure, audio pipeline, Whisper STT, Claude feedback
- [x] Step 2 — Category expansion (100+ jobs), UI polish, question counts (3/5/7/10)
- [x] Step 3 — Firebase auth + Firestore history (requires google-services.json)
- [x] Step 4 — Analytics (weakness tags), sharing (clipboard), streak tracking, radar chart
