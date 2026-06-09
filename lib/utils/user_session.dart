import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sereports/model/user_permissions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  UserSession._();
  static final UserSession instance = UserSession._();

  static const String _permissionsKey = 'user_permissions_json';

  UserPermissions? _permissions;

  UserPermissions? get permissions => _permissions;

  Future<void> savePermissions(UserPermissions perms) async {
    _permissions = perms;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_permissionsKey, jsonEncode(perms.toJson()));
    } catch (e) {
      print('UserSession.savePermissions error: $e');
    }
  }

  Future<void> loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_permissionsKey);
      if (raw != null && raw.isNotEmpty) {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        _permissions = UserPermissions.fromJson(json);
      }
    } catch (e) {
      print('UserSession.loadFromPrefs error: $e');
      _permissions = null;
    }
  }

  Future<void> clear() async {
    _permissions = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_permissionsKey);
    } catch (e) {
      print('UserSession.clear error: $e');
    }
  }

  bool can(String permissionKey) {
    if (_permissions == null) return false;
    final map = _permissions!.toJson();
    final value = map[permissionKey];
    if (value == null) return false;
    if (value is bool) return value;
    return false;
  }

  bool guard(BuildContext context, String permissionKey, {String? customMessage}) {
    if (can(permissionKey)) return true;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          customMessage ?? "You don't have access for this option.",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
    return false;
  }

  String get displayName => _permissions?.cName ?? _permissions?.userName ?? 'User';
  String get userCode => _permissions?.userCode ?? '';
  String get pinnumber => _permissions?.pinnumber ?? '';
  bool get isLoggedIn => _permissions != null;
}