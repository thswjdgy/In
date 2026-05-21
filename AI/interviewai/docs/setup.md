# 개발 환경 설정 가이드

새 기기에서 5분 안에 실행 가능하도록 작성된 가이드입니다.

## 필요 도구

| 도구 | 버전 | 설치 링크 |
|------|------|----------|
| Flutter | 3.41.4 이상 | https://docs.flutter.dev/get-started/install |
| Dart | 3.11.1 이상 | Flutter에 포함됨 |
| JDK | 17 이상 | https://adoptium.net |
| Android Studio | 최신 | https://developer.android.com/studio |
| Xcode (macOS) | 15 이상 | App Store |

```bash
# 설치 확인
flutter doctor
```

---

## 1. 저장소 클론

```bash
git clone https://github.com/<your-org>/interviewai.git
cd interviewai
```

## 2. 의존성 설치

```bash
flutter pub get
```

## 3. 환경 변수 설정

루트에 `.env.example`을 복사해서 `.env` 생성:

```bash
cp .env.example .env
```

`.env` 파일을 열어 실제 키 입력:

```env
OPENAI_API_KEY=sk-여기에_실제_키_입력
ANTHROPIC_API_KEY=sk-ant-여기에_실제_키_입력
FIREBASE_PROJECT_ID=interviewai-여기에_프로젝트_ID
```

> **.env는 절대 git에 커밋하지 마세요** (`.gitignore`에 포함됨)

## 4. Firebase 프로젝트 연결 (히스토리 기능)

히스토리 저장 기능은 Firebase가 필요합니다.  
Firebase 없이도 면접 세션 자체는 정상 동작합니다.

1. [Firebase Console](https://console.firebase.google.com)에서 프로젝트 생성
2. Android 앱 등록 → `google-services.json` 다운로드 → `android/app/` 에 배치
3. iOS 앱 등록 → `GoogleService-Info.plist` 다운로드 → `ios/Runner/` 에 배치
4. Firebase Authentication → Google 로그인 활성화
5. Firestore Database 생성 → 테스트 모드로 시작

## 5. 앱 실행

```bash
# API 키를 dart-define으로 주입
flutter run \
  --dart-define=OPENAI_API_KEY=sk-... \
  --dart-define=ANTHROPIC_API_KEY=sk-ant-...
```

> VS Code 사용 시 `.vscode/launch.json`에 `--dart-define` 항목을 추가하면 편리합니다.

---

## 문제 해결 FAQ

**Q1. `flutter run` 시 "No connected devices" 오류**  
→ 에뮬레이터를 먼저 실행하거나 실기기를 USB로 연결하세요.  
```bash
flutter devices  # 연결된 기기 목록 확인
```

**Q2. Android 빌드 시 "JDK version" 오류**  
→ JDK 17이 설치되어 있는지 확인하세요.  
```bash
java -version
```

**Q3. "Firebase not initialized" 크래시**  
→ `google-services.json` / `GoogleService-Info.plist`가 올바른 위치에 있는지 확인하세요.  
Firebase 연동 없이 실행하려면 main.dart의 Firebase init 코드를 주석 처리하세요.

**Q4. Whisper API 호출 실패**  
→ `OPENAI_API_KEY`가 올바른지, 계정 크레딧이 남아있는지 확인하세요.

**Q5. `flutter pub get` 후 빌드 오류**  
→ 캐시를 초기화 후 재시도:  
```bash
flutter clean
flutter pub get
```
