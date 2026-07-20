import 'package:flutter/foundation.dart';

/// يحدّث عداد الجرس على Web + Mobile (بدون Firebase).
class NotificationBellRefresh {
  NotificationBellRefresh._();

  static final ValueNotifier<int> tick = ValueNotifier(0);

  static void bump() => tick.value++;
}
