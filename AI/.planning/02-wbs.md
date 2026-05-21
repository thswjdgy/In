# InterviewAI — WBS (Work Breakdown Structure)

## Phase 1 — 프로젝트 초기화 & 문서 구조 구축 (10주차)

| 1단계 | 2단계 | 3단계 |
|-------|-------|-------|
| 1.1 환경 구축 | 1.1.1 Flutter 프로젝트 생성 | pubspec.yaml 의존성 설정 |
| | 1.1.2 디렉토리 구조 생성 | features / core / shared 폴더 |
| | 1.1.3 환경 변수 설정 | .env.example, env.dart |
| 1.2 기획 문서 | 1.2.1 비전 문서 | 00-vision.md |
| | 1.2.2 요구사항 | 01-requirements.md (MoSCoW) |
| | 1.2.3 WBS | 02-wbs.md |
| | 1.2.4 일정표 | 04-schedule.md |
| | 1.2.5 ADR 작성 | ADR-0001, 0002, 0003 |
| 1.3 헬로월드 | 1.3.1 main.dart | ProviderScope 래핑 |
| | 1.3.2 app.dart | GoRouter 기본 설정 |
| | 1.3.3 OnboardingScreen | 직종/유형/개수 선택 UI |

## Phase 2 — 음성 파이프라인 구축 (11주차)

| 1단계 | 2단계 | 3단계 |
|-------|-------|-------|
| 2.1 권한 | 2.1.1 Android 권한 | RECORD_AUDIO, INTERNET |
| | 2.1.2 iOS 권한 | NSMicrophoneUsageDescription |
| 2.2 녹음 | 2.2.1 AudioRecorderService | flutter_sound 래핑, .m4a 저장 |
| | 2.2.2 최대 녹음 시간 | 3분 타이머 |
| 2.3 STT | 2.3.1 WhisperClient | multipart 전송, ko 언어 설정 |
| | 2.3.2 에러 처리 | WhisperException, timeout |
| 2.4 TTS | 2.4.1 TtsService | flutter_tts 래핑, 속도 0.9 |

## Phase 3 — AI 피드백 엔진 + 면접 세션 (12주차)

| 1단계 | 2단계 | 3단계 |
|-------|-------|-------|
| 3.1 데이터 모델 | 3.1.1 FeedbackModel | freezed, score/strengths/improvements |
| | 3.1.2 QuestionBank | 직군별 질문, shuffle |
| 3.2 AI 클라이언트 | 3.2.1 ClaudeFeedbackClient | JSON 응답, 3회 재시도 |
| | 3.2.2 fallback 처리 | FeedbackParseException |
| 3.3 화면 | 3.3.1 InterviewScreen | 녹음 → STT → 피드백 파이프라인 |
| | 3.3.2 FeedbackScreen | 점수 게이지 + 강점/약점 카드 |
| | 3.3.3 ResultScreen | 전체 결과 + 질문별 ExpansionTile |

## Phase 4 — 세션 저장 + 히스토리 (13~14주차)

| 1단계 | 2단계 | 3단계 |
|-------|-------|-------|
| 4.1 인증 | 4.1.1 AuthRepository | Google + 이메일 로그인 |
| | 4.1.2 LoginScreen | 로그인 UI |
| 4.2 Firestore | 4.2.1 데이터 구조 설계 | users/{uid}/sessions/{sid} |
| | 4.2.2 SessionRepository | 저장/조회 CRUD |
| 4.3 히스토리 | 4.3.1 HistoryScreen | 그래프 + 세션 목록 |
| | 4.3.2 SessionDetailScreen | 레이더 차트 + 답변 카드 |

## Phase 5 — 배포 & 문서 완비 (15~16주차)

| 1단계 | 2단계 | 3단계 |
|-------|-------|-------|
| 5.1 CI/CD | 5.1.1 GitHub Actions | analyze → test → build APK |
| | 5.1.2 Secrets 설정 | OPENAI_API_KEY, ANTHROPIC_API_KEY |
| 5.2 테스트 | 5.2.1 ClaudeFeedbackClient 테스트 | JSON 파싱, 타임아웃 |
| | 5.2.2 UseCase 테스트 | Mock 서비스 사용 |
| 5.3 문서 | 5.3.1 docs/setup.md | 신규 개발자 5분 셋업 |
| | 5.3.2 docs/architecture.md | Mermaid 다이어그램 |
| | 5.3.3 docs/deploy.md | APK 빌드 방법 |
| | 5.3.4 docs/testing.md | 테스트 실행 방법 |
| 5.4 마무리 | 5.4.1 README.md | 뱃지 + 기능 소개 |
| | 5.4.2 발표 개요 | presentation-outline.md |
