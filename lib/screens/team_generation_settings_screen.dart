import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/settings_validation_service.dart';
import '../services/team_calculation_service.dart';
import '../services/settings_default_service.dart';

class TeamGenerationSettingsScreen extends StatefulWidget {
  final Function(bool) onThemeChanged;

  const TeamGenerationSettingsScreen({super.key, required this.onThemeChanged});

  @override
  State<TeamGenerationSettingsScreen> createState() =>
      _TeamGenerationSettingsScreenState();
}

class _TeamGenerationSettingsScreenState
    extends State<TeamGenerationSettingsScreen> {
  final TextEditingController _namesController = TextEditingController();
  final TextEditingController _numTeamsController = TextEditingController();
  final TextEditingController _teamNamesController = TextEditingController();
  final TextEditingController _teamLeadersController = TextEditingController();

  List<Map<String, String>> _mustTogether = [];
  List<Map<String, String>> _mustSeparate = [];

  final TextEditingController _togetherName1Controller =
      TextEditingController();
  final TextEditingController _togetherName2Controller =
      TextEditingController();
  final TextEditingController _separateName1Controller =
      TextEditingController();
  final TextEditingController _separateName2Controller =
      TextEditingController();

  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final isDark = await StorageService.loadDarkMode();
    setState(() {
      _isDarkMode = isDark;
    });
  }

  Future<void> _toggleDarkMode(bool value) async {
    setState(() {
      _isDarkMode = value;
    });
    await StorageService.saveDarkMode(value);
    widget.onThemeChanged(value);
  }

  @override
  void dispose() {
    _namesController.dispose();
    _numTeamsController.dispose();
    _teamNamesController.dispose();
    _teamLeadersController.dispose();
    _togetherName1Controller.dispose();
    _togetherName2Controller.dispose();
    _separateName1Controller.dispose();
    _separateName2Controller.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await StorageService.loadAllSettings();

      setState(() {
        final names = settings['names'] as List<String>;
        // 기본값이 없거나 비어있으면 기본값 사용
        if (SettingsDefaultService.isEmpty(names)) {
          _namesController.text = SettingsDefaultService.getDefaultNamesText();
        } else {
          _namesController.text = names.join(', ');
        }

        final numTeams = settings['numTeams'] as int;
        _numTeamsController.text = numTeams.toString();

        final teamNames = settings['teamNames'] as List<String>;
        _teamNamesController.text = teamNames.join(', ');

        final teamLeaders = settings['teamLeaders'] as List<String>;
        _teamLeadersController.text = teamLeaders.join(', ');

        _mustTogether = settings['mustTogether'] as List<Map<String, String>>;
        _mustSeparate = settings['mustSeparate'] as List<Map<String, String>>;
      });
    } catch (e) {
      // 기본값 설정
      _namesController.text = SettingsDefaultService.getDefaultNamesText();
      _numTeamsController.text =
          SettingsDefaultService.getDefaultNumTeamsText();
    }
  }

  Future<void> _saveSettings() async {
    // 이름 파싱
    final names = SettingsValidationService.parseNames(_namesController.text);

    // 팀 개수 파싱
    final numTeams = SettingsValidationService.parseNumTeams(
      _numTeamsController.text,
    );

    // 팀 이름 파싱
    final teamNames = SettingsValidationService.parseTeamNames(
      _teamNamesController.text,
    );

    // 팀장 파싱
    final teamLeaders = SettingsValidationService.parseTeamLeaders(
      _teamLeadersController.text,
    );

    // 설정 저장
    await StorageService.saveAllSettings(
      names: names,
      numTeams: numTeams,
      teamNames: teamNames,
      teamLeaders: teamLeaders,
      mustTogether: _mustTogether,
      mustSeparate: _mustSeparate,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('설정이 저장되었습니다!', textAlign: TextAlign.center),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  void _addMustTogether() {
    final name1 = _togetherName1Controller.text.trim();
    final name2 = _togetherName2Controller.text.trim();

    if (!SettingsValidationService.validateNamePair(name1, name2)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('두 명의 이름을 모두 입력해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _mustTogether.add({'name1': name1, 'name2': name2});
      _togetherName1Controller.clear();
      _togetherName2Controller.clear();
    });
  }

  void _removeMustTogether(int index) {
    setState(() {
      _mustTogether.removeAt(index);
    });
  }

  void _addMustSeparate() {
    final name1 = _separateName1Controller.text.trim();
    final name2 = _separateName2Controller.text.trim();

    if (!SettingsValidationService.validateNamePair(name1, name2)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('두 명의 이름을 모두 입력해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _mustSeparate.add({'name1': name1, 'name2': name2});
      _separateName1Controller.clear();
      _separateName2Controller.clear();
    });
  }

  void _removeMustSeparate(int index) {
    setState(() {
      _mustSeparate.removeAt(index);
    });
  }

  Future<void> _showResetConfirmDialog() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            '초기화 확인',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            '모든 설정을 초기값으로 되돌리시겠습니까?\n\n초기화 후에는:\n• 참가자 이름이 기본값으로 설정됩니다\n• 팀 개수가 2로 설정됩니다\n• 다른 설정들은 모두 초기화됩니다',
            style: TextStyle(
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
              fontSize: 15,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                '취소',
                style: TextStyle(
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('초기화'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      _resetToDefaults();
    }
  }

  Future<void> _resetToDefaults() async {
    setState(() {
      // 기본값으로 초기화
      _namesController.text = SettingsDefaultService.getDefaultNamesText();
      _numTeamsController.text =
          SettingsDefaultService.getDefaultNumTeamsText();
      _teamNamesController.clear();
      _teamLeadersController.clear();
      _mustTogether.clear();
      _mustSeparate.clear();
      _togetherName1Controller.clear();
      _togetherName2Controller.clear();
      _separateName1Controller.clear();
      _separateName2Controller.clear();
    });

    // 저장
    await _saveSettings();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('설정이 초기값으로 되돌아갔습니다!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF121212), const Color(0xFF1A1A1A)]
                : [Colors.white, Colors.grey.shade50],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 다크모드 설정
              _buildSection(
                title: '다크모드',
                subtitle: '어두운 테마로 전환합니다',
                isRequired: false,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).inputDecorationTheme.fillColor ??
                        (isDark
                            ? const Color(0xFF2C2C2C)
                            : const Color(0xFFe4e1e9)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SwitchListTile(
                    title: const Text('다크모드'),
                    subtitle: Text(
                      _isDarkMode ? '켜짐' : '꺼짐',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    value: _isDarkMode,
                    onChanged: _toggleDarkMode,
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 참가자 이름
              _buildSection(
                title: '참가자 이름',
                subtitle: '쉼표로 구분하여 입력하세요',
                isRequired: true,
                child: TextField(
                  controller: _namesController,
                  decoration: const InputDecoration(
                    hintText: '예: 훈,솜,민,샤,코,징,권,규,누,도,근,별,나,혁',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ),

              const SizedBox(height: 24),

              // 팀 개수
              _buildSection(
                title: '팀 개수',
                subtitle: '생성할 팀의 개수를 선택하세요',
                isRequired: true,
                child: _buildTeamCountDropdown(),
              ),

              const SizedBox(height: 24),

              // 팀 이름
              _buildSection(
                title: '팀 이름',
                subtitle: '쉼표로 구분하여 입력하세요. 비워두면 자동 생성됩니다.',
                isRequired: false,
                child: TextField(
                  controller: _teamNamesController,
                  decoration: const InputDecoration(
                    hintText: '예: 팀 A, 팀 B',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ),

              const SizedBox(height: 24),

              // 팀장
              _buildSection(
                title: '팀장',
                subtitle: '쉼표로 구분하여 입력하세요. 팀당 한 명씩 배치됩니다.',
                isRequired: false,
                child: TextField(
                  controller: _teamLeadersController,
                  decoration: const InputDecoration(
                    hintText: '예: 별,규',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ),

              const SizedBox(height: 24),

              // 반드시 함께해야 하는 사람
              _buildSection(
                title: '반드시 함께해야 하는 사람',
                subtitle: '같은 팀에 배치되어야 하는 사람들을 설정하세요.',
                isRequired: false,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _togetherName1Controller,
                            decoration: const InputDecoration(
                              labelText: '이름 1',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('↔'),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _togetherName2Controller,
                            decoration: const InputDecoration(
                              labelText: '이름 2',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.add_rounded,
                              color: Colors.green.shade700,
                            ),
                            onPressed: _addMustTogether,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ..._mustTogether.asMap().entries.map((entry) {
                      final index = entry.key;
                      final pair = entry.value;
                      final isDark =
                          Theme.of(context).brightness == Brightness.dark;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF2C2C2C)
                              : const Color(0xFFe4e1e9),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(
                                isDark ? 0.3 : 0.05,
                              ),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          title: Text(
                            '${pair['name1']} ↔ ${pair['name2']}',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          trailing: Container(
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.red.shade400,
                              ),
                              onPressed: () => _removeMustTogether(index),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 반드시 분리해야 하는 사람
              _buildSection(
                title: '반드시 분리해야 하는 사람',
                subtitle: '다른 팀에 배치되어야 하는 사람들을 설정하세요.',
                isRequired: false,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _separateName1Controller,
                            decoration: const InputDecoration(
                              labelText: '이름 1',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('✗'),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _separateName2Controller,
                            decoration: const InputDecoration(
                              labelText: '이름 2',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.add_rounded,
                              color: Colors.red.shade700,
                            ),
                            onPressed: _addMustSeparate,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ..._mustSeparate.asMap().entries.map((entry) {
                      final index = entry.key;
                      final pair = entry.value;
                      final isDark =
                          Theme.of(context).brightness == Brightness.dark;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF2C2C2C)
                              : const Color(0xFFe4e1e9),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(
                                isDark ? 0.3 : 0.05,
                              ),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          title: Text(
                            '${pair['name1']} ✗ ${pair['name2']}',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          trailing: Container(
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.red.shade400,
                              ),
                              onPressed: () => _removeMustSeparate(index),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 저장 버튼
              Container(
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF667EEA), const Color(0xFF764BA2)]
                        : [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? const Color(0xFF667EEA).withOpacity(0.3)
                          : const Color(0xFF6366F1).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _saveSettings,
                    borderRadius: BorderRadius.circular(16),
                    child: const Center(
                      child: Text(
                        '저장',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // 갤럭시 하단 부분 빈 공간 추가
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String subtitle,
    required Widget child,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (isRequired)
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Text(
                  '*',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildTeamCountDropdown() {
    // 참가자 이름 파싱하여 인원수 확인
    final participantCount = TeamCalculationService.calculateParticipantCount(
      _namesController.text,
    );

    // 현재 선택된 팀 개수
    final currentValue = TeamCalculationService.validateAndAdjustTeamCount(
      _numTeamsController.text,
      participantCount,
    );

    // 선택 가능한 팀 개수 목록 생성
    var teamCountOptions = TeamCalculationService.generateTeamCountOptions(
      participantCount,
    );

    // 현재 값이 목록에 없으면 추가
    teamCountOptions = TeamCalculationService.ensureCurrentValueInOptions(
      teamCountOptions,
      currentValue,
    );

    // 총 인원수로 나누어 떨어지는 팀 개수 찾기 (총 인원수 제외)
    final recommendedTeams = TeamCalculationService.getRecommendedTeamCounts(
      participantCount,
    );

    return DropdownButtonFormField<int>(
      value: currentValue,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      items: teamCountOptions.map((count) {
        final isRecommended = recommendedTeams.contains(count);
        return DropdownMenuItem<int>(
          value: count,
          child: Row(
            children: [
              Text('$count팀'),
              if (isRecommended) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '추천',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _numTeamsController.text = value.toString();
          });
        }
      },
      hint: const Text('팀 개수를 선택하세요'),
      isExpanded: true,
    );
  }
}
