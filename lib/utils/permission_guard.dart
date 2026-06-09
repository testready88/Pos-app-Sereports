import 'package:flutter/material.dart';
import 'user_session.dart';

class PermissionGuard {
  /// Returns true if the user has the permission, otherwise shows a
  /// SnackBar with "You don't have access for this option." and returns false.
  static bool verifyAccess({
    required BuildContext context,
    required String permissionKey,
    required String visualOptionName,
  }) {
    if (UserSession.instance.permissions == null) {
      showPermissionDeniedBanner(context, visualOptionName);
      return false;
    }

    bool allowed = UserSession.instance.can(permissionKey);

    if (!allowed) {
      showPermissionDeniedBanner(context, visualOptionName);
    }

    return allowed;
  }

  static void showPermissionDeniedBanner(BuildContext context, String screenName) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "You don't have access for this option.",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}