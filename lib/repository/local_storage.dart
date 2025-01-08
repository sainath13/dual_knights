import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _progressKey = 'user_progress';
  static const String _settingsKey = 'user_settings';

  // Save user progress as a JSON string
  Future<void> saveUserProgress(Map<String, dynamic> progress) async {
    final prefs = await SharedPreferences.getInstance();
    final progressJson = jsonEncode(progress);
    prefs.setString(_progressKey, progressJson);
  }

  // Retrieve user progress and decode it back into a Map
  Future<Map<String, dynamic>> getUserProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final progressString = prefs.getString(_progressKey);
    if (progressString != null) {
      return jsonDecode(progressString) as Map<String, dynamic>;
    }
    return {}; // Return an empty map if no data is found
  }

  // Save user settings as a JSON string
  Future<void> saveUserSettings(Map<String, dynamic> settings) async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = jsonEncode(settings);
    prefs.setString(_settingsKey, settingsJson);
  }

  // Retrieve user settings and decode it back into a Map
  Future<Map<String, dynamic>> getUserSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsString = prefs.getString(_settingsKey);
    if (settingsString != null) {
      return jsonDecode(settingsString) as Map<String, dynamic>;
    }
    return {}; // Return an empty map if no data is found
  }
}
