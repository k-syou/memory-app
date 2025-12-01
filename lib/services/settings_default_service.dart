class SettingsDefaultService {
  /// 기본 참가자 이름 리스트
  static const List<String> defaultNames = [
    '훈',
    '솜',
    '민',
    '샤',
    '코',
    '징',
    '권',
    '규',
    '누',
    '도',
    '근',
    '별',
    '나',
    '혁',
  ];

  /// 기본 참가자 이름을 텍스트 형식으로 반환
  static String getDefaultNamesText() {
    return defaultNames.join(', ');
  }

  /// 기본 팀 개수
  static const int defaultNumTeams = 2;

  /// 기본 팀 개수를 텍스트로 반환
  static String getDefaultNumTeamsText() {
    return defaultNumTeams.toString();
  }

  /// 기본값이 비어있는지 확인
  static bool isEmpty(List<String> names) {
    return names.isEmpty;
  }
}
