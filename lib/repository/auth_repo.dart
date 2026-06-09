import 'package:flutter/material.dart';
import 'package:sereports/model/user_permissions.dart';
import 'package:sereports/screen/auth_screen/login.dart';
import 'package:sereports/utils/api.dart';
import 'package:sereports/utils/user_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepo {
  final SharedPreferences _preferences;
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  AuthRepo(this._preferences);

  final String _tokenKey = 'jwt_token';
  final String _expiryKey = 'jwt_expiry';

  Future<LoginResult> login(String username, String password, String pinnumber) async {
    final result = await Api.loginCompany(username, password, pinnumber);
    if (result.success) {
      // ✅ FIX: Save the token to SharedPreferences so isLoggedIn() works correctly
      await saveToken(result.token!);
      await _fetchAndCachePermissions();
    }
    return result;
  }

  Future<void> _fetchAndCachePermissions() async {
    try {
      final response = await Api.getUserPermissions();
      final dynamic raw = response['data'];
      if (raw == null) return;
      final Map<String, dynamic> userMap = raw is Map ? raw.cast<String, dynamic>() : (raw as Map).cast<String, dynamic>();
      final perms = UserPermissions.fromJson(userMap);
      await UserSession.instance.savePermissions(perms);
    } catch (e) {
      print('Failed to cache permissions: $e');
    }
  }

  Future<void> loadPermissions() async {
    await UserSession.instance.loadFromPrefs();
  }

  Future<void> saveToken(String token) async {
    await _preferences.setString(_tokenKey, token);
    await _preferences.setString(_expiryKey, DateTime.now().add(const Duration(days: 90)).toIso8601String());
  }

  Future<bool> isLoggedIn() async {
    final token = _preferences.getString(_tokenKey);
    final expiryStr = _preferences.getString(_expiryKey);
    if (token == null || expiryStr == null) return false;
    try {
      return DateTime.parse(expiryStr).isAfter(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  Future<void> logout(BuildContext context) async {
    await _preferences.remove(_tokenKey);
    await _preferences.remove(_expiryKey);
    await UserSession.instance.clear();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
}
