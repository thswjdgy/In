# 빌드 & 배포 가이드

## Android APK 빌드

### 로컬 빌드

```bash
# Release APK (API 키 주입 필수)
flutter build apk --release \
  --dart-define=OPENAI_API_KEY=$OPENAI_API_KEY \
  --dart-define=ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY

# 결과물 위치
# build/app/outputs/flutter-apk/app-release.apk
```

### Split APK (배포 용량 최적화)

```bash
flutter build apk --split-per-abi --release \
  --dart-define=OPENAI_API_KEY=$OPENAI_API_KEY \
  --dart-define=ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY
```

## iOS 빌드 (macOS 필요)

```bash
flutter build ipa --release \
  --dart-define=OPENAI_API_KEY=$OPENAI_API_KEY \
  --dart-define=ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY
```

---

## GitHub Actions CI/CD

### 파이프라인 구조

```
push / PR to main
  └── analyze    : flutter analyze (lint 검사)
  └── test       : flutter test (단위 테스트)
  └── build-apk  : flutter build apk --release
                    └── 결과물 → GitHub Releases 업로드
```

### 트리거 방법

1. `main` 브랜치에 push → 자동 실행
2. `main` 대상 PR 생성 → 자동 실행
3. Actions 탭 → "Flutter CI" → "Run workflow" → 수동 실행

### GitHub Secrets 설정

| Secret 이름 | 설명 |
|-------------|------|
| `OPENAI_API_KEY` | OpenAI API 키 |
| `ANTHROPIC_API_KEY` | Anthropic API 키 |

설정 경로: `GitHub Repo → Settings → Secrets and variables → Actions → New repository secret`

### 워크플로 파일 위치

`.github/workflows/build.yml`

```yaml
name: Flutter CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  analyze:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.41.4'
      - run: flutter pub get
      - run: flutter analyze

  test:
    runs-on: ubuntu-latest
    needs: analyze
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.41.4'
      - run: flutter pub get
      - run: flutter test

  build-android:
    runs-on: ubuntu-latest
    needs: test
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '17'
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.41.4'
      - run: flutter pub get
      - run: |
          flutter build apk --release \
            --dart-define=OPENAI_API_KEY=${{ secrets.OPENAI_API_KEY }} \
            --dart-define=ANTHROPIC_API_KEY=${{ secrets.ANTHROPIC_API_KEY }}
      - uses: actions/upload-artifact@v4
        with:
          name: release-apk
          path: build/app/outputs/flutter-apk/app-release.apk
```
