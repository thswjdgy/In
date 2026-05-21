# InterviewAI — Claude Code 단계별 부트스트랩 프롬프트

**용도:** 각 개발 단계 시작 시 Claude Code에 붙여넣기  
**프로젝트:** InterviewAI (Flutter + Whisper + Claude API)  
**팀:** 2인 | **기간:** 10~16주차

> **사용법:** 각 단계 프롬프트를 Claude Code 새 대화에 통째로 붙여넣는다.  
> 단계 내 작업이 끝나면 "검증 체크리스트"를 직접 확인한 뒤 다음 단계로 넘어간다.

---

## PHASE 1 — 프로젝트 초기화 & 문서 구조 구축
> **10주차 | 목표: `flutter run` 정상 동작 + 기획 문서 완비**

```
당신은 InterviewAI Flutter 프로젝트의 AI 에이전트입니다.
아래 지시를 순서대로 실행하고, 각 단계 완료 시 결과를 보고하세요.

=== 프로젝트 컨텍스트 ===
- 앱 이름: InterviewAI
- 설명: 음성 기반 AI 면접 시뮬레이션 앱
- 플랫폼: Flutter (iOS 14+ / Android 8+)
- 상태관리: Riverpod 2.x
- 백엔드: Firebase (Auth + Firestore)
- AI: OpenAI Whisper API (STT) + Anthropic Claude claude-sonnet-4-6 (피드백)

=== 실행 지시 ===

[1단계] Flutter 프로젝트 생성
- 패키지명: com.interviewai.app
- 아래 pubspec.yaml 의존성을 추가하세요:
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  flutter_sound: ^9.2.13
  flutter_tts: ^4.0.2
  firebase_core: ^3.6.0
  firebase_auth: ^5.3.1
  cloud_firestore: ^5.4.4
  google_sign_in: ^6.2.1
  http: ^1.2.2
  dio: ^5.7.0
  fl_chart: ^0.69.0
  go_router: ^14.3.0
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0
  envied: ^0.5.4+1
  dev_dependencies에 추가:
  build_runner: ^2.4.13
  freezed: ^2.5.2
  json_serializable: ^6.8.0
  riverpod_generator: ^2.4.3
  envied_generator: ^0.5.4+1

[2단계] 디렉토리 구조 생성
lib/ 아래 다음 폴더를 생성하세요 (빈 .gitkeep 포함):
  features/auth/screens/
  features/auth/providers/
  features/auth/repositories/
  features/interview/screens/
  features/interview/providers/
  features/interview/use_cases/
  features/interview/repositories/
  features/feedback/screens/
  features/feedback/models/
  features/feedback/providers/
  features/history/screens/
  features/history/providers/
  features/history/repositories/
  core/api/
  core/services/
  core/errors/
  shared/widgets/
  shared/theme/
  shared/constants/

[3단계] 환경 변수 설정
- .env.example 파일을 프로젝트 루트에 생성:
  OPENAI_API_KEY=sk-여기에_키_입력
  ANTHROPIC_API_KEY=sk-ant-여기에_키_입력
  FIREBASE_PROJECT_ID=interviewai-여기에_프로젝트_ID
- lib/core/env.dart 파일을 envied 패턴으로 생성 (실제 값은 .env에서 로드)
- .gitignore에 .env 추가 확인

[4단계] 기획 문서 생성
다음 파일들을 .planning/ 폴더에 생성하세요:

파일: .planning/00-vision.md
내용: InterviewAI의 비전, 문제 정의, 한 줄 가치 제안

파일: .planning/01-requirements.md
내용: MoSCoW 요구사항 전체 표 (Must 8개, Should 4개, Could 2개, Won't 3개)

파일: .planning/02-wbs.md
내용: 5개 Phase를 3단계 깊이로 분해한 WBS 표

파일: .planning/04-schedule.md
내용: 10~16주차 개발 일정표 (목표/산출물/검증 방법 포함)

파일: .planning/decisions/ADR-0001-flutter.md
내용: Flutter 선택 이유 (배경/결정/대안/결과 형식)

파일: .planning/decisions/ADR-0002-riverpod.md
내용: Riverpod 상태관리 선택 이유

파일: .planning/decisions/ADR-0003-firebase.md
내용: Firebase 백엔드 선택 이유 (Supabase, 자체 서버 대안 비교)

파일: BONUS.md
내용: 가산점 항목별 진행 상황 추적 체크리스트

파일: AGENTS.md
내용: 이 프로젝트에서 Claude Code를 활용하는 방식, 커밋 컨벤션, 프롬프트 패턴 기록

[5단계] Hello World 화면
- lib/main.dart: Firebase 초기화 + ProviderScope 래핑
- lib/app.dart: GoRouter 기본 설정 (home → /onboarding)
- lib/features/auth/screens/onboarding_screen.dart: "InterviewAI" 텍스트 + 시작하기 버튼
- flutter run으로 빌드 성공 확인

=== 완료 조건 ===
□ flutter run 에러 없이 실행됨
□ .planning/ 문서 7개 생성됨
□ ADR 3개 생성됨
□ BONUS.md, AGENTS.md 생성됨
□ .env.example 루트에 존재함
□ .gitignore에 .env 포함됨
```

---

## PHASE 2 — 음성 파이프라인 구축 (STT)
> **11주차 | 목표: 실기기에서 한국어 녹음 → 텍스트 변환 성공**

```
당신은 InterviewAI의 음성 파이프라인을 구축하는 AI 에이전트입니다.
Phase 1이 완료된 상태에서 시작합니다.

=== 현재 상태 ===
- Flutter 프로젝트 + 디렉토리 구조 완비
- Firebase 연결됨
- Riverpod, flutter_sound, flutter_tts 의존성 설치됨

=== 실행 지시 ===

[1단계] 권한 설정
- android/app/src/main/AndroidManifest.xml에 추가:
  RECORD_AUDIO, INTERNET 권한
- ios/Runner/Info.plist에 추가:
  NSMicrophoneUsageDescription: "면접 답변 녹음을 위해 마이크 접근이 필요합니다"

[2단계] 녹음 서비스 구현
파일: lib/core/services/audio_recorder_service.dart
- flutter_sound의 FlutterSoundRecorder 래핑
- startRecording(): 마이크 입력 시작, .m4a 포맷으로 임시 파일 저장
- stopRecording(): 녹음 중지, 파일 경로 반환
- 최대 녹음 시간: 3분 (180초) 타이머 내장
- 권한 없으면 PermissionDeniedException throw

[3단계] Whisper API 클라이언트 구현
파일: lib/core/api/whisper_client.dart
- transcribe(String audioFilePath) → Future<String>
- multipart/form-data로 .m4a 파일 전송
- model: "whisper-1", language: "ko"
- 응답에서 text 필드 추출
- 타임아웃: 15초
- 실패 시 WhisperException throw (에러 코드 포함)

[4단계] STT Provider 구현
파일: lib/features/interview/providers/stt_provider.dart
- Riverpod AsyncNotifier 패턴 사용
- 상태: idle / recording / transcribing / done / error
- startRecording() / stopAndTranscribe() 메서드
- 녹음 경과 시간 스트림 (초 단위)

[5단계] 녹음 테스트 화면 구현
파일: lib/features/interview/screens/audio_test_screen.dart
- 마이크 아이콘 버튼 (누르면 녹음 시작, 다시 누르면 중지)
- 녹음 중 경과 시간 표시 (00:00 형식)
- 변환 중 로딩 스피너
- 변환 완료 시 텍스트 화면에 출력
- 에러 시 SnackBar로 메시지 표시

[6단계] TTS 서비스 구현
파일: lib/core/services/tts_service.dart
- flutter_tts 래핑
- speak(String text): 한국어 음성 재생 (언어: ko-KR, 속도: 0.9)
- stop(): 재생 중지
- 재생 중 상태 스트림 제공

=== 완료 조건 ===
□ 실기기(또는 에뮬레이터)에서 녹음 버튼 작동
□ 30초 한국어 답변 녹음 후 텍스트 변환 성공
□ 변환된 텍스트가 화면에 출력됨
□ 마이크 권한 거부 시 적절한 에러 메시지 표시
□ TTS로 텍스트 읽기 작동 확인

=== 주의사항 ===
- API 키는 반드시 env.dart에서 로드, 코드에 직접 하드코딩 금지
- 오디오 파일은 임시 디렉토리 사용, 변환 완료 후 삭제
- Whisper API 응답이 빈 문자열일 경우 "답변을 인식하지 못했습니다" fallback
```

---

## PHASE 3 — AI 피드백 엔진 + 면접 세션 핵심 로직
> **12주차 | 목표: 질문 → 녹음 → STT → Claude 피드백까지 완전한 파이프라인**

```
당신은 InterviewAI의 AI 피드백 엔진을 구현하는 AI 에이전트입니다.
Phase 2 완료 상태 (녹음 + STT 작동) 에서 시작합니다.

=== 실행 지시 ===

[1단계] 피드백 데이터 모델 정의
파일: lib/features/feedback/models/feedback_model.dart
- freezed + json_serializable 사용
- 필드:
  String id
  int score (0~100)
  List<String> strengths (잘한 점, 최대 3개)
  List<String> improvements (보완할 점, 최대 3개)
  String summary (한 줄 요약)
  DateTime createdAt

파일: lib/features/interview/models/interview_session_model.dart
- String sessionId
- String jobCategory (backend_dev / frontend_dev / pm / designer)
- String interviewType (technical / personality)
- List<QuestionAnswer> questionAnswers
- FeedbackModel? aggregateFeedback
- DateTime startedAt / endedAt

파일: lib/features/interview/models/question_answer_model.dart
- String question
- String userAnswer (Whisper 변환 텍스트)
- FeedbackModel feedback
- int durationSeconds (답변 시간)

[2단계] 질문 데이터 구축
파일: lib/shared/constants/question_bank.dart
- 직군별 질문 Map<String, List<String>> 구조:
  backend_dev: 기술 15개 + 인성 10개
  frontend_dev: 기술 15개 + 인성 10개
  pm: 기술 10개 + 인성 10개
  designer: 기술 10개 + 인성 10개
- getRandomQuestions(category, type, count): 중복 없이 랜덤 추출

[3단계] Claude 피드백 클라이언트 구현
파일: lib/core/api/claude_feedback_client.dart
- getFeedback({
    required String question,
    required String answer,
    required String jobCategory,
  }) → Future<FeedbackModel>
- 시스템 프롬프트:
  "당신은 [직군] 분야의 시니어 면접관입니다.
   답변을 STAR 구조, 구체성, 논리성, 직군 적합성 기준으로 평가하세요.
   반드시 아래 JSON 형식으로만 응답하세요:
   {\"score\": 정수, \"strengths\": [\"...\"], \"improvements\": [\"...\"], \"summary\": \"...\"}"
- 모델: claude-sonnet-4-6
- max_tokens: 500
- JSON 파싱 실패 시 3회 재시도
- 파싱 완전 실패 시 FeedbackParseException throw + fallback FeedbackModel 반환

[4단계] 면접 세션 UseCase 구현
파일: lib/features/interview/use_cases/conduct_interview_use_case.dart
- 의존성: AudioRecorderService, WhisperClient, ClaudeFeedbackClient, TtsService
- startSession(category, type, questionCount): 세션 초기화
- readNextQuestion(): TTS로 다음 질문 읽기
- startAnswerRecording(): 녹음 시작
- stopAndEvaluate(): 녹음 중지 → STT → Claude 피드백 → 결과 반환
- endSession(): 세션 완료, 결과 집계

[5단계] 면접 진행 화면 구현
파일: lib/features/interview/screens/interview_screen.dart
레이아웃:
  상단: 진행 상황 (질문 n/5)
  중앙: 질문 텍스트 카드
  중하단: 파형 애니메이션 (녹음 중에만 표시)
  하단: 상태별 버튼
    - 대기 중: "답변 시작" 버튼 (마이크 아이콘)
    - 녹음 중: "답변 완료" 버튼 (빨간 정지 아이콘) + 경과 시간
    - 처리 중: 로딩 인디케이터 + "AI가 분석 중..."
  각 질문 사이: TTS 자동 재생

[6단계] 피드백 화면 구현
파일: lib/features/feedback/screens/feedback_screen.dart
레이아웃:
  상단: 점수 게이지 (0~100, 애니메이션)
  중단: "잘한 점" 카드 (초록) + "보완할 점" 카드 (주황)
  하단: 한 줄 요약 + "다음 질문" 또는 "세션 완료" 버튼

=== 완료 조건 ===
□ 직군·유형 선택 → 질문 TTS 재생 → 녹음 → 피드백 화면까지 1회 완전 동작
□ Claude 응답 JSON 파싱 성공률 5/5 (테스트 5회)
□ 피드백 화면에 점수·잘한점·보완점 모두 표시
□ JSON 파싱 실패 시 fallback 메시지 표시됨
□ 중간 발표 데모 시나리오로 사용 가능한 수준

=== 주의사항 ===
- Claude 응답을 강제 JSON으로 받으려면 system 프롬프트에 "JSON 형식으로만" 명시 필수
- 피드백 생성 중 화면이 멈춰 보이면 안 됨 (항상 로딩 상태 표시)
- 질문 5개 초과 금지 (API 비용 제한)
```

---

## PHASE 4 — 세션 저장 + 히스토리 & 통계 UI
> **13~14주차 | 목표: 반복 사용 시 성장을 확인할 수 있는 상태**

```
당신은 InterviewAI의 데이터 저장 및 히스토리 기능을 구현하는 AI 에이전트입니다.
Phase 3 완료 상태 (면접 세션 + 피드백 작동) 에서 시작합니다.

=== 실행 지시 ===

[1단계] Firebase 인증 구현
파일: lib/features/auth/repositories/auth_repository.dart
- signInWithGoogle(): Google OAuth
- signInWithEmail(email, password): 이메일 로그인
- signUp(email, password): 회원가입
- signOut(): 로그아웃
- currentUser: User? 스트림

파일: lib/features/auth/screens/login_screen.dart
- Google 로그인 버튼
- 이메일/비밀번호 입력 + 로그인 버튼
- 회원가입 링크

[2단계] Firestore 데이터 구조 설계
컬렉션 구조를 다음과 같이 구현하세요:
  users/{userId}/
    sessions/{sessionId}/
      - sessionId: String
      - jobCategory: String
      - interviewType: String
      - totalScore: int
      - questionCount: int
      - weakAreas: List<String>
      - startedAt: Timestamp
      - endedAt: Timestamp
      questionAnswers/{answerId}/
        - question: String
        - userAnswer: String
        - score: int
        - strengths: List<String>
        - improvements: List<String>
        - summary: String

[3단계] 세션 저장 Repository 구현
파일: lib/features/interview/repositories/session_repository.dart
- saveSession(InterviewSessionModel session) → Future<String> (세션ID 반환)
- getSessions(String userId) → Stream<List<SessionSummary>>
- getSessionDetail(String sessionId) → Future<InterviewSessionModel>

[4단계] 히스토리 화면 구현
파일: lib/features/history/screens/history_screen.dart
레이아웃:
  상단 카드: 총 세션 수, 평균 점수, 최고 점수
  중단: 점수 추이 꺾은선 그래프 (fl_chart LineChart)
    - x축: 날짜, y축: 점수 (0~100)
    - 최근 10회 세션
  하단: 취약 영역 태그 목록
    - improvements 텍스트에서 빈도 높은 키워드 추출
    - 태그 칩 형태로 표시 (예: #논리성 #구체적사례)
  세션 목록: ListView
    - 날짜, 직군, 점수, 화살표 → 상세 화면 이동

[5단계] 세션 상세 화면
파일: lib/features/history/screens/session_detail_screen.dart
- 레이더 차트 (fl_chart RadarChart): STAR·구체성·논리성·직군적합·발음 5축
  → 각 축 점수는 Claude 피드백 파싱 시 항목별로 추출
- 질문별 답변 + 피드백 카드 목록
- "다시 연습하기" 버튼 (같은 직군/유형으로 새 세션 시작)

[6단계] 온보딩 + 직군 설정 화면 구현
파일: lib/features/interview/screens/onboarding_screen.dart
- 직군 선택: 백엔드 개발자 / 프론트엔드 개발자 / 기획자 / 디자이너 (카드형 선택)
- 면접 유형: 기술 면접 / 인성 면접 (토글)
- 질문 수: 3문제 / 5문제 (세그먼트)
- "면접 시작" 버튼 → 면접 화면으로 이동

=== 완료 조건 ===
□ Google 로그인 후 세션 저장됨
□ 앱 재시작 후 히스토리 화면에서 이전 세션 목록 확인 가능
□ 점수 꺾은선 그래프가 실제 데이터로 렌더링됨
□ 취약 영역 태그가 피드백 텍스트에서 자동 추출됨
□ 레이더 차트가 5개 항목으로 표시됨
```

---

## PHASE 5 — 마감 & 배포 & 문서 완비
> **15~16주차 | 목표: GitHub Actions 자동 빌드 + 발표 준비 완료**

```
당신은 InterviewAI의 배포 및 문서화를 담당하는 AI 에이전트입니다.
Phase 4 완료 상태 (전체 기능 작동) 에서 시작합니다.

=== 실행 지시 ===

[1단계] CI/CD 파이프라인 구축
파일: .github/workflows/build.yml
- trigger: push to main, PR to main
- jobs:
  analyze: flutter analyze (lint 검사)
  test: flutter test (단위 테스트)
  build-android: flutter build apk --release
    → 빌드 아티팩트 GitHub Release에 업로드
- 환경변수: GitHub Secrets에서 OPENAI_API_KEY, ANTHROPIC_API_KEY 주입

[2단계] 단위 테스트 작성
파일: test/core/api/claude_feedback_client_test.dart
- 정상 JSON 응답 파싱 테스트
- 빈 응답 fallback 테스트
- 타임아웃 에러 테스트

파일: test/features/interview/use_cases/conduct_interview_use_case_test.dart
- Mock AudioRecorderService, WhisperClient, ClaudeFeedbackClient 사용
- 정상 세션 흐름 테스트
- STT 실패 시 에러 처리 테스트

[3단계] 문서 완비
파일: docs/setup.md
내용 (새 기기에서 5분 안에 실행 가능하도록):
  1. 필요 도구 버전 (Flutter 3.x, Dart 3.x, JDK 17)
  2. git clone 명령
  3. flutter pub get
  4. .env 설정 방법 (.env.example → .env 복사)
  5. Firebase 프로젝트 연결 (google-services.json 위치)
  6. flutter run 실행
  7. 문제 해결 FAQ 5개 (권한 오류, Firebase 연결 실패 등)

파일: docs/architecture.md
내용:
  - 시스템 구성도 (Mermaid 다이어그램)
  - 레이어 구조 설명 (features / core / shared)
  - 핵심 데이터 흐름 시퀀스 다이어그램
  - 상태관리 패턴 설명 (Riverpod AsyncNotifier)

파일: docs/deploy.md
내용:
  - Android APK 빌드 명령
  - GitHub Actions 트리거 방법
  - Secrets 설정 목록

파일: docs/testing.md
내용:
  - 테스트 실행 명령 (flutter test)
  - 테스트 커버리지 확인 방법
  - 주요 테스트 시나리오 목록

파일: README.md
내용:
  - 프로젝트 한 줄 소개
  - 주요 기능 스크린샷 (또는 GIF)
  - 빠른 시작 (setup.md 링크)
  - 기술 스택 뱃지
  - 라이선스

[4단계] 발표 자료 준비 지원
파일: .planning/presentation-outline.md
다음 구조로 발표 개요 작성:
  1. 문제 제기 (1분): 취준생의 3가지 고통
  2. 솔루션 소개 (1분): InterviewAI 한 줄 가치 제안
  3. 라이브 데모 (3분): 온보딩 → 질문 TTS → 녹음 → 피드백 확인
  4. 기술 스택 & 아키텍처 (1분): 레이어 구조 + 데이터 흐름
  5. 개발 과정 & AI 활용 (1분): Claude Code로 무엇을 했나
  6. Q&A 예상 질문 & 답변 (1분 준비):
     - Flutter 선택 이유? → ADR-0001
     - 앱 구조? → features 레이어 + Riverpod
     - 개발 환경 설정? → docs/setup.md
     - 빌드/배포? → GitHub Actions
     - 테스트? → flutter test + 단위 테스트

[5단계] 최종 점검
다음 항목을 자동으로 확인하고 결과를 표로 출력하세요:
- .planning/ 파일 목록 및 존재 여부
- docs/ 파일 목록 및 존재 여부
- ADR 파일 수
- README.md 존재 여부
- AGENTS.md 존재 여부
- BONUS.md 존재 여부
- .github/workflows/build.yml 존재 여부
- test/ 파일 수

=== 완료 조건 ===
□ GitHub Actions 빌드 성공 (초록불)
□ APK 파일 생성 및 설치 가능
□ docs/ 4개 파일 모두 작성됨
□ README.md에 스크린샷 또는 데모 GIF 포함
□ flutter test 전체 통과
□ 발표 7분 리허설 완료
□ 문서 완성도 +5점 체크리스트 모두 충족

=== 발표 Q&A 대비 핵심 답변 ===
Q: 사용한 플랫폼은?
A: Flutter 3.x. 1인(또는 2인) 개발로 iOS/Android 동시 지원이 필요해 단일 코드베이스 선택.

Q: 앱 구조는?
A: features(auth/interview/feedback/history) + core(api/services) + shared(widgets/theme).
   슬라이드 4레이어와 다른 feature-first 구조는 ADR-0004에 근거 기록됨.

Q: 개발 환경 설정은?
A: docs/setup.md 참조. git clone → .env 설정 → flutter run 3단계.

Q: 빌드/배포는?
A: GitHub Actions. push to main 시 자동으로 flutter analyze → test → build apk 실행.

Q: 테스트는?
A: flutter test로 단위 테스트 실행. ClaudeFeedbackClient, ConductInterviewUseCase 핵심 로직 커버.

Q: AI가 만든 부분은?
A: 기획서·PRD·ADR·architecture.md·setup.md·WBS는 Claude Code로 생성.
   코드는 Claude Code가 초안 작성, 본인이 검증·수정·커밋.
```

---

## 사용 팁

### 프롬프트 재사용 패턴
각 Phase 안에서 막히는 부분이 있으면 아래를 추가로 붙여넣으세요:

```
위 [N단계] 구현 중 [구체적 문제] 가 발생했습니다.
현재 에러: [에러 메시지 붙여넣기]
관련 파일: [파일명]
어떻게 수정해야 하나요? 수정된 코드 전체를 보여주세요.
```

### 커밋 컨벤션
```
feat: [기능명] 구현
fix: [버그명] 수정
docs: [문서명] 작성
refactor: [대상] 리팩토링
test: [테스트명] 추가
chore: 의존성 업데이트 / 설정 변경
```

### LLM Wiki 기록 권장 항목
Phase 진행하며 발견한 노하우를 `llm-wiki/` 폴더에 기록:
- 잘 작동한 Claude 프롬프트 패턴
- JSON 강제 응답에서 실패한 케이스 & 해결법
- Riverpod + flutter_sound 조합 주의사항
- Whisper API 한국어 인식률 향상 팁
