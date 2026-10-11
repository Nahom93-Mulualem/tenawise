import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Central language controller for TenaWise with persistent local storage.
/// Defaults to English (false). Language choice is saved across restarts.
class AppLanguage {
  AppLanguage._();

  static const String _prefKey = 'tenawise_language_is_amharic';

  /// false = 100% English (default), true = Amharic
  static final ValueNotifier<bool> isAmharicNotifier =
      ValueNotifier<bool>(false);

  static bool get isAmharic => isAmharicNotifier.value;

  /// Loads saved language preference from SharedPreferences
  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedValue = prefs.getBool(_prefKey) ?? false;
      isAmharicNotifier.value = savedValue;
    } catch (_) {
      // In case of platform exception, default to English
    }
  }

  /// Toggles language and persists the choice to device storage
  static Future<void> toggleLanguage() async {
    final newValue = !isAmharicNotifier.value;
    isAmharicNotifier.value = newValue;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKey, newValue);
    } catch (_) {}
  }

  /// Explicitly sets language and persists the choice
  static Future<void> setAmharic(bool value) async {
    isAmharicNotifier.value = value;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKey, value);
    } catch (_) {}
  }
}
