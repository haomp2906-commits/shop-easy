// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';

import 'app_settings.dart';
import 'login_screen.dart';
import 'thehoso.dart';

// Công tắc chế độ tối: main.dart lắng nghe biến này để đổi theme cả app ngay lập tức
final ValueNotifier<bool> darkModeNotifier = ValueNotifier<bool>(
  AppSettings.instance.isDarkMode,
);

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Hàm hiển thị bảng chọn BottomSheet (Chọn Ngôn ngữ, Cỡ chữ)
  void _showBottomSheetOption({
    required String title,
    required List<String> options,
    required String currentValue,
    required Function(String) onSelect,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(),
                ...options.map(
                  (option) => ListTile(
                    title: Text(option),
                    trailing: option == currentValue
                        ? const Icon(Icons.check, color: Colors.blue)
                        : null,
                    onTap: () {
                      onSelect(option);
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Hộp thoại xác nhận khi bấm nút Đăng xuất
  void _showLogoutDialog() {
    final settings = AppSettings.instance;
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(settings.tr('confirmLogout')),
          content: Text(settings.tr('logoutMsg')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(settings.tr('cancel')),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext); // Đóng Dialog
                // Xóa hết các màn hình đang mở và về màn hình Đăng nhập
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
              child: Text(settings.tr('logout')),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = AppSettings.instance;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          settings.tr('settings'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ================= NHÓM 1: TÀI KHOẢN =================
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              settings.tr('account'),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Theme.of(context).dividerColor),
            ),
            child: Column(
              children: [
                // 1. Nhận thông báo
                SwitchListTile(
                  title: Text(settings.tr('notifications')),
                  value: settings.receiveNotifications,
                  onChanged: (val) =>
                      setState(() => settings.setNotifications(val)),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),

                // 2. Chế độ Tối / Sáng (Thực thi toàn app ngay lập tức)
                SwitchListTile(
                  title: Text(settings.tr('darkMode')),
                  value: settings.isDarkMode,
                  onChanged: (val) {
                    setState(() => settings.toggleDarkMode(val));
                    darkModeNotifier.value = val; // báo cho main.dart đổi theme
                  },
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),

                // 3. Nhớ đăng nhập
                SwitchListTile(
                  title: Text(settings.tr('rememberLogin')),
                  value: settings.rememberLogin,
                  onChanged: (val) =>
                      setState(() => settings.setRememberLogin(val)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ================= NHÓM 2: ỨNG DỤNG =================
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              settings.tr('app'),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Theme.of(context).dividerColor),
            ),
            child: Column(
              children: [
                // 4. Đổi Ngôn ngữ
                ListTile(
                  title: Text(settings.tr('language')),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        settings.language,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                  onTap: () {
                    _showBottomSheetOption(
                      title: settings.tr('selectLang'),
                      options: ['Tiếng Việt', 'English'],
                      currentValue: settings.language,
                      onSelect: (val) =>
                          setState(() => settings.setLanguage(val)),
                    );
                  },
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),

                // 5. Đổi Cỡ chữ
                ListTile(
                  title: Text(settings.tr('fontSize')),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        settings.language == 'English'
                            ? (settings.fontSizeLabel == 'Nhỏ'
                                  ? 'Small'
                                  : settings.fontSizeLabel == 'Lớn'
                                  ? 'Large'
                                  : 'Medium')
                            : settings.fontSizeLabel,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                  onTap: () {
                    final options = settings.language == 'English'
                        ? ['Small', 'Medium', 'Large']
                        : ['Nhỏ', 'Vừa', 'Lớn'];
                    _showBottomSheetOption(
                      title: settings.tr('selectFontSize'),
                      options: options,
                      currentValue: settings.language == 'English'
                          ? (settings.fontSizeLabel == 'Nhỏ'
                                ? 'Small'
                                : settings.fontSizeLabel == 'Lớn'
                                ? 'Large'
                                : 'Medium')
                          : settings.fontSizeLabel,
                      onSelect: (val) =>
                          setState(() => settings.setFontSize(val)),
                    );
                  },
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),

                // 6. Về ứng dụng
                ListTile(
                  title: Text(settings.tr('about')),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'App Demo Cài đặt',
                      applicationVersion: '1.0.0',
                      applicationLegalese: 'Vương Hưng Lợi',
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // ================= 1. NÚT PROFILE (Nằm trên nút Đăng xuất) =================
          OutlinedButton(
            onPressed: () {
              // Chuyển sang trang TheHoSo khi bấm nút Profile
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TheHoSo()),
              );
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF1769D2)), // Viền xanh
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Profile',
              style: TextStyle(color: Color(0xFF1769D2), fontSize: 16),
            ),
          ),

          const SizedBox(height: 12),

          // ================= 2. NÚT ĐĂNG XUẤT (Viền đỏ) =================
          OutlinedButton(
            onPressed: _showLogoutDialog, // Gọi Dialog xác nhận đăng xuất
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red), // Viền đỏ
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              settings.tr('logout'),
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
