import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';
import 'auth_service.dart';

class EventService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 모든 일정 로드 (사용자 일정 + 공개 일정)
  static Future<List<Event>> loadEvents() async {
    final user = AuthService.currentUser;
    if (user == null) {
      print('EventService: 사용자가 로그인하지 않았습니다');
      return [];
    }

    try {
      // 사용자 자신의 일정 (private + public 모두)
      final userEventsQuery = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('events')
          .get();

      print('EventService: 사용자 일정 ${userEventsQuery.docs.length}개 발견');

      final userEvents = userEventsQuery.docs.map((doc) {
        try {
          final data = doc.data();
          print('EventService: 일정 데이터 파싱 - ${doc.id}: ${data['title']}');
          return Event.fromJson({
            'id': doc.id,
            'title': data['title'] as String,
            'description': data['description'] as String,
            'date': (data['date'] as Timestamp).toDate().toIso8601String(),
            'startTime': data['startTime'] != null
                ? (data['startTime'] as Timestamp).toDate().toIso8601String()
                : null,
            'endTime': data['endTime'] != null
                ? (data['endTime'] as Timestamp).toDate().toIso8601String()
                : null,
            'color': data['color'] as String? ?? '#6366F1',
            'visibility': data['visibility'] as String? ?? 'private',
            'userId': data['userId'] as String?,
          });
        } catch (e) {
          print('EventService: 일정 파싱 오류 - ${doc.id}: $e');
          rethrow;
        }
      }).toList();

      // 다른 사용자의 공개 일정 (collectionGroup 쿼리는 인덱스가 필요할 수 있음)
      List<Event> publicEvents = [];
      try {
        final publicEventsQuery = await _firestore
            .collectionGroup('events')
            .where('visibility', isEqualTo: 'public')
            .where('userId', isNotEqualTo: user.uid)
            .get();

        print('EventService: 공개 일정 ${publicEventsQuery.docs.length}개 발견');

        publicEvents = publicEventsQuery.docs.map((doc) {
          final data = doc.data();
          return Event.fromJson({
            'id': doc.id,
            'title': data['title'] as String,
            'description': data['description'] as String,
            'date': (data['date'] as Timestamp).toDate().toIso8601String(),
            'startTime': data['startTime'] != null
                ? (data['startTime'] as Timestamp).toDate().toIso8601String()
                : null,
            'endTime': data['endTime'] != null
                ? (data['endTime'] as Timestamp).toDate().toIso8601String()
                : null,
            'color': data['color'] as String? ?? '#6366F1',
            'visibility': data['visibility'] as String? ?? 'private',
            'userId': data['userId'] as String?,
          });
        }).toList();
      } catch (e) {
        print('EventService: 공개 일정 조회 오류 (무시됨): $e');
        // collectionGroup 쿼리 실패 시 무시하고 사용자 일정만 반환
      }

      final allEvents = [...userEvents, ...publicEvents];
      print('EventService: 총 ${allEvents.length}개 일정 로드 완료');
      return allEvents;
    } catch (e) {
      print('EventService: 일정 로드 오류: $e');
      return [];
    }
  }

  // 일정 추가
  static Future<void> addEvent(Event event) async {
    final user = AuthService.currentUser;
    if (user == null) throw Exception('로그인이 필요합니다');

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('events')
          .doc(event.id)
          .set({
            'title': event.title,
            'description': event.description,
            'date': Timestamp.fromDate(event.date),
            'startTime': event.startTime != null
                ? Timestamp.fromDate(event.startTime!)
                : null,
            'endTime': event.endTime != null
                ? Timestamp.fromDate(event.endTime!)
                : null,
            'color': event.color,
            'visibility': event.visibility,
            'userId': user.uid,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      rethrow;
    }
  }

  // 일정 삭제
  static Future<void> deleteEvent(String eventId) async {
    final user = AuthService.currentUser;
    if (user == null) throw Exception('로그인이 필요합니다');

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('events')
          .doc(eventId)
          .delete();
    } catch (e) {
      rethrow;
    }
  }

  // 일정 업데이트
  static Future<void> updateEvent(Event event) async {
    final user = AuthService.currentUser;
    if (user == null) throw Exception('로그인이 필요합니다');

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('events')
          .doc(event.id)
          .update({
            'title': event.title,
            'description': event.description,
            'date': Timestamp.fromDate(event.date),
            'startTime': event.startTime != null
                ? Timestamp.fromDate(event.startTime!)
                : null,
            'endTime': event.endTime != null
                ? Timestamp.fromDate(event.endTime!)
                : null,
            'color': event.color,
            'visibility': event.visibility,
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      rethrow;
    }
  }

  // 특정 날짜의 일정 가져오기
  static Future<List<Event>> getEventsForDate(DateTime date) async {
    final events = await loadEvents();
    return events.where((e) {
      return e.date.year == date.year &&
          e.date.month == date.month &&
          e.date.day == date.day;
    }).toList();
  }
}
