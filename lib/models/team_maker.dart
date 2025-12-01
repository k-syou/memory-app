import 'dart:math';

class TeamMaker {
  List<String> names = [];
  int numTeams = 2;
  List<Pair<String, String>> mustTogether = []; // 반드시 함께해야 하는 쌍
  List<Pair<String, String>> mustSeparate = []; // 반드시 분리해야 하는 쌍
  List<String> teamNames = []; // 팀 이름들
  List<String> teamLeaders = []; // 팀장 리스트 (팀당 한 명씩)

  void addNames(List<String> names) {
    this.names = names
        .where((name) => name.trim().isNotEmpty)
        .map((name) => name.trim())
        .toList();
  }

  void setNumTeams(int num) {
    numTeams = max(2, num);
  }

  void setTeamNames(List<String> names) {
    teamNames = names.take(numTeams).toList();
    // 부족한 경우 자동 생성
    while (teamNames.length < numTeams) {
      teamNames.add('팀 ${teamNames.length + 1}');
    }
  }

  void addMustTogether(String name1, String name2) {
    if (names.contains(name1) && names.contains(name2)) {
      mustTogether.add(Pair(name1, name2));
    }
  }

  void addMustSeparate(String name1, String name2) {
    if (names.contains(name1) && names.contains(name2)) {
      mustSeparate.add(Pair(name1, name2));
    }
  }

  void setTeamLeaders(List<String> names) {
    teamLeaders = [];
    for (var name in names) {
      name = name.trim();
      if (this.names.contains(name) && !teamLeaders.contains(name)) {
        teamLeaders.add(name);
      }
    }
  }

  void addTeamLeader(String name) {
    name = name.trim();
    if (names.contains(name) && !teamLeaders.contains(name)) {
      teamLeaders.add(name);
    }
  }

  ValidationResult validateConstraints(List<List<String>> teams) {
    List<String> errors = [];

    // 팀장이 각 팀에 한 명씩 있는지 확인
    if (teamLeaders.isNotEmpty) {
      if (teamLeaders.length > teams.length) {
        errors.add(
          '팀장 수(${teamLeaders.length})가 팀 개수(${teams.length})보다 많습니다!',
        );
      } else {
        // 각 팀장이 서로 다른 팀에 있는지 확인
        Map<String, int> leaderTeams = {};
        for (int idx = 0; idx < teams.length; idx++) {
          for (var leader in teamLeaders) {
            if (teams[idx].contains(leader)) {
              if (leaderTeams.containsKey(leader)) {
                errors.add('팀장 $leader이(가) 여러 팀에 배치되었습니다!');
              } else {
                leaderTeams[leader] = idx;
              }
            }
          }
        }

        // 모든 팀장이 배치되었는지 확인
        for (var leader in teamLeaders) {
          if (!leaderTeams.containsKey(leader)) {
            errors.add('팀장 $leader이(가) 배치되지 않았습니다!');
          }
        }
      }
    }

    // 반드시 함께해야 하는 사람들 확인
    for (var pair in mustTogether) {
      int? team1Idx;
      int? team2Idx;
      for (int idx = 0; idx < teams.length; idx++) {
        if (teams[idx].contains(pair.first)) {
          team1Idx = idx;
        }
        if (teams[idx].contains(pair.second)) {
          team2Idx = idx;
        }
      }
      if (team1Idx != team2Idx) {
        errors.add('${pair.first}과(와) ${pair.second}는 반드시 같은 팀이어야 합니다!');
      }
    }

    // 반드시 분리해야 하는 사람들 확인
    for (var pair in mustSeparate) {
      for (var team in teams) {
        if (team.contains(pair.first) && team.contains(pair.second)) {
          errors.add('${pair.first}과(와) ${pair.second}는 같은 팀에 있을 수 없습니다!');
        }
      }
    }

    return ValidationResult(errors.isEmpty, errors);
  }

  List<List<String>> generateTeams({int maxAttempts = 1000}) {
    if (names.length < numTeams) {
      throw Exception('인원 수(${names.length})가 팀 개수($numTeams)보다 적습니다!');
    }

    // 팀장 수가 팀 개수보다 많으면 오류
    if (teamLeaders.length > numTeams) {
      throw Exception('팀장 수(${teamLeaders.length})가 팀 개수($numTeams)보다 많습니다!');
    }

    final random = Random();
    List<List<String>>? bestTeams;

    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      // 이름 리스트를 섞기
      List<String> shuffled = List.from(names);
      shuffled.shuffle(random);

      // 팀 개수만큼 나누기
      List<List<String>> teams = List.generate(numTeams, (_) => []);

      // 각 팀의 목표 인원 수 계산 (전체 인원 / 팀 개수)
      int totalMembers = names.length;
      int baseMembersPerTeam = totalMembers ~/ numTeams; // 기본 인원 수
      int extraMembers = totalMembers % numTeams; // 추가 인원이 필요한 팀 수

      // 각 팀의 목표 인원 수 설정
      List<int> targetSizes = [];
      for (int i = 0; i < numTeams; i++) {
        int targetSize = baseMembersPerTeam + (i < extraMembers ? 1 : 0);
        targetSizes.add(targetSize);
      }

      // 팀장을 먼저 각 팀에 배치 (목표 인원 수를 고려하여 균등하게)
      List<int> teamIndices = List.generate(numTeams, (i) => i);
      teamIndices.shuffle(random);

      // 팀장을 배치할 때 목표 인원 수가 큰 팀부터 우선 배치
      teamIndices.sort((a, b) => targetSizes[b].compareTo(targetSizes[a]));

      for (int i = 0; i < teamLeaders.length && i < teamIndices.length; i++) {
        var leader = teamLeaders[i];
        if (shuffled.contains(leader)) {
          teams[teamIndices[i]].add(leader);
          shuffled.remove(leader);
        }
      }

      // 나머지 인원을 균등하게 배치
      // 각 팀이 목표 인원 수에 도달하도록 가장 적은 인원의 팀부터 채우기
      for (int i = 0; i < shuffled.length; i++) {
        // 가장 인원이 적고 목표 인원 수에 도달하지 않은 팀 찾기
        int bestTeamIndex = 0;
        int bestTeamSize = teams[0].length;
        bool bestTeamReachedTarget = teams[0].length >= targetSizes[0];

        for (int j = 1; j < numTeams; j++) {
          int currentSize = teams[j].length;
          bool reachedTarget = currentSize >= targetSizes[j];

          // 목표에 도달하지 않은 팀 우선
          if (!reachedTarget && bestTeamReachedTarget) {
            bestTeamIndex = j;
            bestTeamSize = currentSize;
            bestTeamReachedTarget = false;
          } else if (!reachedTarget && !bestTeamReachedTarget) {
            // 둘 다 목표에 도달하지 않았으면 더 적은 인원의 팀 선택
            if (currentSize < bestTeamSize) {
              bestTeamIndex = j;
              bestTeamSize = currentSize;
            }
          } else if (reachedTarget && bestTeamReachedTarget) {
            // 둘 다 목표에 도달했으면 더 적은 인원의 팀 선택
            if (currentSize < bestTeamSize) {
              bestTeamIndex = j;
              bestTeamSize = currentSize;
            }
          }
        }

        teams[bestTeamIndex].add(shuffled[i]);
      }

      // 제약 조건 검증
      var validation = validateConstraints(teams);
      if (validation.isValid) {
        return teams;
      }

      // 최선의 결과 저장 (에러가 적은 것)
      if (bestTeams == null ||
          validation.errors.length <
              validateConstraints(bestTeams).errors.length) {
        bestTeams = teams;
      }
    }

    // 최대 시도 횟수 초과 시 경고와 함께 반환
    return bestTeams ?? List.generate(numTeams, (_) => []);
  }
}

class Pair<T1, T2> {
  final T1 first;
  final T2 second;

  Pair(this.first, this.second);
}

class ValidationResult {
  final bool isValid;
  final List<String> errors;

  ValidationResult(this.isValid, this.errors);
}
