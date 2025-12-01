import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class GlobalSettingsScreen extends StatefulWidget {
  final Function(bool) onThemeChanged;

  const GlobalSettingsScreen({super.key, required this.onThemeChanged});

  @override
  State<GlobalSettingsScreen> createState() => _GlobalSettingsScreenState();
}

class _GlobalSettingsScreenState extends State<GlobalSettingsScreen> {
  bool _isDarkMode = false;
  final _displayNameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
    _loadUserData();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _loadThemeMode() async {
    final isDark = await StorageService.loadDarkMode();
    if (mounted) {
      setState(() {
        _isDarkMode = isDark;
      });
    }
  }

  Future<void> _loadUserData() async {
    final userData = await AuthService.getUserData();
    final displayName =
        userData?['displayName'] as String? ??
        AuthService.currentUser?.displayName ??
        '';
    if (mounted) {
      setState(() {
        _displayNameController.text = displayName;
      });
    }
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
            const SizedBox(height: 20),
            // 닉네임 설정
            _buildSection(
              title: '닉네임',
              subtitle: '표시될 이름을 설정합니다',
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _displayNameController,
                          decoration: const InputDecoration(
                            hintText: '닉네임을 입력하세요',
                            border: InputBorder.none,
                          ),
                          enabled: !_isLoading,
                        ),
                      ),
                      IconButton(
                        icon: _isLoading
                            ? const SizedBox(
                                // width: 30,
                                // height: 30,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Container(
                                decoration: const BoxDecoration(
                                  color: Color(0xFFC8E6C9),
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(8),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.green,
                                  size: 24,
                                ),
                              ),
                        onPressed: _isLoading
                            ? null
                            : () async {
                                if (_displayNameController.text
                                    .trim()
                                    .isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('닉네임을 입력해주세요'),
                                    ),
                                  );
                                  return;
                                }

                                setState(() {
                                  _isLoading = true;
                                });

                                try {
                                  await AuthService.updateUserProfile(
                                    displayName: _displayNameController.text
                                        .trim(),
                                  );
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('닉네임이 변경되었습니다'),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('오류가 발생했습니다: $e')),
                                    );
                                  }
                                } finally {
                                  if (mounted) {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  }
                                }
                              },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
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
            const SizedBox(height: 24),
            // 로그아웃 버튼
            _buildSection(
              title: '계정',
              subtitle: '계정 관련 설정입니다',
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
                child: ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    '로그아웃',
                    style: TextStyle(color: Colors.red),
                  ),
                  subtitle: Text(
                    AuthService.currentUser?.email ?? '',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('로그아웃'),
                        content: const Text('정말 로그아웃하시겠습니까?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('취소'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text(
                              '로그아웃',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true && mounted) {
                      // 로그아웃 처리
                      await AuthService.signOut();

                      // 모든 화면을 제거하고 루트(로그인 화면)로 이동
                      if (mounted) {
                        Navigator.of(
                          context,
                          rootNavigator: true,
                        ).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(
                              onThemeChanged: widget.onThemeChanged,
                            ),
                          ),
                          (route) => false,
                        );
                      }
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 40),
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
