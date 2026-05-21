# InterviewAI — Sub-Agents

Sub-agents for specialized tasks within this project. Defined per Week 7 course requirements.

## Available Agents

### code-bug-analyzer
**Model**: Claude Opus  
**Color**: Blue  
**Permissions**: Read-only (no file writes)

Analyzes the codebase to identify bugs, type errors, and logic issues.

**Trigger**: When a bug is reported or `flutter analyze` shows warnings  
**Scope**: `lib/` directory — all Dart files  
**Output**: Ordered list of issues with file:line references and suggested fixes

```
Analyze the InterviewAI Flutter codebase for bugs and issues.
Focus on:
- Null safety violations
- State management errors (Riverpod providers)
- Audio lifecycle issues (recorder not disposed, timer leaks)
- API error handling gaps
- Deprecated Flutter APIs (withOpacity → withValues)
Report each issue as: [SEVERITY] file:line — description — suggested fix
```

---

### performance-optimizer
**Model**: Inherited (claude-sonnet-4-6)  
**Color**: Green  
**Permissions**: All tools

Reviews and improves app performance — startup time, frame rate, memory usage.

**Trigger**: When the app feels slow or before each Step release  
**Scope**: Screens, services, API clients  
**Output**: Specific refactoring suggestions with before/after code

```
Review InterviewAI for performance bottlenecks.
Check:
- Widget rebuilds (unnecessary setState calls)
- Audio recorder initialization (lazy vs eager)
- API timeout settings (WhisperClient, ClaudeFeedbackClient)
- Image/asset loading
- GoRouter rebuild patterns
Suggest concrete optimizations with measurable impact.
```

---

### ux-design-advisor
**Model**: Inherited (claude-sonnet-4-6)  
**Color**: Orange  
**Permissions**: All tools

Reviews screens for UX consistency, accessibility, and Korean language correctness.

**Trigger**: After implementing a new screen or major UI change  
**Scope**: `lib/features/` all screen files  
**Output**: Actionable UX improvements with priority (P1/P2/P3)

```
Review InterviewAI screens for UX quality.
Check:
- Korean text naturalness (면접 context)
- Touch target sizes (minimum 44×44dp)
- Loading state feedback (processing states)
- Error message clarity
- Color contrast ratios (WCAG AA)
- Navigation flow coherence (onboarding → interview → feedback → history)
Output P1/P2/P3 priority improvements per screen.
```

## Usage in Claude Code

```bash
# In the Claude Code CLI, agents can be invoked via:
# /agents → lists available agents
# Then select the agent and describe the task

# Example: trigger code-bug-analyzer
claude --agent code-bug-analyzer "analyze lib/features/interview/screens/interview_screen.dart"
```
