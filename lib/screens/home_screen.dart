import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import 'team_generation_screen.dart';
import 'global_settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(bool) onThemeChanged;

  const HomeScreen({super.key, required this.onThemeChanged});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final isDark = await StorageService.loadDarkMode();
    setState(() {
      _isDarkMode = isDark;
    });
  }

  void _toggleTheme(bool isDark) {
    setState(() {
      _isDarkMode = isDark;
    });
    StorageService.saveDarkMode(isDark);
    widget.onThemeChanged(isDark);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey.shade50,
      appBar: AppBar(
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(
              isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            ),
            onPressed: () {
              final newMode = !_isDarkMode;
              _toggleTheme(newMode);
            },
            tooltip: isDark ? '라이트 모드로 전환' : '다크 모드로 전환',
          ),
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        GlobalSettingsScreen(onThemeChanged: _toggleTheme),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: Container(
        color: isDark ? const Color(0xFF121212) : Colors.grey.shade50,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              // 메인 기능 카드
              _buildMenuCard(
                context: context,
                isDark: isDark,
                title: '팀 생성',
                subtitle: '팀원을 랜덤으로 배치하여 팀을 생성합니다',
                icon: Icons.group_rounded,
                gradient: isDark
                    ? [const Color(0xFF667EEA), const Color(0xFF764BA2)]
                    : [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          TeamGenerationScreen(onThemeChanged: _toggleTheme),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              // 추가 기능 카드들 (향후 확장 가능)
              _buildMenuCard(
                context: context,
                isDark: isDark,
                title: '기능 추가 예정',
                subtitle: '추가 기능이 여기에 표시됩니다',
                icon: Icons.add_circle_outline_rounded,
                gradient: isDark
                    ? [Colors.grey.shade700, Colors.grey.shade600]
                    : [Colors.grey.shade500, Colors.grey.shade400],
                onTap: () {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('준비 중인 기능입니다')));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required bool isDark,
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: gradient[0].withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 32, color: Colors.white),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white.withOpacity(0.8),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
