# ADR-0003 — Firebase 백엔드 선택

**날짜:** 2026-05-18  
**상태:** 채택됨

## 배경

면접 세션 기록 저장, 사용자 인증, 히스토리 조회를 위한 백엔드가 필요하다.
2인 팀, 10~16주 기간에서 백엔드 서버를 직접 구축하는 것은 부담이 크다.

## 결정

**Firebase** (Authentication + Cloud Firestore) 를 사용한다.

## 대안 검토

| 옵션 | 장점 | 단점 | 제외 이유 |
|------|------|------|----------|
| Firebase | Flutter 공식 지원, Auth 통합 용이, 무료 티어 충분 | Google 종속성, 복잡한 쿼리 제한 | — (채택) |
| Supabase | PostgreSQL 기반, 오픈소스, SQL 쿼리 가능 | Flutter SDK 성숙도 낮음, 팀 학습 비용 | Flutter 지원 불안정 |
| 자체 서버 (Node.js) | 완전한 제어권, 유연한 쿼리 | 서버 유지보수, 배포 복잡성 | 10주 내 구현 불가 |
| AWS Amplify | 강력한 기능, 엔터프라이즈 수준 | 설정 복잡, 높은 비용 | MVP에 과함 |

## 결과

- `google_sign_in` + `firebase_auth`로 소셜 로그인 빠르게 구현
- Firestore 실시간 스트림으로 히스토리 즉시 반영
- 무료 티어(Spark Plan)로 개발/테스트 비용 0원
- `google-services.json` 설정 전까지는 Firebase 초기화를 조건부 처리하여 개발 중단 방지

## 데이터 구조

```
users/{userId}/
  sessions/{sessionId}/
    - jobCategory, interviewType, totalScore
    - questionCount, weakAreas[]
    - startedAt, endedAt (Timestamp)
    questionAnswers/{answerId}/
      - question, userAnswer, score
      - strengths[], improvements[], summary
```
