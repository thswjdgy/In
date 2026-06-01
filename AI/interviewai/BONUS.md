# InterviewAI — Bonus Features & Course Requirements

## Course Requirement Checklist

### Week 5 — CLAUDE.md & Custom Commands
- [x] `CLAUDE.md` — project guidelines, API key rules, verification checklist
- [x] `.claude/commands/interview-validate.md` — validate question bank quality
- [x] `.claude/commands/interview-add.md` — add new questions via slash command

### Week 6 — Vibe Coding Project (PRD & Prompts)
- [x] PRD defined (5W1H, 2-person team, 10–16주차 roadmap)
- [x] Bootstrap prompts (`resources/05-bootstrap-prompt.md`)
- [x] Feature-first Flutter architecture with Riverpod + GoRouter
- [x] Voice interview loop: TTS → record → Whisper STT → Claude feedback

### Week 7 — Sub-Agents & MCP
- [x] `AGENTS.md` — 3 sub-agents defined (code-bug-analyzer, performance-optimizer, ux-design-advisor)
- [x] MCP: Notion MCP server — `.claude/mcp_config.json`
- [x] MCP: Sequential Thinking MCP server — `.claude/mcp_config.json`
- [x] MCP: Context7 MCP server (Flutter/Dart docs) — `.claude/mcp_config.json`

## MCP Setup Instructions

### Notion MCP
```json
{
  "mcpServers": {
    "notion": {
      "command": "npx",
      "args": ["-y", "@notionhq/notion-mcp-server"],
      "env": {
        "OPENAPI_MCP_HEADERS": "{\"Authorization\": \"Bearer YOUR_NOTION_TOKEN\", \"Notion-Version\": \"2022-06-28\"}"
      }
    }
  }
}
```
Add to: `%APPDATA%\Claude\claude_desktop_config.json` (Claude Desktop)  
or: `.claude/mcp_config.json` (project-level)

### Sequential Thinking MCP
```json
{
  "mcpServers": {
    "sequential-thinking": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"]
    }
  }
}
```

### Context7 MCP (Flutter docs)
```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp"]
    }
  }
}
```

## Implemented Features

### 핵심 인터뷰 파이프라인
- [x] 음성 녹음 + Whisper STT (한국어, m4a)
- [x] TTS 질문 자동 재생 (flutter_tts, 0.9x 속도)
- [x] 녹음 중 펄스 애니메이션 + 경과 시간
- [x] 진행 상황 LinearProgressIndicator

### AI 질문 생성
- [x] 자소서(자기소개서) 기반 맞춤 질문 생성
- [x] 채용공고 기반 맞춤 질문 생성
- [x] 두 문서 동시 분석 지원
- [x] 4가지 페르소나 면접관 (기본/실무자/임원/압박)
- [x] 질문 수 선택 (3/5/7/10문제)

### AI 피드백 (강화 버전)
- [x] STAR 구조 평가 (Situation/Task/Action/Result)
- [x] 점수 (0–100) + 원형 게이지
- [x] 잘한 점 / 아쉬운 점 상세 설명 (2–3문장)
- [x] AI 모범 답변 (접기/펼치기 카드)
- [x] STAR 힌트 바텀시트 (연습 모드 인라인 힌트도 추가)
- [x] 꼬리 질문 생성 + 피드백 화면 예상 꼬리 질문 표시

### 말하기 분석 (로컬 계산, API 불필요)
- [x] 발화 속도 측정 (분당 글자 수, 적정 200–350자/분)
- [x] 말버릇 감지 ("어", "음", "그니까" 등 14개 패턴)
- [x] 피드백 화면에 시각화 (진행 막대 + 태그)

### 면접 모드
- [x] 연습 모드 — 시간 제한 없음, STAR 힌트 카드 표시
- [x] 실전 모드 — 30초 준비 타이머, 2분 답변 제한, 잔여 시간 경고

### 인증 & 데이터
- [x] 로그인/회원가입 (Firebase + 로컬 SharedPreferences 이중화)
- [x] Google OAuth 지원
- [x] 비밀번호 재설정 (이메일 링크)
- [x] 앱 재시작 시 자동 로그인
- [x] 세션 자동 저장 (Firestore + 로컬 이중화)
- [x] 연속 학습 스트릭 (🔥 N일 연속 뱃지)

### 히스토리 & 분석
- [x] 면접 기록 목록 (날짜·직종·유형·점수)
- [x] 점수 추이 꺾은선 차트 (fl_chart, 최근 10회)
- [x] 취약 영역 태그 (빈도순 정렬)
- [x] 세션 상세 화면 (문항별 답변 + 피드백 카드)
- [x] 당겨서 새로고침

### 기타
- [x] 결과 클립보드 공유
- [x] 홈 화면 프로필/로그아웃 바텀시트
- [x] 토스 스타일 로그인 UI
- [x] Noto Sans KR 폰트 (웹 한글 깨짐 해결)
- [x] GitHub Actions CI (analyze → test → build-apk)
- [x] 11개 단위 테스트 (FeedbackModel, SessionModel, widget smoke)

## Step Roadmap

| Step | Theme | Status |
|---|---|---|
| 1 | 핵심 기능 구현 (음성 인터뷰 루프) | ✅ Done |
| 2 | UI 개선 및 카테고리 확장 | ✅ Done |
| 3 | Firebase 인증 + Firestore 기록 | ✅ Done |
| 4 | 분석·공유·AI 질문·말하기 분석 | ✅ Done |

## Suggested Next Features (미구현)
- [ ] **영상/카메라 분석** — 시선 처리, 표정 분석 (MediaPipe 필요)
- [ ] **성장 대시보드** — 발화속도·말버릇 개선 추이 그래프
- [ ] **화상 면접 실시간 지원** — 줌 화면 옆 키워드 힌트 (데스크톱/웹)
- [ ] **PDF 리포트 출력** — 세션 결과를 PDF로 내보내기
- [ ] **커스텀 질문** — 사용자가 직접 질문 추가
