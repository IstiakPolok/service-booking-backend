import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_endpoints.dart';

class TokenStorage {
  static const String _keyToken = 'auth_token';
  static const String _keyUser = 'cached_user';
  static const String _keyBaseUrl = 'custom_base_url';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    
    // Load persisted base URL if custom
    final savedBaseUrl = _prefs?.getString(_keyBaseUrl);
    if (savedBaseUrl != null && savedBaseUrl.isNotEmpty) {
      if (savedBaseUrl.contains('10.0.2.2') || savedBaseUrl.contains('127.0.0.1')) {
        // Upgrade old local emulator URL to the live cloud URL
        await _prefs?.remove(_keyBaseUrl);
        ApiEndpoints.baseUrl = ApiEndpoints.defaultBaseUrl;
      } else {
        ApiEndpoints.baseUrl = savedBaseUrl;
      }
    } else {
      ApiEndpoints.baseUrl = ApiEndpoints.defaultBaseUrl;
    }
  }

  static Future<void> saveToken(String token) async {
    await init();
    await _prefs?.setString(_keyToken, token);
  }

  static Future<String?> getToken() async {
    await init();
    return _prefs?.getString(_keyToken);
  }

  static Future<void> saveUser(Map<String, dynamic> userMap) async {
    await init();
    await _prefs?.setString(_keyUser, jsonEncode(userMap));
  }

  static Future<Map<String, dynamic>?> getUser() async {
    await init();
    final userStr = _prefs?.getString(_keyUser);
    if (userStr != null) {
      try {
        return jsonDecode(userStr) as Map<String, dynamic>;
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  static Future<void> clearAuth() async {
    await init();
    await _prefs?.remove(_keyToken);
    await _prefs?.remove(_keyUser);
  }

  static Future<void> saveCustomBaseUrl(String url) async {
    await init();
    await _prefs?.setString(_keyBaseUrl, url);
    ApiEndpoints.baseUrl = url;
  }
}
