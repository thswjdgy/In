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
    api/                        — WhisperClient, ClaudeFeedbackClient, ClaudeQuestionClient
    constants/                  — Env (dart-define keys)
    errors/                     — sealed AppException hierarchy
    services/                   — AudioRecorderService, TtsService, StreakService
  features/
    auth/
      repositories/             — AuthRepository (Firebase + 로컬 fallback 이중화)
      screens/                  — LoginScreen (토스 스타일, 탭바: 로그인/회원가입)
    interview/
      models/                   — SessionModel (QuestionResult, SessionSummary)
      repositories/             — SessionRepository (Firestore + SharedPreferences 이중화)
      screens/                  — OnboardingScreen, InterviewScreen
    feedback/
      models/                   — FeedbackModel (score, STAR, goodPoint, badPoint, betterVersion,
                                  speechSpeedCpm, fillerWords, InterviewPersona, InterviewMode)
      screens/                  — FeedbackScreen
    history/
      screens/                  — HistoryScreen, SessionDetailScreen
    result/
      screens/                  — ResultScreen
  shared/
    constants/                  — question_bank.dart (100+ 질문)
    theme/                      — AppTheme (primary #4F46E5, Material 3)
```

## Routing (GoRouter)
| Path | Screen | Extra params |
|---|---|---|
| `/` | OnboardingScreen | — |
| `/login` | LoginScreen | — |
| `/interview` | InterviewScreen | `job`, `type`, `count`, `resume?`, `jobPosting?`, `persona`, `mode` (persona: InterviewPersona enum, mode: InterviewMode enum) |
| `/feedback` | FeedbackScreen | `feedback`, `question`, `answer`, `followUpQuestion?`, `isLast`, `onNext?`, `onFinish?` |
| `/result` | ResultScreen | `job`, `results` |
| `/history` | HistoryScreen | — |
| `/session-detail` | SessionDetailScreen | `userId`, `sessionId`, `job`, `score` |

## External APIs
| Service | Client | Notes |
|---|---|---|
| OpenAI Whisper | `WhisperClient` | model: whisper-1, lang: ko, m4a |
| Anthropic Claude (피드백) | `ClaudeFeedbackClient` | claude-sonnet-4-6, STAR+goodPoint+badPoint+betterVersion, 3 retries |
| Anthropic Claude (질문) | `ClaudeQuestionClient` | generateQuestions (자소서/채용공고/페르소나), generateFollowUp |

## Auth & Session 이중화 (Firebase 미설정 시)
- `AuthRepository._firebaseAvailable` → `Firebase.apps.isNotEmpty` 로 정확 판별
- Firebase 없음 → SharedPreferences 기반 로컬 인증 (LocalUser 모델)
- 세션 저장 → Firestore 시도 후 실패 시 SharedPreferences 로컬 저장
- 앱 재시작 시 `LoginScreen.initState`에서 로컬 세션 확인 → 자동 로그인

## InterviewScreen 상태 머신
```
loading → ready ↔ thinking(실전30s) → speaking → ready
ready → recording → processing → followUp ↔ followUpRec
followUp → evaluating / followUpProc → evaluating → done
```

## 면접 모드
| 모드 | 특징 |
|---|---|
| 연습 모드 | 시간 제한 없음, STAR 힌트 카드 표시 |
| 실전 모드 | 준비 30초 카운트다운, 답변 2분 제한, 30초 남으면 경고 |

## Firebase
Firebase initialized in `main.dart` wrapped in try/catch — runs without `google-services.json`. Provide the file for full Firestore/Auth functionality.

Firestore schema: `users/{uid}/sessions/{sid}` + `questionAnswers` subcollection.

## Verification Checklist (before each commit)
1. `flutter analyze` → No issues found
2. `flutter test` → 11/11 pass
3. No hardcoded API keys (`grep -r "sk-" lib/`)
4. No `withOpacity` calls (`grep -r "withOpacity" lib/`)
5. All routes in `app.dart` have corresponding screen files

## Feature Status — 완성 기능 목록
| 기능 | 상태 |
|---|---|
| 음성 녹음 + Whisper STT | ✅ |
| TTS 질문 자동 재생 | ✅ |
| Claude AI 피드백 (STAR + 모범답변) | ✅ |
| 꼬리 질문 생성 (페르소나 반영) | ✅ |
| 자소서 기반 맞춤 질문 | ✅ |
| 채용공고 기반 맞춤 질문 | ✅ |
| 4가지 페르소나 면접관 | ✅ |
| 연습 / 실전 모드 | ✅ |
| 말버릇 감지 + 발화 속도 분석 | ✅ |
| 로그인/회원가입 (Firebase + 로컬) | ✅ |
| 연속 학습 스트릭 (🔥 뱃지) | ✅ |
| 면접 기록 히스토리 + 점수 차트 | ✅ |
| 취약 영역 태그 분석 | ✅ |
| 결과 클립보드 공유 | ✅ |
| GitHub Actions CI (analyze→test→apk) | ✅ |
