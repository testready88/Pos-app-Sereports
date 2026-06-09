import 'dart:async';

import 'package:sereports/repository/auth_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  final SharedPreferences _preferences;
  Timer? _sessionCheckTimer;

  SessionManager(this._preferences);

  void startSessionMonitoring() {
    _sessionCheckTimer = Timer.periodic(const Duration(minutes: 1), (_) async {
      final authRepo = AuthRepo(_preferences);
      final isValid = await authRepo.isLoggedIn();
      final ctx = AuthRepo.navigatorKey.currentContext;
      if (!isValid && ctx != null) {
        authRepo.logout(ctx);
        stopSessionMonitoring();
      }
    });
  }

  void stopSessionMonitoring() {
    _sessionCheckTimer?.cancel();
    _sessionCheckTimer = null;
  }
}
