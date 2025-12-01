class SettingsValidationService {
  /// 이름 텍스트를 파싱하여 리스트로 변환
  static List<String> parseNames(String namesText) {
    return namesText
        .split(',')
        .map((n) => n.trim())
        .where((n) => n.isNotEmpty)
        .toList();
  }

  /// 팀 개수 텍스트를 파싱하여 정수로 변환
  static int parseNumTeams(String numTeamsText, {int minValue = 2}) {
    try {
      final numTeams = int.parse(numTeamsText.trim());
      return numTeams < minValue ? minValue : numTeams;
    } catch (e) {
      return minValue;
    }
  }

  /// 팀 이름 텍스트를 파싱하여 리스트로 변환
  static List<String> parseTeamNames(String teamNamesText) {
    return teamNamesText
        .split(',')
        .map((n) => n.trim())
        .where((n) => n.isNotEmpty)
        .toList();
  }

  /// 팀장 텍스트를 파싱하여 리스트로 변환
  static List<String> parseTeamLeaders(String leadersText) {
    return leadersText
        .split(',')
        .map((n) => n.trim())
        .where((n) => n.isNotEmpty)
        .toList();
  }

  /// 이름 쌍 검증 (두 이름이 모두 입력되었는지 확인)
  static bool validateNamePair(String name1, String name2) {
    return name1.trim().isNotEmpty && name2.trim().isNotEmpty;
  }
}

