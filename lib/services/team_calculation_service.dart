class TeamCalculationService {
  /// 참가자 이름 텍스트에서 인원수 계산
  static int calculateParticipantCount(String namesText) {
    final names = namesText
        .split(',')
        .map((n) => n.trim())
        .where((n) => n.isNotEmpty)
        .toList();
    return names.length;
  }

  /// 선택 가능한 팀 개수 목록 생성
  static List<int> generateTeamCountOptions(int participantCount, {int maxTeams = 20}) {
    final effectiveMax = participantCount > 0
        ? (participantCount < maxTeams ? participantCount : maxTeams)
        : maxTeams;
    
    if (effectiveMax < 2) return [2];
    
    return List.generate(
      effectiveMax - 1,
      (index) => index + 2,
    );
  }

  /// 현재 팀 개수 값 검증 및 조정
  static int validateAndAdjustTeamCount(
    String numTeamsText,
    int participantCount, {
    int minValue = 2,
  }) {
    int currentValue = minValue;
    try {
      final numTeamsTextTrimmed = numTeamsText.trim();
      if (numTeamsTextTrimmed.isNotEmpty) {
        currentValue = int.parse(numTeamsTextTrimmed);
        if (currentValue < minValue) currentValue = minValue;
        if (participantCount > 0 && currentValue > participantCount) {
          currentValue = participantCount;
        }
      }
    } catch (e) {
      currentValue = minValue;
    }
    return currentValue;
  }

  /// 총 인원수로 나누어 떨어지는 팀 개수 찾기 (총 인원수 제외)
  static List<int> getRecommendedTeamCounts(int participantCount) {
    final recommendedTeams = <int>[];
    if (participantCount > 0) {
      for (int i = 2; i < participantCount; i++) {
        if (participantCount % i == 0) {
          recommendedTeams.add(i);
        }
      }
    }
    return recommendedTeams;
  }

  /// 팀 개수 옵션에 현재 값이 없으면 추가
  static List<int> ensureCurrentValueInOptions(
    List<int> options,
    int currentValue, {
    int minValue = 2,
  }) {
    if (!options.contains(currentValue) && currentValue >= minValue) {
      options.add(currentValue);
      options.sort();
    }
    return options;
  }
}

