# interview-add

Add a new interview question to the question bank.

## Usage
`/interview-add category=<category> type=<type> question=<question text>`

### Parameters
- `category`: `backend` | `frontend` | `android` | `data`
- `type`: `technical` | `behavioral`
- `question`: Korean question text (15–120 chars, ends with `?` or `요.`)

## What this does

1. Validate the question against quality rules (see `/interview-validate`)
2. Check for duplicates in `lib/shared/constants/question_bank.dart`
3. If valid, append the question to the correct list in `question_bank.dart`
4. Run `flutter analyze` to confirm no syntax errors
5. Report the new total count for that category/type

## Example
```
/interview-add category=backend type=technical question=REST API와 GraphQL의 차이점을 설명해주세요.
```
