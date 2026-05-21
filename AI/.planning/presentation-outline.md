# InterviewAI — 발표 개요 (7분)

## 1. 문제 제기 (1분)

취준생의 3가지 고통:
1. **혼자 연습하기 어렵다** — 면접 스터디 구성 어려움, 피드백 받을 상대 없음
2. **실전 환경 부재** — 긴장감 없는 텍스트 연습은 실전과 괴리가 큼
3. **내 약점을 모른다** — 어떤 부분이 부족한지, 무엇을 개선해야 하는지 불명확

---

## 2. 솔루션 소개 (1분)

> **"InterviewAI — AI 면접관과 실전처럼, 즉각적인 피드백으로 빠르게"**

- 음성으로 답변 → Whisper STT → Claude 피드백 → 점수 + 강점/약점
- 100+ 직종 지원: 개발자·간호사·공무원·디자이너 등 자유 입력
- 세션 기록 저장 → 점수 추이 그래프로 성장 확인

---

## 3. 라이브 데모 (3분)

**데모 시나리오:**
1. 앱 실행 → OnboardingScreen
2. 직종: "백엔드개발자" 입력, 직무 면접, 3문제 선택
3. "면접 시작" → InterviewScreen
4. 질문 TTS 재생 확인
5. "답변 시작" → 30초 답변 녹음
6. "답변 완료" → AI 분석 중 로딩 확인
7. FeedbackScreen → 점수 게이지 + 잘한점 + 보완할점
8. "다음 질문" 반복 후 ResultScreen → 평균 점수 확인
9. HistoryScreen → 세션 목록 + 점수 그래프

---

## 4. 기술 스택 & 아키텍처 (1분)

```
사용자 음성
  → flutter_sound (녹음)
  → OpenAI Whisper (STT)
  → Anthropic Claude claude-sonnet-4-6 (피드백 JSON)
  → FeedbackScreen

Firebase Auth + Firestore
  → 세션 저장 → HistoryScreen (fl_chart 그래프)
```

- **feature-first** 구조: `features/` + `core/` + `shared/`
- 상태관리: Riverpod 2.x (공유 상태) + StatefulWidget (로컬 상태)
- 라우팅: GoRouter (선언적, Extra 파라미터 타입 안전)

---

## 5. 개발 과정 & AI 활용 (1분)

**Claude Code로 한 것:**
- 기획 문서 (PRD, WBS, 일정표, ADR 3개) 초안 생성
- 아키텍처 설계 및 docs/ 문서화
- 코드 초안 작성 (AudioRecorderService, WhisperClient, ClaudeFeedbackClient)
- CLAUDE.md 작성 (deprecation 규칙, 코드 컨벤션)

**직접 한 것:**
- 코드 검증 및 수정
- UI 세부 디자인 조정
- 실기기 테스트 및 버그 수정
- Git 커밋 & PR 관리

---

## 6. Q&A 예상 질문 & 답변 (1분 준비)

**Q: Flutter를 선택한 이유?**  
A: iOS/Android 동시 지원이 필요한 2인 팀에서 단일 코드베이스가 최적. ADR-0001 참조.

**Q: 앱 구조는?**  
A: `features/(auth/interview/feedback/history/result)` + `core/` + `shared/` 의 feature-first 구조. `docs/architecture.md` 참조.

**Q: 개발 환경 설정은?**  
A: `docs/setup.md` 참조. `git clone` → `.env` 설정 → `flutter run` 3단계.

**Q: 빌드/배포는?**  
A: GitHub Actions. `push to main` 시 자동으로 `flutter analyze` → `test` → `build apk` 실행. `docs/deploy.md` 참조.

**Q: 테스트는?**  
A: `flutter test` 로 단위 테스트 실행. `ClaudeFeedbackClient` JSON 파싱, 세션 흐름 커버. `docs/testing.md` 참조.

**Q: AI가 만든 부분은?**  
A: 기획서·ADR·architecture.md·setup.md·WBS는 Claude Code로 생성. 코드는 Claude Code 초안 → 본인 검증·수정·커밋.
