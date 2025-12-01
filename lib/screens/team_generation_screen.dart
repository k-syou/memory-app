import 'package:flutter/material.dart';
import 'package:memory_app/services/settings_default_service.dart';
import '../models/team_maker.dart';
import '../services/storage_service.dart';
import 'team_generation_settings_screen.dart';

class TeamGenerationScreen extends StatefulWidget {
  final Function(bool) onThemeChanged;

  const TeamGenerationScreen({super.key, required this.onThemeChanged});

  @override
  State<TeamGenerationScreen> createState() => _TeamGenerationScreenState();
}

class _TeamGenerationScreenState extends State<TeamGenerationScreen> {
  final TeamMaker _teamMaker = TeamMaker();
  List<List<String>> _teams = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _clearTeams() {
    setState(() {
      _teams = [];
      _errorMessage = null;
    });
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await StorageService.loadAllSettings();

      setState(() {
        final names = settings['names'] as List<String>;
        // 기본값이 없거나 비어있으면 기본값 사용
        if (names.isEmpty) {
          _teamMaker.addNames(SettingsDefaultService.defaultNames);
        } else {
          _teamMaker.addNames(names);
        }
        _teamMaker.setNumTeams(settings['numTeams'] as int);
        _teamMaker.setTeamNames(settings['teamNames'] as List<String>);
        _teamMaker.setTeamLeaders(settings['teamLeaders'] as List<String>);

        // mustTogether 설정
        final mustTogether =
            settings['mustTogether'] as List<Map<String, String>>;
        for (var pair in mustTogether) {
          _teamMaker.addMustTogether(pair['name1']!, pair['name2']!);
        }

        // mustSeparate 설정
        final mustSeparate =
            settings['mustSeparate'] as List<Map<String, String>>;
        for (var pair in mustSeparate) {
          _teamMaker.addMustSeparate(pair['name1']!, pair['name2']!);
        }
      });
    } catch (e) {
      // 설정이 없으면 기본값 사용
      setState(() {
        _teamMaker.addNames(SettingsDefaultService.defaultNames);
        _teamMaker.setNumTeams(2);
      });
    }
  }

  Future<void> _generateTeams() async {
    if (_teamMaker.names.isEmpty) {
      setState(() {
        _errorMessage = '설정에서 참가자 이름을 먼저 입력해주세요!';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Future.delayed(
        const Duration(milliseconds: 300),
      ); // UI 업데이트를 위한 짧은 지연

      final teams = _teamMaker.generateTeams();

      setState(() {
        _teams = teams;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey.shade50,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Image.asset(
          'assets/memory_logo.png',
          height: 32,
          fit: BoxFit.contain,
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.settings_rounded),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TeamGenerationSettingsScreen(
                      onThemeChanged: widget.onThemeChanged,
                    ),
                  ),
                );
                _loadSettings();
              },
            ),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '팀을 생성하는 중...',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: isDark ? const Color(0xFF121212) : Colors.grey.shade50,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 팀 굴리기 버튼과 초기화 버튼
            Row(
              children: [
                // 팀 굴리기 버튼
                Expanded(
                  child: Container(
                    height: 90,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF667EEA), const Color(0xFF764BA2)]
                            : [
                                const Color(0xFF6366F1),
                                const Color(0xFF8B5CF6),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: isDark
                          ? [] // 다크모드에서는 그림자 제거
                          : [
                              BoxShadow(
                                color: const Color(0xFF6366F1).withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _generateTeams,
                        borderRadius: BorderRadius.circular(20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.casino_rounded,
                                size: 32,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Text(
                              '팀원 굴리기',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // 초기화 버튼
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: isDark
                        ? [] // 다크모드에서는 그림자 제거
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _clearTeams,
                      borderRadius: BorderRadius.circular(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.refresh_rounded,
                            size: 32,
                            color: isDark
                                ? Colors.grey.shade300
                                : Colors.grey.shade700,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '초기화',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.grey.shade300
                                  : Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 에러 메시지
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.shade200, width: 1.5),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.error_outline_rounded,
                        color: Colors.red,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // 팀 결과 표시
            if (_teams.isNotEmpty) ...[
              // const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  '팀 구성 결과',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              ..._buildTeamCards(),
            ] else if (_teamMaker.names.isEmpty) ...[
              const SizedBox(height: 60),
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.info_outline_rounded,
                        size: 48,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '설정에서 참가자 이름을\n먼저 입력해주세요!',
                      style: TextStyle(
                        fontSize: 17,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
            // Container(height: 100, color: Colors.red),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTeamCards() {
    final gradients = [
      [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
      [Color(0xFF4ECDC4), Color(0xFF6EDDD6)],
      [Color(0xFF45B7D1), Color(0xFF6BC5E0)],
      [Color(0xFFFFA07A), Color(0xFFFFB89A)],
      [Color(0xFF9B59B6), Color(0xFFB47DD6)],
      [Color(0xFF1ABC9C), Color(0xFF3DD4B8)],
    ];

    return _teams.asMap().entries.map((entry) {
      final index = entry.key;
      final team = entry.value;
      final teamName = index < _teamMaker.teamNames.length
          ? _teamMaker.teamNames[index]
          : '팀 ${index + 1}';
      final gradient = gradients[index % gradients.length];

      return Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          teamName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${team.length}명',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 3.2,
                        ),
                    itemCount: team.length,
                    itemBuilder: (context, memberIndex) {
                      final member = team[memberIndex];
                      final isLeader = _teamMaker.teamLeaders.contains(member);

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              gradient[0].withOpacity(0.1),
                              gradient[1].withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: gradient[0].withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: gradient),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: gradient[0].withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  '${memberIndex + 1}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                member,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: isLeader
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.color,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isLeader)
                              Container(
                                width: 24,
                                height: 24,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade100,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.star_rounded,
                                  size: 16,
                                  color: Colors.amber,
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }
}
