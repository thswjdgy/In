# 테스트 가이드

## 테스트 실행

```bash
# 전체 테스트 실행
flutter test

# 특정 파일만 실행
flutter test test/core/api/claude_feedback_client_test.dart

# 커버리지 포함
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## 테스트 구조

```
test/
├── core/
│   └── api/
│       └── claude_feedback_client_test.dart  # JSON 파싱, fallback, 타임아웃
└── features/
    └── interview/
        └── use_cases/
            └── conduct_interview_use_case_test.dart  # 세션 흐름, STT 실패 처리
```

## 주요 테스트 시나리오

### ClaudeFeedbackClient

| 시나리오 | 기대 결과 |
|----------|----------|
| 정상 JSON 응답 파싱 | `FeedbackModel` 반환 (score 0~100 clamp) |
| 빈 문자열 응답 | `FeedbackModel.fallback()` 반환 |
| JSON 파싱 실패 3회 | `FeedbackParseException` throw |
| 타임아웃 (15초 초과) | `NetworkException` throw |

### InterviewScreen (통합)

| 시나리오 | 기대 결과 |
|----------|----------|
| 정상 세션 흐름 (질문 → 녹음 → STT → 피드백) | FeedbackScreen으로 이동 |
| 마이크 권한 거부 | `PermissionDeniedException` → 에러 메시지 표시 |
| STT 변환 실패 | 에러 메시지 → 재시도 가능 |
| 마지막 질문 완료 | ResultScreen으로 이동 |

## Mock 사용법

```dart
// Mock AudioRecorderService 예시
class MockAudioRecorderService extends Mock implements AudioRecorderService {}

setUp(() {
  mockRecorder = MockAudioRecorderService();
  when(() => mockRecorder.startRecording()).thenAnswer((_) async {});
  when(() => mockRecorder.stopRecording())
      .thenAnswer((_) async => '/tmp/test.m4a');
});
```

## flutter analyze

코드 커밋 전 반드시 실행:

```bash
flutter analyze
# 출력: "No issues found!" 이어야 함
```

### 금지 패턴 (CLAUDE.md 기준)

```bash
# 하드코딩된 API 키 체크
grep -r "sk-" lib/

# deprecated Color.withOpacity 체크
grep -r "withOpacity" lib/

# deprecated MaterialStateProperty 체크
grep -r "MaterialStateProperty" lib/
```
