import 'package:flutter/material.dart';
import 'admin_feedback.dart';

/// Safe admin snackbars after async — avoids using BuildContext when unmounted.
extension SafeAdminFeedback on State {
  void adminSuccess(String message) {
    if (!mounted) return;
    showAdminSuccess(context, message);
  }

  void adminError(Object error) {
    if (!mounted) return;
    showAdminError(context, error);
  }
}
