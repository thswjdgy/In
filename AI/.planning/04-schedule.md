# InterviewAI — 개발 일정표 (10~16주차)

| 주차 | Phase | 목표 | 산출물 | 상태 |
|------|-------|------|--------|------|
| **10주차** | Phase 1 | 프로젝트 초기화 | Flutter 프로젝트, pubspec.yaml, 디렉토리 구조, 기획 문서 7개, ADR 3개 | ✅ |
| **11주차** | Phase 2 | 음성 파이프라인 | AudioRecorderService, WhisperClient, TtsService, InterviewScreen 기초 | ✅ |
| **12주차** | Phase 3 | AI 피드백 엔진 | FeedbackModel, ClaudeFeedbackClient, InterviewScreen 완성, FeedbackScreen, ResultScreen | ✅ |
| **13주차** | Phase 4 (1/2) | Firebase 인증 + 저장 | AuthRepository, LoginScreen, SessionRepository | ✅ |
| **14주차** | Phase 4 (2/2) | 히스토리 & 통계 UI | HistoryScreen (꺾은선 그래프 + 취약점 태그), SessionDetailScreen (레이더 차트) | ✅ |
| **15주차** | Phase 5 (1/2) | CI/CD + 테스트 | GitHub Actions build.yml, 단위 테스트 11개 통과 | ✅ |
| **16주차** | Phase 5 (2/2) | 문서 완비 + 발표 준비 | docs/ 4개 파일, README.md, presentation-outline.md | ✅ |

## 마일스톤

| 마일스톤 | 기준 | 상태 |
|----------|------|------|
| MVP 구조 확정 | `flutter run` + 기획 문서 완비 | ✅ 완료 |
| 중간 발표 데모 가능 | 면접 1세션 완전 동작 | ✅ 완료 |
| 기능 완성 | Firebase 히스토리 포함 전체 기능 | ✅ 완료 |
| 최종 제출 | APK + 문서 + GitHub 완비 | ✅ 완료 |

## 위험 요소 & 대응

| 위험 | 가능성 | 대응 | 결과 |
|------|--------|------|------|
| Whisper API 한국어 인식률 저하 | 중 | 3~5초 침묵 제거 전처리 추가 | 문제 없음 |
| Claude JSON 파싱 실패 | 중 | 3회 재시도 + fallback FeedbackModel | 구현 완료 |
| Firebase 설정 지연 | 낮 | google-services.json 없이도 앱 실행 가능하도록 분기 처리 | 구현 완료 |
| API 비용 초과 | 낮 | 세션당 질문 최대 10개, 개발 중 Mock 사용 | 문제 없음 |
| share_plus Windows 심링크 오류 | 낮 | Clipboard API로 대체 | 해결 완료 |
