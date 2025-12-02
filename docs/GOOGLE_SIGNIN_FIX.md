# Google Sign-In 에러 코드 10 해결 방법

## 현재 문제
- `google-services.json` 파일의 `oauth_client` 배열이 비어있음
- 에러 코드 10 (DEVELOPER_ERROR) 발생

## 해결 방법

### 1단계: Firebase Console에서 google-services.json 재다운로드

1. Firebase Console 접속: https://console.firebase.google.com/
2. 프로젝트 `memory-app-server` 선택
3. 프로젝트 설정 (⚙️) → 일반 탭
4. "내 앱" 섹션에서 Android 앱 (`com.memory.app`) 선택
5. "google-services.json" 파일 다운로드
6. 다운로드한 파일을 `android/app/google-services.json`에 덮어쓰기

### 2단계: OAuth 클라이언트 확인

다운로드한 `google-services.json` 파일을 열어서 `oauth_client` 배열이 비어있지 않은지 확인:

```json
{
  "client": [
    {
      "oauth_client": [
        {
          "client_id": "629900837240-xxxxx.apps.googleusercontent.com",
          "client_type": 3
        }
      ]
    }
  ]
}
```

만약 여전히 비어있다면 3단계로 진행하세요.

### 3단계: Google Cloud Console에서 OAuth 클라이언트 확인

1. Google Cloud Console 접속: https://console.cloud.google.com/
2. 프로젝트 `memory-app-server` 선택
3. 좌측 메뉴: "API 및 서비스" → "사용자 인증 정보"
4. "OAuth 2.0 클라이언트 ID" 섹션 확인
5. Android용 클라이언트가 없다면 생성:
   - "+ 사용자 인증 정보 만들기" → "OAuth 클라이언트 ID"
   - 애플리케이션 유형: Android
   - 패키지 이름: `com.memory.app`
   - SHA-1 인증서 지문: (Firebase Console에 등록한 SHA-1 입력)

### 4단계: 앱 재빌드

```bash
flutter clean
flutter pub get
flutter run
```

## 참고: SHA-1 지문 확인 방법

### Windows (PowerShell):
```powershell
keytool -list -v -keystore "$env:USERPROFILE\.android\debug.keystore" -storepass android | Select-String "SHA1:"
```

### Linux/macOS:
```bash
keytool -list -v -keystore ~/.android/debug.keystore -storepass android | grep "SHA1:"
```

