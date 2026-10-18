import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/user_preferences.dart';
import '../../features/assistant/models/chat_message.dart';
import '../../features/websites/models/generated_website.dart';

class StorageService {
  static const String _keyPreferences = 'cyber_ai_preferences';
  static const String _keyChatHistory = 'cyber_ai_chat_history';
  static const String _keyWebsites = 'cyber_ai_websites';

  final SharedPreferences? _prefs;

  StorageService([this._prefs]);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // --- User Preferences ---
  Future<UserPreferences> loadPreferences() async {
    if (_prefs == null) return const UserPreferences();
    final raw = _prefs.getString(_keyPreferences);
    if (raw == null) return const UserPreferences();
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return UserPreferences.fromJson(decoded);
    } catch (_) {
      return const UserPreferences();
    }
  }

  Future<bool> savePreferences(UserPreferences preferences) async {
    if (_prefs == null) return false;
    final encoded = jsonEncode(preferences.toJson());
    return _prefs.setString(_keyPreferences, encoded);
  }

  // --- Chat History ---
  Future<List<ChatMessage>> loadChatHistory() async {
    if (_prefs == null) return [];
    final raw = _prefs.getStringList(_keyChatHistory);
    if (raw == null) return [];
    try {
      return raw.map((item) {
        final map = jsonDecode(item) as Map<String, dynamic>;
        return ChatMessage.fromJson(map);
      }).toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> saveChatHistory(List<ChatMessage> messages) async {
    if (_prefs == null) return false;
    // Keep last 100 messages for storage efficiency
    final trimmed = messages.length > 100
        ? messages.sublist(messages.length - 100)
        : messages;
    final encoded = trimmed.map((m) => jsonEncode(m.toJson())).toList();
    return _prefs.setStringList(_keyChatHistory, encoded);
  }

  Future<bool> clearChatHistory() async {
    if (_prefs == null) return false;
    return _prefs.remove(_keyChatHistory);
  }

  // --- Generated Websites ---
  Future<List<GeneratedWebsite>> loadWebsites() async {
    if (_prefs == null) return [];
    final raw = _prefs.getStringList(_keyWebsites);
    if (raw == null) return [];
    try {
      return raw.map((item) {
        final map = jsonDecode(item) as Map<String, dynamic>;
        return GeneratedWebsite.fromJson(map);
      }).toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> saveWebsites(List<GeneratedWebsite> websites) async {
    if (_prefs == null) return false;
    final encoded = websites.map((w) => jsonEncode(w.toJson())).toList();
    return _prefs.setStringList(_keyWebsites, encoded);
  }

  Future<bool> clearAllData() async {
    if (_prefs == null) return false;
    await _prefs.remove(_keyChatHistory);
    await _prefs.remove(_keyWebsites);
    return true;
  }
}
