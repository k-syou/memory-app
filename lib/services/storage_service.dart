import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyNames = 'team_names';
  static const String _keyNumTeams = 'num_teams';
  static const String _keyTeamNames = 'team_names_list';
  static const String _keyTeamLeaders = 'team_leaders';
  static const String _keyMustTogether = 'must_together';
  static const String _keyMustSeparate = 'must_separate';
  static const String _keyDarkMode = 'dark_mode';

  // 이름 리스트 저장
  static Future<void> saveNames(List<String> names) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyNames, names);
  }

  // 이름 리스트 로드
  static Future<List<String>> loadNames() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyNames) ?? [];
  }

  // 팀 개수 저장
  static Future<void> saveNumTeams(int numTeams) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyNumTeams, numTeams);
  }

  // 팀 개수 로드
  static Future<int> loadNumTeams() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyNumTeams) ?? 2;
  }

  // 팀 이름 리스트 저장
  static Future<void> saveTeamNamesList(List<String> teamNames) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyTeamNames, teamNames);
  }

  // 팀 이름 리스트 로드
  static Future<List<String>> loadTeamNamesList() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyTeamNames) ?? [];
  }

  // 팀장 리스트 저장
  static Future<void> saveTeamLeaders(List<String> leaders) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyTeamLeaders, leaders);
  }

  // 팀장 리스트 로드
  static Future<List<String>> loadTeamLeaders() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyTeamLeaders) ?? [];
  }

  // 반드시 함께해야 하는 사람들 저장
  static Future<void> saveMustTogether(List<Map<String, String>> pairs) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(pairs);
    await prefs.setString(_keyMustTogether, jsonString);
  }

  // 반드시 함께해야 하는 사람들 로드
  static Future<List<Map<String, String>>> loadMustTogether() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyMustTogether);
    if (jsonString == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((e) => Map<String, String>.from(e)).toList();
    } catch (e) {
      return [];
    }
  }

  // 반드시 분리해야 하는 사람들 저장
  static Future<void> saveMustSeparate(List<Map<String, String>> pairs) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(pairs);
    await prefs.setString(_keyMustSeparate, jsonString);
  }

  // 반드시 분리해야 하는 사람들 로드
  static Future<List<Map<String, String>>> loadMustSeparate() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyMustSeparate);
    if (jsonString == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((e) => Map<String, String>.from(e)).toList();
    } catch (e) {
      return [];
    }
  }

  // 모든 설정 로드
  static Future<Map<String, dynamic>> loadAllSettings() async {
    return {
      'names': await loadNames(),
      'numTeams': await loadNumTeams(),
      'teamNames': await loadTeamNamesList(),
      'teamLeaders': await loadTeamLeaders(),
      'mustTogether': await loadMustTogether(),
      'mustSeparate': await loadMustSeparate(),
    };
  }

  // 다크모드 저장
  static Future<void> saveDarkMode(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDarkMode, isDarkMode);
  }

  // 다크모드 로드
  static Future<bool> loadDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDarkMode) ?? false;
  }

  // 모든 설정 저장
  static Future<void> saveAllSettings({
    required List<String> names,
    required int numTeams,
    required List<String> teamNames,
    required List<String> teamLeaders,
    required List<Map<String, String>> mustTogether,
    required List<Map<String, String>> mustSeparate,
  }) async {
    await Future.wait([
      saveNames(names),
      saveNumTeams(numTeams),
      saveTeamNamesList(teamNames),
      saveTeamLeaders(teamLeaders),
      saveMustTogether(mustTogether),
      saveMustSeparate(mustSeparate),
    ]);
  }
}

