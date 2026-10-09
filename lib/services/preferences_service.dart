// File: lib/services/preferences_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _keyHasSeenOnboarding = 'has_seen_onboarding';

  static Future<bool> hasSeenOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyHasSeenOnboarding) ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> setHasSeenOnboarding(bool seen) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyHasSeenOnboarding, seen);
    } catch (_) {}
  }
}
