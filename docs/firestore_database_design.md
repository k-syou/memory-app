# Firestore 데이터베이스 구조 설계

## 개요
Firebase Firestore를 활용한 Event(일정) 저장 데이터베이스 구조입니다.
나중에 로그인 기능을 추가할 예정이므로, 사용자별로 데이터를 분리하는 구조로 설계했습니다.

### 주요 기능
- **비공개 일정**: 본인만 볼 수 있는 일정
- **공개 일정**: 모든 사용자가 볼 수 있는 일정 (읽기 전용 또는 읽기/쓰기 가능)
- **전체 공유**: 모든 사용자가 보고 수정할 수 있는 협업 일정
- **개인 공유**: 특정 사용자에게만 공유하는 일정 (읽기 또는 읽기/쓰기 권한 설정 가능)

---

## 데이터베이스 구조

### 1. Users 컬렉션
**경로**: `users/{userId}`

사용자 기본 정보를 저장하는 컬렉션입니다.

#### 필드 구조
| 필드명 | 타입 | 필수 | 설명 |
|--------|------|------|------|
| `userId` | String | ✅ | Firebase Auth UID (문서 ID로 사용) |
| `email` | String | ✅ | 사용자 이메일 주소 |
| `displayName` | String | ❌ | 사용자 표시 이름 |
| `photoUrl` | String | ❌ | 프로필 사진 URL |
| `createdAt` | Timestamp | ✅ | 계정 생성 일시 |
| `updatedAt` | Timestamp | ✅ | 마지막 업데이트 일시 |
| `settings` | Map | ❌ | 사용자 설정 정보 |
| `settings.darkMode` | Boolean | ❌ | 다크모드 설정 (기본값: false) |
| `settings.language` | String | ❌ | 언어 설정 (기본값: 'ko') |

#### 예시 데이터
```json
{
  "userId": "abc123xyz",
  "email": "user@example.com",
  "displayName": "홍길동",
  "photoUrl": "https://example.com/photo.jpg",
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-15T12:30:00Z",
  "settings": {
    "darkMode": false,
    "language": "ko"
  }
}
```

---

### 2. Events 서브컬렉션
**경로**: `users/{userId}/events/{eventId}`

각 사용자의 일정을 저장하는 서브컬렉션입니다.
서브컬렉션을 사용하는 이유:
- 사용자별 데이터 분리가 명확함
- 보안 규칙 설정이 쉬움
- 쿼리 성능이 좋음

#### 필드 구조
| 필드명 | 타입 | 필수 | 설명 |
|--------|------|------|------|
| `eventId` | String | ✅ | 일정 고유 ID (문서 ID로 사용) |
| `userId` | String | ✅ | 소유자 사용자 ID (참조용) |
| `title` | String | ✅ | 일정 제목 |
| `description` | String | ❌ | 일정 설명 |
| `date` | Timestamp | ✅ | 일정 날짜 (시간 제외) |
| `startTime` | Timestamp | ❌ | 시작 시간 |
| `endTime` | Timestamp | ❌ | 종료 시간 |
| `color` | String | ❌ | 일정 색상 (HEX 코드, 기본값: '#6366F1') |
| `isAllDay` | Boolean | ❌ | 종일 일정 여부 (기본값: false) |
| `location` | String | ❌ | 장소 |
| `reminder` | Map | ❌ | 알림 설정 |
| `reminder.enabled` | Boolean | ❌ | 알림 활성화 여부 |
| `reminder.minutesBefore` | Number | ❌ | 몇 분 전 알림 (예: 15, 30, 60) |
| `visibility` | String | ✅ | 공개 여부 ('private', 'public', 'shared', 기본값: 'private') |
| `publicPermission` | String | ❌ | 공개 일정 권한 ('read', 'write', 기본값: 'read', visibility가 'public'일 때 사용) |
| `sharedWith` | Array | ❌ | 공유 대상 사용자 ID 목록 (visibility가 'shared'일 때 사용) |
| `sharedWith[].userId` | String | ❌ | 공유 대상 사용자 ID |
| `sharedWith[].permission` | String | ❌ | 권한 ('read', 'write', 기본값: 'read') |
| `sharedWith[].sharedAt` | Timestamp | ❌ | 공유 일시 |
| `createdAt` | Timestamp | ✅ | 생성 일시 |
| `updatedAt` | Timestamp | ✅ | 마지막 업데이트 일시 |
| `deletedAt` | Timestamp | ❌ | 삭제 일시 (소프트 삭제용) |

#### 인덱스 설정
다음 쿼리를 위해 복합 인덱스가 필요합니다:

1. **날짜별 조회**
   - Collection: `users/{userId}/events`
   - Fields: `date` (Ascending), `createdAt` (Ascending)

2. **기간별 조회**
   - Collection: `users/{userId}/events`
   - Fields: `date` (Ascending), `startTime` (Ascending)

3. **공개 일정 조회 (Collection Group)**
   - Collection Group: `events`
   - Fields: `visibility` (Ascending), `date` (Ascending), `startTime` (Ascending)

4. **공개 일정 조회 - 읽기 전용 (Collection Group)**
   - Collection Group: `events`
   - Fields: `visibility` (Ascending), `publicPermission` (Ascending), `date` (Ascending), `startTime` (Ascending)

5. **전체 공유 일정 조회 (Collection Group)**
   - Collection Group: `events`
   - Fields: `visibility` (Ascending), `publicPermission` (Ascending), `date` (Ascending), `startTime` (Ascending)

6. **공유 일정 조회 (Collection Group)**
   - Collection Group: `events`
   - Fields: `visibility` (Ascending), `sharedWith` (Array Contains), `date` (Ascending)

#### Visibility 옵션 설명
- **`private`**: 본인만 볼 수 있음 (기본값)
- **`public`**: 모든 사용자가 접근 가능
  - `publicPermission`이 `read`인 경우: 모든 사용자가 볼 수만 있음
  - `publicPermission`이 `write`인 경우: 모든 사용자가 보고 수정할 수 있음 (전체 공유)
- **`shared`**: `sharedWith` 배열에 포함된 사용자만 접근 가능

#### PublicPermission 옵션 설명 (visibility가 'public'일 때만 사용)
- **`read`**: 모든 사용자가 읽기만 가능 (기본값)
- **`write`**: 모든 사용자가 읽기/쓰기 가능 (전체 공유)

#### 예시 데이터

**1. 비공개 일정 (Private)**
```json
{
  "eventId": "event_1234567890",
  "userId": "abc123xyz",
  "title": "개인 일정",
  "description": "개인 메모",
  "date": "2024-01-20T00:00:00Z",
  "startTime": "2024-01-20T14:00:00Z",
  "endTime": "2024-01-20T15:30:00Z",
  "color": "#6366F1",
  "isAllDay": false,
  "location": "회의실 A",
  "reminder": {
    "enabled": true,
    "minutesBefore": 15
  },
  "visibility": "private",
  "createdAt": "2024-01-15T10:00:00Z",
  "updatedAt": "2024-01-15T10:00:00Z",
  "deletedAt": null
}
```

**2. 공개 일정 (Public - 읽기 전용)**
```json
{
  "eventId": "event_2345678901",
  "userId": "abc123xyz",
  "title": "공개 이벤트",
  "description": "모든 사용자가 볼 수 있는 일정",
  "date": "2024-01-25T00:00:00Z",
  "startTime": "2024-01-25T10:00:00Z",
  "endTime": "2024-01-25T12:00:00Z",
  "color": "#10B981",
  "isAllDay": false,
  "visibility": "public",
  "publicPermission": "read",
  "createdAt": "2024-01-15T10:00:00Z",
  "updatedAt": "2024-01-15T10:00:00Z",
  "deletedAt": null
}
```

**2-1. 전체 공유 일정 (Public - 읽기/쓰기 가능)**
```json
{
  "eventId": "event_2345678902",
  "userId": "abc123xyz",
  "title": "협업 일정",
  "description": "모든 사용자가 보고 수정할 수 있는 일정",
  "date": "2024-01-26T00:00:00Z",
  "startTime": "2024-01-26T14:00:00Z",
  "endTime": "2024-01-26T16:00:00Z",
  "color": "#F59E0B",
  "isAllDay": false,
  "location": "온라인",
  "visibility": "public",
  "publicPermission": "write",
  "createdAt": "2024-01-15T10:00:00Z",
  "updatedAt": "2024-01-15T10:00:00Z",
  "deletedAt": null
}
```

**3. 공유 일정 (Shared)**
```json
{
  "eventId": "event_3456789012",
  "userId": "abc123xyz",
  "title": "팀 미팅",
  "description": "프로젝트 진행 상황 논의",
  "date": "2024-01-20T00:00:00Z",
  "startTime": "2024-01-20T14:00:00Z",
  "endTime": "2024-01-20T15:30:00Z",
  "color": "#F59E0B",
  "isAllDay": false,
  "location": "회의실 A",
  "reminder": {
    "enabled": true,
    "minutesBefore": 15
  },
  "visibility": "shared",
  "sharedWith": [
    {
      "userId": "def456uvw",
      "permission": "read",
      "sharedAt": "2024-01-15T10:00:00Z"
    },
    {
      "userId": "ghi789rst",
      "permission": "write",
      "sharedAt": "2024-01-15T10:00:00Z"
    }
  ],
  "createdAt": "2024-01-15T10:00:00Z",
  "updatedAt": "2024-01-15T10:00:00Z",
  "deletedAt": null
}
```

---

## 보안 규칙 (Firestore Security Rules)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Users 컬렉션: 본인만 읽기/쓰기 가능
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Events 서브컬렉션: 공개/공유 일정 접근 규칙
      match /events/{eventId} {
        // 소유자인지 확인
        function isOwner() {
          return request.auth != null && request.auth.uid == userId;
        }
        
        // 일정 데이터 가져오기 (읽기 권한 확인용)
        function getEvent() {
          return get(/databases/$(database)/documents/users/$(userId)/events/$(eventId));
        }
        
        // 공유 대상인지 확인 (간단한 버전 - 실제 구현 시 클라이언트에서 세부 권한 체크)
        function isSharedWith() {
          let event = getEvent();
          return event.data.visibility == 'shared' && 
                 event.data.sharedWith != null;
        }
        
        // 쓰기 권한이 있는 공유 대상자인지 확인 (간단한 버전)
        function hasWritePermission() {
          let event = getEvent();
          return event.data.visibility == 'shared' &&
                 event.data.sharedWith != null;
        }
        
        // 읽기 권한 확인
        function canRead() {
          return request.auth != null && (
            isOwner() ||
            getEvent().data.visibility == 'public' ||
            isSharedWith()
          );
        }
        
        // 공개 일정의 쓰기 권한 확인
        function hasPublicWritePermission() {
          let event = getEvent();
          return event.data.visibility == 'public' && 
                 event.data.publicPermission == 'write';
        }
        
        // 쓰기 권한 확인
        function canWrite() {
          return isOwner() || 
                 hasPublicWritePermission() ||
                 hasWritePermission();
        }
        
        // 읽기: 소유자, 공개 일정, 공유 대상자
        allow read: if canRead();
        
        // 생성: 소유자만
        allow create: if isOwner();
        
        // 수정: 소유자 또는 쓰기 권한이 있는 공유 대상자
        allow update: if canWrite();
        
        // 삭제: 소유자만
        allow delete: if isOwner();
      }
    }
    
    // Collection Group 쿼리를 위한 규칙 (공개/공유 일정 조회)
    match /{path=**}/events/{eventId} {
      function getEvent() {
        return get(/databases/$(database)/documents/$(path)/events/$(eventId));
      }
      
      function isOwner() {
        let event = getEvent();
        return request.auth != null && request.auth.uid == event.data.userId;
      }
      
      function hasPublicWritePermission() {
        let event = getEvent();
        return event.data.visibility == 'public' && 
               event.data.publicPermission == 'write';
      }
      
      function isSharedWith() {
        let event = getEvent();
        return event.data.visibility == 'shared' && 
               event.data.sharedWith != null;
      }
      
      function canRead() {
        return request.auth != null && (
          isOwner() ||
          getEvent().data.visibility == 'public' ||
          isSharedWith()
        );
      }
      
      function canWrite() {
        return isOwner() || 
               hasPublicWritePermission() ||
               isSharedWith();
      }
      
      allow read: if canRead();
      allow update: if canWrite();
    }
  }
}
```

---

## 쿼리 예시

### 1. 특정 날짜의 일정 조회
```dart
final eventsRef = FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .collection('events')
    .where('date', isGreaterThanOrEqualTo: startOfDay)
    .where('date', isLessThan: endOfDay)
    .where('deletedAt', isNull: true)
    .orderBy('date')
    .orderBy('startTime')
    .get();
```

### 2. 기간별 일정 조회 (한 달치)
```dart
final eventsRef = FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .collection('events')
    .where('date', isGreaterThanOrEqualTo: startOfMonth)
    .where('date', isLessThan: endOfMonth)
    .where('deletedAt', isNull: true)
    .orderBy('date')
    .get();
```

### 3. 일정 추가
```dart
final eventRef = FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .collection('events')
    .doc();
    
await eventRef.set({
  'eventId': eventRef.id,
  'userId': userId,
  'title': '새 일정',
  'date': Timestamp.fromDate(selectedDate),
  'createdAt': FieldValue.serverTimestamp(),
  'updatedAt': FieldValue.serverTimestamp(),
});
```

### 4. 일정 수정
```dart
await FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .collection('events')
    .doc(eventId)
    .update({
      'title': '수정된 제목',
      'updatedAt': FieldValue.serverTimestamp(),
    });
```

### 5. 일정 삭제 (소프트 삭제)
```dart
await FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .collection('events')
    .doc(eventId)
    .update({
      'deletedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
```

### 6. 공개 일정 조회 (모든 사용자의 공개 일정)
```dart
// 모든 사용자의 공개 일정을 조회하려면 collectionGroup 사용
// (읽기 전용 + 전체 공유 모두 포함)
final publicEventsRef = FirebaseFirestore.instance
    .collectionGroup('events')
    .where('visibility', isEqualTo: 'public')
    .where('date', isGreaterThanOrEqualTo: startOfDay)
    .where('date', isLessThan: endOfDay)
    .where('deletedAt', isNull: true)
    .orderBy('date')
    .orderBy('startTime')
    .get();

// 읽기 전용 공개 일정만 조회
final publicReadOnlyEventsRef = FirebaseFirestore.instance
    .collectionGroup('events')
    .where('visibility', isEqualTo: 'public')
    .where('publicPermission', isEqualTo: 'read')
    .where('date', isGreaterThanOrEqualTo: startOfDay)
    .where('date', isLessThan: endOfDay)
    .where('deletedAt', isNull: true)
    .orderBy('date')
    .orderBy('startTime')
    .get();
```

### 7. 공유된 일정 조회 (나에게 공유된 일정)
```dart
final sharedEventsRef = FirebaseFirestore.instance
    .collectionGroup('events')
    .where('visibility', isEqualTo: 'shared')
    .where('sharedWith', arrayContains: currentUserId)
    .where('date', isGreaterThanOrEqualTo: startOfDay)
    .where('date', isLessThan: endOfDay)
    .where('deletedAt', isNull: true)
    .orderBy('date')
    .get();
```

### 8. 일정 공유하기
```dart
// 특정 사용자에게 읽기 권한으로 공유
await FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .collection('events')
    .doc(eventId)
    .update({
      'visibility': 'shared',
      'sharedWith': FieldValue.arrayUnion([
        {
          'userId': targetUserId,
          'permission': 'read',
          'sharedAt': FieldValue.serverTimestamp(),
        }
      ]),
      'updatedAt': FieldValue.serverTimestamp(),
    });

// 쓰기 권한으로 공유
await FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .collection('events')
    .doc(eventId)
    .update({
      'visibility': 'shared',
      'sharedWith': FieldValue.arrayUnion([
        {
          'userId': targetUserId,
          'permission': 'write',
          'sharedAt': FieldValue.serverTimestamp(),
        }
      ]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
```

### 9. 일정 공개 설정
```dart
// 공개로 변경 (읽기 전용)
await FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .collection('events')
    .doc(eventId)
    .update({
      'visibility': 'public',
      'publicPermission': 'read',
      'sharedWith': FieldValue.delete(), // 공개일 때는 sharedWith 불필요
      'updatedAt': FieldValue.serverTimestamp(),
    });

// 전체 공유로 변경 (모든 사용자가 읽기/쓰기 가능)
await FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .collection('events')
    .doc(eventId)
    .update({
      'visibility': 'public',
      'publicPermission': 'write',
      'sharedWith': FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

// 비공개로 변경
await FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .collection('events')
    .doc(eventId)
    .update({
      'visibility': 'private',
      'publicPermission': FieldValue.delete(),
      'sharedWith': FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
```

### 9-1. 전체 공유 일정 조회 (모든 사용자가 수정 가능한 일정)
```dart
// 전체 공유 일정만 조회
final publicWriteEventsRef = FirebaseFirestore.instance
    .collectionGroup('events')
    .where('visibility', isEqualTo: 'public')
    .where('publicPermission', isEqualTo: 'write')
    .where('date', isGreaterThanOrEqualTo: startOfDay)
    .where('date', isLessThan: endOfDay)
    .where('deletedAt', isNull: true)
    .orderBy('date')
    .orderBy('startTime')
    .get();
```

### 10. 공유 해제
```dart
// 특정 사용자 공유 해제
await FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .collection('events')
    .doc(eventId)
    .get()
    .then((doc) {
      if (doc.exists) {
        List<dynamic> sharedWith = doc.data()!['sharedWith'] ?? [];
        sharedWith.removeWhere((s) => s['userId'] == targetUserId);
        
        // 공유 대상이 없으면 private로 변경
        String visibility = sharedWith.isEmpty ? 'private' : 'shared';
        
        return doc.reference.update({
          'visibility': visibility,
          'sharedWith': sharedWith,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });
```

---

## 확장 가능한 구조 (향후 추가 가능)

### 1. 일정 카테고리/태그
- `categories` 서브컬렉션
- `tags` 배열 필드

### 3. 반복 일정
- `recurrence` Map 필드
- `recurrence.type`: 'daily', 'weekly', 'monthly', 'yearly'
- `recurrence.interval`: 반복 간격
- `recurrence.endDate`: 반복 종료일

### 4. 일정 참석자
- `attendees` 배열 필드
- `attendees[].userId`: 참석자 ID
- `attendees[].status`: 'accepted', 'declined', 'pending'

### 5. 일정 댓글/메모
- `comments` 서브컬렉션 추가
- 댓글 작성자, 내용, 작성 시간 등

### 6. 일정 좋아요/즐겨찾기
- `likes` 배열 필드 (사용자 ID 목록)
- `favorites` 배열 필드 (사용자 ID 목록)

---

## 마이그레이션 전략

현재 로컬 저장소(SharedPreferences)에서 Firestore로 마이그레이션할 때:

1. 사용자 로그인 후 기존 로컬 데이터를 Firestore로 업로드
2. 업로드 완료 후 로컬 데이터 삭제
3. 이후부터는 Firestore만 사용

---

## 참고사항

- 모든 Timestamp는 UTC 기준으로 저장
- `deletedAt`이 null이 아닌 경우 삭제된 것으로 간주 (소프트 삭제)
- `createdAt`, `updatedAt`은 `FieldValue.serverTimestamp()` 사용 권장
- 대량 데이터 조회 시 페이지네이션 적용 권장

