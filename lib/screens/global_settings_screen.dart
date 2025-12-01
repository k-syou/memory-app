import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class GlobalSettingsScreen extends StatefulWidget {
  final Function(bool) onThemeChanged;

  const GlobalSettingsScreen({super.key, required this.onThemeChanged});

  @override
  State<GlobalSettingsScreen> createState() => _GlobalSettingsScreenState();
}

class _GlobalSettingsScreenState extends State<GlobalSettingsScreen> {
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

  Future<void> _toggleDarkMode(bool value) async {
    setState(() {
      _isDarkMode = value;
    });
    await StorageService.saveDarkMode(value);
    widget.onThemeChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          '설정',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
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
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  value: _isDarkMode,
                  onChanged: _toggleDarkMode,
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
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
}
