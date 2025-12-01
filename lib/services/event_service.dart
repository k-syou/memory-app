import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event.dart';

class EventService {
  static const String _keyEvents = 'events';

  // 모든 일정 저장
  static Future<void> saveEvents(List<Event> events) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = events.map((e) => e.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await prefs.setString(_keyEvents, jsonString);
  }

  // 모든 일정 로드
  static Future<List<Event>> loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyEvents);
    if (jsonString == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((e) => Event.fromJson(Map<String, dynamic>.from(e))).toList();
    } catch (e) {
      return [];
    }
  }

  // 일정 추가
  static Future<void> addEvent(Event event) async {
    final events = await loadEvents();
    events.add(event);
    await saveEvents(events);
  }

  // 일정 삭제
  static Future<void> deleteEvent(String eventId) async {
    final events = await loadEvents();
    events.removeWhere((e) => e.id == eventId);
    await saveEvents(events);
  }

  // 일정 업데이트
  static Future<void> updateEvent(Event event) async {
    final events = await loadEvents();
    final index = events.indexWhere((e) => e.id == event.id);
    if (index != -1) {
      events[index] = event;
      await saveEvents(events);
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

