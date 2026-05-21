# interview-validate

Validate the question bank for quality and correctness.

## Usage
`/interview-validate`

## What this does

1. Read `lib/shared/constants/question_bank.dart`
2. For each question, check:
   - Korean language (no mixed English sentences)
   - Question ends with `?` or `요.`
   - Length between 15 and 120 characters
   - No duplicate questions across categories
   - Category key matches one of: `backend`, `frontend`, `android`, `data`
   - Type key matches one of: `technical`, `behavioral`
3. Report: total count, pass/fail per category, list any violations with line numbers
4. If violations found, suggest corrected text for each

## Output format
```
[PASS] backend/technical: 5 questions ✓
[FAIL] frontend/behavioral: Q3 — duplicate of backend/behavioral Q1
Total: 18 questions, 1 violation
```
