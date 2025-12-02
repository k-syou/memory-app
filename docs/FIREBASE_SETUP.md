# Firebase Google Sign-In 설정 가이드

## 문제: 에러 코드 10 (DEVELOPER_ERROR)

에러 코드 10은 주로 `google-services.json` 파일의 `oauth_client`가 비어있을 때 발생합니다.

## 해결 방법

### 방법 1: Firebase Console에서 google-services.json 재다운로드 (권장)

1. **Firebase Console 접속**
   - https://console.firebase.google.com/
   - 프로젝트: `memory-app-server` 선택

2. **프로젝트 설정으로 이동**
   - 좌측 메뉴에서 ⚙️ (설정) → 프로젝트 설정
   - 또는 우측 상단의 프로젝트 설정 아이콘 클릭

3. **Android 앱 선택**
   - "내 앱" 섹션에서 Android 앱 (`com.memory.app`) 선택

4. **google-services.json 다운로드**
   - "google-services.json" 파일 다운로드 버튼 클릭
   - 다운로드한 파일을 `android/app/google-services.json`에 덮어쓰기

5. **OAuth 클라이언트 확인**
   - 다운로드한 `google-services.json` 파일을 열어서 `oauth_client` 배열이 비어있지 않은지 확인
   - 비어있다면 방법 2를 진행하세요

### 방법 2: Google Cloud Console에서 OAuth 클라이언트 ID 확인 및 추가

1. **Google Cloud Console 접속**
   - https://console.cloud.google.com/
   - 프로젝트: `memory-app-server` 선택

2. **API 및 서비스 → 사용자 인증 정보로 이동**
   - 좌측 메뉴: API 및 서비스 → 사용자 인증 정보

3. **OAuth 클라이언트 ID 확인**
   - "OAuth 2.0 클라이언트 ID" 섹션에서 Android용 클라이언트 ID 확인
   - 없다면 생성:
     - "+ 사용자 인증 정보 만들기" → "OAuth 클라이언트 ID"
     - 애플리케이션 유형: Android
     - 이름: Android client (또는 원하는 이름)
     - 패키지 이름: `com.memory.app`
     - SHA-1 인증서 지문: (Firebase Console에 등록한 SHA-1 지문 입력)

4. **Firebase Console에서 확인**
   - Firebase Console → 프로젝트 설정 → 일반
   - "내 앱" 섹션에서 Android 앱 선택
   - "SHA 인증서 지문" 섹션에 SHA-1 지문이 등록되어 있는지 확인
   - 등록되어 있다면 `google-services.json` 파일을 다시 다운로드

### 방법 3: SHA-1 지문 확인 및 등록

#### Windows에서 SHA-1 지문 확인:
```powershell
keytool -list -v -keystore "$env:USERPROFILE\.android\debug.keystore" -storepass android
```

#### Linux/macOS에서 SHA-1 지문 확인:
```bash
keytool -list -v -keystore ~/.android/debug.keystore -storepass android
```

#### SHA-1 지문 등록:
1. Firebase Console → 프로젝트 설정 → 일반
2. "내 앱" 섹션에서 Android 앱 선택
3. "SHA 인증서 지문" 섹션에서 "+ 지문 추가" 클릭
4. 위에서 확인한 SHA-1 지문 입력
5. 저장 후 `google-services.json` 파일 재다운로드

### 방법 4: 코드에 서버 클라이언트 ID 명시 (임시 해결책)

만약 위 방법들이 작동하지 않는다면, Google Cloud Console에서 확인한 서버 클라이언트 ID를 코드에 직접 지정할 수 있습니다:

1. **Google Cloud Console에서 서버 클라이언트 ID 확인**
   - Google Cloud Console → API 및 서비스 → 사용자 인증 정보
   - "OAuth 2.0 클라이언트 ID" 섹션에서 "웹 애플리케이션" 타입의 클라이언트 ID 확인
   - 또는 Firebase Console → 프로젝트 설정 → 일반 → "내 앱" → 웹 앱의 클라이언트 ID 확인

2. **코드 수정**
   - `lib/services/auth_service.dart` 파일에서 `GoogleSignIn` 초기화 시 `serverClientId` 파라미터 추가
   - 예: `GoogleSignIn(serverClientId: 'YOUR_SERVER_CLIENT_ID', ...)`

## 확인 사항 체크리스트

- [ ] Firebase Console에서 Google Sign-In이 활성화되어 있음
- [ ] SHA-1 지문이 Firebase Console에 등록되어 있음
- [ ] `google-services.json` 파일의 `oauth_client` 배열이 비어있지 않음
- [ ] `google-services.json` 파일이 최신 버전임
- [ ] AndroidManifest.xml에 인터넷 권한이 추가되어 있음
- [ ] 앱을 clean build 후 다시 실행

## 앱 재빌드

설정 변경 후 반드시 앱을 재빌드하세요:

```bash
flutter clean
flutter pub get
flutter run
```

