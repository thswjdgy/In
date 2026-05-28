# InterviewAI — Bonus Features & Course Requirements

Tracks bonus features and Week 5–7 course requirement compliance.

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
- [x] MCP: Notion MCP server — `.claude/mcp_config.json` (replace YOUR_NOTION_TOKEN)
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

## Bonus Feature Ideas

### Implemented
- [x] Category-specific question banks (backend, frontend, PM, designer)
- [x] STAR framework evaluation in Claude feedback
- [x] Korean TTS with natural speed (0.9x)
- [x] Animated pulsing mic during recording
- [x] Linear progress indicator across questions
- [x] Score color coding (green ≥80 / amber ≥60 / red <60)
- [x] **Streak tracking** — daily practice streak with SharedPreferences (🔥 badge on home screen)
- [x] **Result sharing** — copy formatted result text to clipboard
- [x] **Firebase History** — sessions saved to Firestore with score trends + weakness tags
- [x] **Analytics** — weak area tags sorted by frequency on history screen
- [x] **Example answer** — STAR 답변 구조 힌트 바텀시트 (FeedbackScreen)
- [x] **Radar chart** — 5축 역량 분석 (STAR구조/구체성/논리성/전문성/자신감) in SessionDetailScreen

### Won't Implement (범위 외)
- Pronunciation guide — technical term phonetics
- Custom questions — user-defined question bank
- Export PDF — feedback as PDF report

## Step Roadmap

| Step | Theme | Status |
|---|---|---|
| 1 | 핵심 기능 구현 (음성 인터뷰 루프) | ✅ Done |
| 2 | UI 개선 및 카테고리 확장 | ✅ Done |
| 3 | Firebase 인증 + Firestore 기록 | ✅ Done |
| 4 | 분석, 공유, Play Store 출시 준비 | 🚧 In Progress |
