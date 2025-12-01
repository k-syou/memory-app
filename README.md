# 기억 (Memory)

팀원을 랜덤으로 배치하여 팀을 생성하고 일정을 관리하는 Flutter 모바일 애플리케이션입니다.

## 주요 기능

### 1. 인증 및 사용자 관리
- Google Sign-In을 통한 간편 로그인
- 사용자 프로필 관리 (닉네임 설정)
- 로그아웃 기능
- Firebase Authentication 연동

### 2. 팀 생성
- 참가자 이름을 입력하여 랜덤으로 팀을 생성
- 팀 개수 설정 및 균등 배분
- 팀장 지정 기능
- 반드시 함께해야 하는 사람 설정
- 반드시 분리해야 하는 사람 설정
- 팀 이름 커스터마이징

### 3. 캘린더
- 일정 등록 및 관리
- 날짜별 일정 조회
- 일정 추가/수정/삭제 기능
- 색상으로 구분되는 일정 표시

### 4. 설정 관리
- **전역 설정**: 다크모드 전환, 닉네임 설정, 로그아웃
- **팀 생성 설정**: 참가자 이름, 팀 개수, 팀장, 제약 조건 등

### 5. UI/UX
- 모던한 Material Design 3 스타일
- 다크모드/라이트모드 지원
- 커스텀 폰트 (Paperlogy)
- 직관적인 메뉴 구조
- 반응형 레이아웃
- 한국어 로케일 지원

### 6. 데이터 저장
- SharedPreferences를 사용한 설정 자동 저장
- Firebase Firestore를 사용한 사용자 데이터 및 일정 저장
- 앱 재시작 시 설정 유지

## 화면 구성

### 로그인 화면 (LoginScreen)
- Google Sign-In 버튼
- 자동 로그인 상태 확인

### 홈 화면 (HomeScreen)
- 메인 메뉴 화면
- 팀 생성 메뉴 카드
- 캘린더 메뉴 카드
- 다크모드 토글 버튼
- 사용자 프로필 버튼 (설정 화면 이동)

### 팀 생성 화면 (TeamGenerationScreen)
- 팀원 굴리기 버튼
- 팀 구성 결과 표시 (2열 그리드 레이아웃)
- 팀장 표시 (별 아이콘)
- 초기화 버튼
- 팀 생성 설정 버튼

### 캘린더 화면 (CalendarScreen)
- 월별 캘린더 뷰
- 날짜 선택 및 일정 조회
- 일정 추가/수정/삭제 다이얼로그
- 색상별 일정 표시

### 전역 설정 화면 (GlobalSettingsScreen)
- 닉네임 설정
- 다크모드 전환
- 로그아웃

### 팀 생성 설정 화면 (TeamGenerationSettingsScreen)
- 참가자 이름 입력
- 팀 개수 선택 (드롭다운, 추천 표시)
- 팀 이름 설정
- 팀장 설정
- 반드시 함께해야 하는 사람 설정
- 반드시 분리해야 하는 사람 설정
- 설정 초기화 기능

## 기술 스택

- **Flutter**: 크로스 플랫폼 모바일 개발 프레임워크
- **Dart**: 프로그래밍 언어
- **Firebase**: 
  - Authentication (Google Sign-In)
  - Cloud Firestore (사용자 데이터 및 일정 저장)
- **shared_preferences**: 로컬 설정 데이터 저장
- **google_sign_in**: Google 로그인 연동
- **intl**: 날짜/시간 포맷팅
- **Material Design 3**: UI 디자인 시스템

## 프로젝트 구조

```
lib/
├── main.dart                          # 앱 진입점
├── firebase_options.dart              # Firebase 설정
├── models/
│   ├── event.dart                    # 일정 모델
│   └── team_maker.dart               # 팀 생성 로직
├── screens/
│   ├── login_screen.dart             # 로그인 화면
│   ├── home_screen.dart              # 홈 화면
│   ├── team_generation_screen.dart   # 팀 생성 화면
│   ├── calendar_screen.dart          # 캘린더 화면
│   ├── global_settings_screen.dart   # 전역 설정 화면
│   └── team_generation_settings_screen.dart  # 팀 생성 설정 화면
└── services/
    ├── auth_service.dart             # 인증 서비스 (Firebase Auth)
    ├── event_service.dart            # 일정 관리 서비스
    ├── storage_service.dart          # 로컬 데이터 저장/로드
    ├── settings_validation_service.dart  # 입력 검증
    ├── team_calculation_service.dart # 팀 개수 계산
    └── settings_default_service.dart # 기본값 관리
```

## 주요 특징

### 팀 균등 배분
- 참가자 수를 고려하여 최대한 균등하게 팀원 배분
- 팀장 포함하여 인원 수 균등화
- 총 인원수로 나누어 떨어지는 팀 개수 추천

### 사용자 친화적 UI
- 직관적인 버튼 배치
- 명확한 시각적 피드백
- 부드러운 그라데이션 색상
- 다크모드 최적화

## APK 빌드

### Release APK 빌드
```bash
flutter build apk --release
```

### Debug APK 빌드
```bash
flutter build apk --debug
```

### ABI별 분리 빌드 (용량 최적화)
```bash
flutter build apk --split-per-abi
```

빌드된 APK 파일은 `build/app/outputs/flutter-apk/` 디렉토리에 생성됩니다.

## 개발 환경

- Flutter SDK: ^3.8.1
- Dart SDK: ^3.8.1
- 최소 Android SDK: 23
- 타겟 Android SDK: flutter.targetSdkVersion
- Firebase 프로젝트: memory-app-server

## Firebase 설정

1. Firebase 프로젝트 생성 및 Android/iOS 앱 등록
2. `google-services.json` (Android) 및 `GoogleService-Info.plist` (iOS) 파일 추가
3. `flutterfire configure` 명령어로 `firebase_options.dart` 생성
4. Firebase Authentication에서 Google Sign-In 활성화
5. Firestore Database 생성 및 보안 규칙 설정

## 라이선스

이 프로젝트는 개인 사용 목적으로 개발되었습니다.
