import 'package:flutter/material.dart';

class AppSettings extends ChangeNotifier {
  // Singleton pattern để gọi ở bất kỳ đâu
  static final AppSettings instance = AppSettings._internal();
  AppSettings._internal();

  // 1. Chế độ Tối / Sáng
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleDarkMode(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners(); // Cập nhật giao diện toàn app
  }

  // 2. Ngôn ngữ
  String _language = 'Tiếng Việt'; // 'Tiếng Việt' hoặc 'English'
  String get language => _language;

  void setLanguage(String lang) {
    _language = lang;
    notifyListeners();
  }

  // 3. Cỡ chữ (Text Scale Factor)
  String _fontSizeLabel = 'Vừa';
  double _textScaleFactor = 1.0;

  String get fontSizeLabel => _fontSizeLabel;
  double get textScaleFactor => _textScaleFactor;

  void setFontSize(String sizeLabel) {
    _fontSizeLabel = sizeLabel;
    if (sizeLabel == 'Nhỏ' || sizeLabel == 'Small') {
      _textScaleFactor = 0.85;
    } else if (sizeLabel == 'Lớn' || sizeLabel == 'Large') {
      _textScaleFactor = 1.2;
    } else {
      _textScaleFactor = 1.0;
    }
    notifyListeners();
  }

  // 4. Các trạng thái công tắc khác
  bool receiveNotifications = true;
  bool rememberLogin = true;

  void setNotifications(bool val) {
    receiveNotifications = val;
    notifyListeners();
  }

  void setRememberLogin(bool val) {
    rememberLogin = val;
    notifyListeners();
  }

  // Từ điển dịch thuật đơn giản đa ngôn ngữ
  String tr(String key) {
    final isEn = _language == 'English';
    final map = {
      'profile': isEn ? 'Profile' : 'Hồ sơ cá nhân (Thẻ thô sơ)',
      'settings': isEn ? 'Settings' : 'Cài đặt',
      'account': isEn ? 'ACCOUNT' : 'TÀI KHOẢN',
      'app': isEn ? 'APP' : 'ỨNG DỤNG',
      'notifications': isEn ? 'Receive Notifications' : 'Nhận thông báo',
      'darkMode': isEn ? 'Dark Mode' : 'Chế độ tối',
      'rememberLogin': isEn ? 'Remember Login' : 'Nhớ đăng nhập',
      'language': isEn ? 'Language' : 'Ngôn ngữ',
      'fontSize': isEn ? 'Font Size' : 'Cỡ chữ',
      'about': isEn ? 'About App' : 'Về ứng dụng',
      'logout': isEn ? 'Logout' : 'Đăng xuất',
      'login': isEn ? 'Login' : 'Đăng nhập',
      'register': isEn ? 'Register' : 'Đăng ký',
      'forgotPassword': isEn ? 'Forgot Password?' : 'Quên mật khẩu?',
      'confirmLogout': isEn ? 'Confirm Logout' : 'Xác nhận đăng xuất',
      'logoutMsg': isEn ? 'Are you sure you want to logout?' : 'Bạn có chắc chắn muốn đăng xuất không?',
      'cancel': isEn ? 'Cancel' : 'Hủy',
      'selectLang': isEn ? 'Select Language' : 'Chọn ngôn ngữ',
      'selectFontSize': isEn ? 'Select Font Size' : 'Chọn cỡ chữ',
      'small': isEn ? 'Small' : 'Nhỏ',
      'medium': isEn ? 'Medium' : 'Vừa',
      'large': isEn ? 'Large' : 'Lớn',
    };
    return map[key] ?? key;
  }
}