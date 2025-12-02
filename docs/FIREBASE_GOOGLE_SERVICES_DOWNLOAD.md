# Firebase Console에서 google-services.json 다운로드 가이드

## 단계별 상세 가이드

### 1단계: Firebase Console 접속
1. 웹 브라우저에서 https://console.firebase.google.com/ 접속
2. Google 계정으로 로그인 (Firebase 프로젝트에 접근 권한이 있는 계정)

### 2단계: 프로젝트 선택
1. Firebase Console 메인 페이지에서 프로젝트 목록이 표시됩니다
2. **"memory-app-server"** 프로젝트를 클릭하여 선택
   - 프로젝트가 보이지 않으면 상단 검색창에 "memory-app-server" 입력

### 3단계: 프로젝트 설정 페이지로 이동
1. 프로젝트 대시보드에 들어간 후, **왼쪽 상단의 톱니바퀴 아이콘(⚙️)** 클릭
   - 또는 화면 왼쪽 사이드바에서 **"프로젝트 설정"** 클릭
   - 또는 화면 오른쪽 상단의 **"프로젝트 설정"** 텍스트 클릭

### 4단계: 일반 탭 확인
1. 프로젝트 설정 페이지가 열리면 상단에 여러 탭이 있습니다:
   - **일반** (기본적으로 선택됨)
   - 사용자 및 권한
   - 통합
   - 등등...
2. **"일반"** 탭이 선택되어 있는지 확인 (보통 기본으로 선택되어 있음)

### 5단계: "내 앱" 섹션 찾기
1. "일반" 탭을 아래로 스크롤하면 **"내 앱"** 섹션이 있습니다
2. 이 섹션에는 등록된 앱들이 표시됩니다:
   - Android 앱
   - iOS 앱
   - 웹 앱
   - 등등...

### 6단계: Android 앱 선택
1. "내 앱" 섹션에서 **Android 앱**을 찾습니다
2. Android 앱 카드에서 다음 정보를 확인할 수 있습니다:
   - 앱 패키지 이름: `com.memory.app`
   - 앱 ID: `1:629900837240:android:2d4dfde780ed14e424c88d`
3. Android 앱 카드의 **오른쪽 상단에 있는 점 3개 메뉴(⋮)** 또는 **"google-services.json 다운로드"** 버튼 클릭
   - 또는 Android 앱 카드를 클릭하면 상세 페이지로 이동

### 7단계: google-services.json 다운로드
**방법 A: 앱 카드에서 직접 다운로드**
1. Android 앱 카드에서 **"google-services.json"** 버튼 또는 링크 클릭
2. 파일이 자동으로 다운로드됩니다

**방법 B: 앱 상세 페이지에서 다운로드**
1. Android 앱 카드를 클릭하면 상세 페이지로 이동
2. 상세 페이지에서 **"google-services.json 다운로드"** 버튼 클릭
3. 파일이 자동으로 다운로드됩니다

### 8단계: 파일 위치 확인
1. 다운로드한 파일은 보통 브라우저의 기본 다운로드 폴더에 저장됩니다:
   - Windows: `C:\Users\[사용자명]\Downloads\google-services.json`
   - macOS: `~/Downloads/google-services.json`
   - Linux: `~/Downloads/google-services.json`

### 9단계: 프로젝트에 파일 복사
1. 다운로드한 `google-services.json` 파일을 찾습니다
2. 파일을 다음 경로로 복사합니다:
   ```
   android/app/google-services.json
   ```
3. 기존 파일이 있다면 덮어쓰기

## 시각적 참고

### Firebase Console 레이아웃
```
┌─────────────────────────────────────────┐
│  Firebase Console                        │
│  [프로젝트 목록]                          │
│  ┌───────────────────────────────────┐   │
│  │ memory-app-server (선택)          │   │
│  └───────────────────────────────────┘   │
└─────────────────────────────────────────┘
         ↓ 클릭
┌─────────────────────────────────────────┐
│  프로젝트 대시보드                        │
│  ⚙️ 프로젝트 설정 (왼쪽 상단)           │
│         ↓ 클릭                           │
│  ┌───────────────────────────────────┐   │
│  │ 프로젝트 설정                      │   │
│  │ [일반] [사용자 및 권한] [통합]... │   │
│  │                                   │   │
│  │ 내 앱                              │   │
│  │ ┌─────────────────────────────┐   │   │
│  │ │ Android 앱                  │   │   │
│  │ │ com.memory.app              │   │   │
│  │ │ [google-services.json 다운로드]│ │   │
│  │ └─────────────────────────────┘   │   │
│  └───────────────────────────────────┘   │
└─────────────────────────────────────────┘
```

## 문제 해결

### "내 앱" 섹션이 보이지 않는 경우
- 프로젝트 설정 페이지에서 "일반" 탭이 선택되어 있는지 확인
- 페이지를 아래로 스크롤
- 브라우저 캐시를 지우고 새로고침

### Android 앱이 보이지 않는 경우
- Firebase Console에서 Android 앱이 등록되어 있는지 확인
- 다른 프로젝트를 선택했는지 확인
- Firebase Console에서 Android 앱을 새로 등록해야 할 수도 있음

### 다운로드 버튼이 보이지 않는 경우
- Android 앱 카드를 클릭하여 상세 페이지로 이동
- 상세 페이지에서 다운로드 옵션 확인
- 브라우저의 팝업 차단 설정 확인

## 대안: Firebase CLI 사용

터미널에서 직접 다운로드하려면:

```bash
# Firebase CLI 설치 (없는 경우)
npm install -g firebase-tools

# Firebase 로그인
firebase login

# 프로젝트 디렉토리로 이동
cd memory_team_maker

# google-services.json 다운로드 (직접 다운로드는 불가능하지만, 
# flutterfire configure로 재생성 가능)
flutterfire configure --project=memory-app-server --platforms=android
```

## 확인 방법

다운로드한 `google-services.json` 파일을 열어서 다음을 확인:

1. `oauth_client` 배열이 비어있지 않은지 확인
2. `package_name`이 `com.memory.app`인지 확인
3. `project_id`가 `memory-app-server`인지 확인

올바른 파일 예시:
```json
{
  "project_info": {
    "project_id": "memory-app-server",
    ...
  },
  "client": [
    {
      "client_info": {
        "android_client_info": {
          "package_name": "com.memory.app"
        }
      },
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

