# InterviewAI

[![Flutter](https://img.shields.io/badge/Flutter-3.41.4-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.11.1-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

> AI 면접관과 실전처럼 연습하고, 즉각적인 피드백으로 빠르게 성장하는 음성 기반 면접 시뮬레이션 앱

## 주요 기능

| 기능 | 설명 |
|------|------|
| 🎙️ 음성 녹음 + STT | flutter_sound로 녹음 → OpenAI Whisper로 한국어 변환 |
| 🤖 AI 피드백 | Anthropic Claude가 STAR 구조 기준으로 점수 + 강점/약점 분석 |
| 🗣️ 질문 TTS 자동 재생 | flutter_tts로 면접관처럼 질문 읽기 |
| 🏢 100+ 직종 지원 | 간호사·개발자·공무원 등 자유 입력 + 자동완성 |
| 📊 세션 결과 요약 | 질문별 점수·잘한점·보완점 ExpansionTile |
| 📅 면접 히스토리 | Firebase 연동 시 점수 추이 그래프 + 취약 영역 태그 |

## 스크린샷

| 홈 화면 | 면접 진행 | AI 피드백 | 전체 결과 |
|---------|----------|----------|----------|
| 직종 입력 + 유형/문제 수 선택<br>🔥 연속 학습 뱃지 | TTS 질문 → 음성 녹음<br>경과 시간 + 펄스 애니메이션 | 원형 점수 게이지<br>강점/보완점 + STAR 힌트 | 평균 점수 요약<br>문항별 ExpansionTile |

| 로그인 | 면접 히스토리 | 세션 상세 | 비밀번호 재설정 |
|--------|------------|----------|---------------|
| Google/이메일 탭 UI<br>회원가입 + 비밀번호 찾기 | 꺾은선 그래프<br>취약 영역 태그 | 5축 레이더 차트<br>답변별 피드백 카드 | 이메일 입력 → 재설정 링크 |

> 실제 스크린샷은 `google-services.json` 설정 후 `flutter run`으로 확인하세요.

## 빠른 시작

```bash
git clone https://github.com/thswjdgy/interviewai.git
cd interviewai
flutter pub get
flutter run \
  --dart-define=OPENAI_API_KEY=sk-... \
  --dart-define=ANTHROPIC_API_KEY=sk-ant-...
```

자세한 설정 방법 → [docs/setup.md](docs/setup.md)

## 기술 스택

| 분류 | 사용 기술 |
|------|----------|
| 프레임워크 | Flutter 3.41 / Dart 3.11 |
| 상태관리 | Riverpod 2.x |
| 라우팅 | GoRouter 15 |
| 음성 녹음 | flutter_sound |
| TTS | flutter_tts |
| STT | OpenAI Whisper API |
| AI 피드백 | Anthropic Claude claude-sonnet-4-6 |
| 백엔드 | Firebase Auth + Cloud Firestore |
| 차트 | fl_chart |

## 문서

- [환경 설정](docs/setup.md) — 신규 개발자 온보딩
- [아키텍처](docs/architecture.md) — 시스템 구성도 + 데이터 흐름
- [빌드/배포](docs/deploy.md) — APK 빌드 + GitHub Actions
- [테스트](docs/testing.md) — 테스트 실행 + 시나리오

## 프로젝트 구조

```
lib/
├── core/         # API 클라이언트, 서비스, 에러
├── features/     # 기능별 모듈 (auth/interview/feedback/history/result)
└── shared/       # 공용 테마, 질문 뱅크
```

→ 상세 구조: [docs/architecture.md](docs/architecture.md)

## License

MIT
