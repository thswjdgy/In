# ADR-0001 — Flutter 플랫폼 선택

**날짜:** 2026-05-18  
**상태:** 채택됨

## 배경

InterviewAI는 iOS와 Android 모두를 타겟으로 하는 모바일 앱이다.
2인 팀, 10~16주 개발 기간이라는 제약 조건에서 플랫폼을 결정해야 했다.

## 결정

**Flutter 3.x** (Dart 3.x) 를 사용한다.

## 대안 검토

| 옵션 | 장점 | 단점 | 제외 이유 |
|------|------|------|----------|
| Flutter | 단일 코드베이스, 빠른 UI 개발, Hot Reload | Dart 학습 곡선 | — (채택) |
| React Native | JS 생태계 풍부 | 브리지 성능 이슈, 네이티브 모듈 설정 복잡 | 음성 처리 네이티브 연동 부담 |
| Swift (iOS only) | 최고 성능, Xcode 통합 | iOS 전용, 팀 학습 비용 | Android 지원 불가 |
| Kotlin (Android only) | Android 공식, 성능 우수 | iOS 지원 불가 | iOS 지원 불가 |

## 결과

- iOS 14+ / Android 8+ 단일 코드베이스로 지원
- flutter_sound, flutter_tts, permission_handler 모두 Flutter 플러그인으로 제공됨
- Riverpod 2.x 와의 통합이 Flutter 생태계에서 성숙함
- 2인 팀이 공통 코드베이스로 협업 가능
