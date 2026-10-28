import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Central theme mode controller for TenaWise with persistent local storage.
/// Defaults to ThemeMode.system.
class AppThemeMode {
  AppThemeMode._();

  static const String _prefKey = 'tenawise_theme_mode';

  static final ValueNotifier<ThemeMode> themeModeNotifier =
      ValueNotifier<ThemeMode>(ThemeMode.light);

  static ThemeMode get themeMode => themeModeNotifier.value;

  static bool get isDark => themeModeNotifier.value == ThemeMode.dark;

  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedStr = prefs.getString(_prefKey) ?? 'light';
      if (savedStr == 'dark') {
        themeModeNotifier.value = ThemeMode.dark;
      } else if (savedStr == 'system') {
        themeModeNotifier.value = ThemeMode.system;
      } else {
        themeModeNotifier.value = ThemeMode.light;
      }
    } catch (_) {
      themeModeNotifier.value = ThemeMode.light;
    }
  }

  static Future<void> toggleTheme() async {
    final newMode = themeModeNotifier.value == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    themeModeNotifier.value = newMode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, newMode == ThemeMode.dark ? 'dark' : 'light');
    } catch (_) {}
  }
}

