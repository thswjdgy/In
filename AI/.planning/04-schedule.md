# InterviewAI — 개발 일정표 (10~16주차)

| 주차 | Phase | 목표 | 산출물 | 검증 방법 |
|------|-------|------|--------|----------|
| **10주차** | Phase 1 | 프로젝트 초기화 | Flutter 프로젝트, pubspec.yaml, 디렉토리 구조, 기획 문서 7개, ADR 3개 | `flutter run` 에러 없이 실행 |
| **11주차** | Phase 2 | 음성 파이프라인 | AudioRecorderService, WhisperClient, TtsService, InterviewScreen 기초 | 실기기에서 한국어 STT 성공 |
| **12주차** | Phase 3 | AI 피드백 엔진 | FeedbackModel, ClaudeFeedbackClient, InterviewScreen 완성, FeedbackScreen, ResultScreen | 질문→녹음→피드백 파이프라인 1회 완전 동작 |
| **13주차** | Phase 4 (1/2) | Firebase 인증 + 저장 | AuthRepository, LoginScreen, SessionRepository | Google 로그인 + Firestore 세션 저장 성공 |
| **14주차** | Phase 4 (2/2) | 히스토리 & 통계 UI | HistoryScreen (그래프), SessionDetailScreen | 꺾은선 그래프 실데이터 렌더링 |
| **15주차** | Phase 5 (1/2) | CI/CD + 테스트 | GitHub Actions build.yml, 단위 테스트 2종 | GitHub Actions 초록불, `flutter test` 전체 통과 |
| **16주차** | Phase 5 (2/2) | 문서 완비 + 발표 준비 | docs/ 4개 파일, README.md, presentation-outline.md | 발표 7분 리허설 완료 |

## 마일스톤

| 날짜 | 마일스톤 | 기준 |
|------|----------|------|
| 10주차 말 | MVP 구조 확정 | `flutter run` + 기획 문서 완비 |
| 12주차 말 | 중간 발표 데모 가능 | 면접 1세션 완전 동작 |
| 14주차 말 | 기능 완성 | Firebase 히스토리 포함 전체 기능 |
| 16주차 말 | 최종 제출 | APK + 문서 + GitHub 완비 |

## 위험 요소 & 대응

| 위험 | 가능성 | 대응 |
|------|--------|------|
| Whisper API 한국어 인식률 저하 | 중 | 3~5초 침묵 제거 전처리 추가 |
| Claude JSON 파싱 실패 | 중 | 3회 재시도 + fallback FeedbackModel |
| Firebase 설정 지연 | 낮 | google-services.json 없이도 앱 실행 가능하도록 분기 처리 |
| API 비용 초과 | 낮 | 세션당 질문 최대 10개, 개발 중 Mock 사용 |
