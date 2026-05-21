# ADR-0002 — Riverpod 2.x 상태관리 선택

**날짜:** 2026-05-18  
**상태:** 채택됨

## 배경

Flutter 앱의 상태관리 라이브러리를 선택해야 한다.
면접 세션 상태(idle/recording/transcribing/done/error)처럼 복잡한 비동기 상태를 관리해야 한다.

## 결정

**Riverpod 2.x** + **riverpod_annotation** (코드 제너레이션) 을 사용한다.

## 대안 검토

| 옵션 | 장점 | 단점 | 제외 이유 |
|------|------|------|----------|
| Riverpod 2.x | 타입 안전, 컴파일 타임 오류 검출, AsyncNotifier 패턴 | 학습 곡선, 코드 제너레이션 필요 | — (채택) |
| Provider | 익숙함, 가벼움 | 런타임 오류, Riverpod의 전신이라 기능 제한 | 타입 안전성 부족 |
| BLoC | 엄격한 구조, 테스트 용이 | 보일러플레이트 과다, 2인 팀에 과함 | 개발 속도 저하 |
| GetX | 적은 코드, 빠른 개발 | 글로벌 상태 오염, 테스트 어려움 | 유지보수성 우려 |

## 결과

- `AsyncNotifier` 패턴으로 로딩/에러/데이터 상태를 선언적으로 관리
- `riverpod_generator`로 `@riverpod` 어노테이션 사용, 보일러플레이트 최소화
- Provider 트리 외부에서도 의존성 주입 가능 (서비스 레이어 테스트 용이)
- Flutter DevTools의 Riverpod 인스펙터로 상태 디버깅 가능
