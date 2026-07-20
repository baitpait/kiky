import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';

enum NotificationCategory {
  attendance,
  absence,
  homework,
  homeworkConfirm,
  meal,
  photo,
  sticker,
  live,
  chat,
  announcement,
  general,
}

class NotificationStyle {
  const NotificationStyle({
    required this.category,
    required this.icon,
    required this.color,
    required this.label,
  });

  final NotificationCategory category;
  final IconData icon;
  final Color color;
  final String label;
}

NotificationCategory? parseNotificationCategory(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  switch (raw) {
    case 'attendance':
      return NotificationCategory.attendance;
    case 'absence':
      return NotificationCategory.absence;
    case 'homework':
      return NotificationCategory.homework;
    case 'homework_confirm':
      return NotificationCategory.homeworkConfirm;
    case 'meal':
      return NotificationCategory.meal;
    case 'photo':
      return NotificationCategory.photo;
    case 'sticker':
      return NotificationCategory.sticker;
    case 'live':
      return NotificationCategory.live;
    case 'chat':
      return NotificationCategory.chat;
    case 'announcement':
      return NotificationCategory.announcement;
    default:
      return null;
  }
}

NotificationStyle styleFromCategory(NotificationCategory category) {
  switch (category) {
    case NotificationCategory.absence:
      return const NotificationStyle(
        category: NotificationCategory.absence,
        icon: Icons.event_busy_outlined,
        color: AppColors.coralRed,
        label: 'غياب',
      );
    case NotificationCategory.attendance:
      return const NotificationStyle(
        category: NotificationCategory.attendance,
        icon: Icons.fact_check_outlined,
        color: AppColors.linkGreen,
        label: 'حضور',
      );
    case NotificationCategory.homework:
      return const NotificationStyle(
        category: NotificationCategory.homework,
        icon: Icons.assignment_outlined,
        color: AppColors.kiddyBlue,
        label: 'واجب',
      );
    case NotificationCategory.homeworkConfirm:
      return const NotificationStyle(
        category: NotificationCategory.homeworkConfirm,
        icon: Icons.task_alt_outlined,
        color: AppColors.kiddyBlue,
        label: 'تأكيد واجب',
      );
    case NotificationCategory.meal:
      return const NotificationStyle(
        category: NotificationCategory.meal,
        icon: Icons.restaurant_outlined,
        color: AppColors.warmOrange,
        label: 'وجبة',
      );
    case NotificationCategory.photo:
      return const NotificationStyle(
        category: NotificationCategory.photo,
        icon: Icons.photo_outlined,
        color: AppColors.linkGreen,
        label: 'صورة',
      );
    case NotificationCategory.sticker:
      return const NotificationStyle(
        category: NotificationCategory.sticker,
        icon: Icons.emoji_events_outlined,
        color: AppColors.warmOrange,
        label: 'ملصق',
      );
    case NotificationCategory.live:
      return const NotificationStyle(
        category: NotificationCategory.live,
        icon: Icons.live_tv_outlined,
        color: AppColors.coralRed,
        label: 'بث مباشر',
      );
    case NotificationCategory.chat:
      return const NotificationStyle(
        category: NotificationCategory.chat,
        icon: Icons.chat_bubble_outline,
        color: AppColors.kiddyBlue,
        label: 'رسالة',
      );
    case NotificationCategory.announcement:
      return const NotificationStyle(
        category: NotificationCategory.announcement,
        icon: Icons.campaign_outlined,
        color: AppColors.kiddyBlue,
        label: 'إعلان',
      );
    case NotificationCategory.general:
      return const NotificationStyle(
        category: NotificationCategory.general,
        icon: Icons.notifications_outlined,
        color: AppColors.kiddyBlue,
        label: 'إشعار',
      );
  }
}

/// Prefer API `category`; fallback to title/body heuristics for old rows.
NotificationStyle styleForNotification(
  String title,
  String body, {
  String? category,
}) {
  final fromApi = parseNotificationCategory(category);
  if (fromApi != null) return styleFromCategory(fromApi);

  final text = '$title $body';

  if (RegExp(r'غياب').hasMatch(text)) {
    return styleFromCategory(NotificationCategory.absence);
  }
  if (RegExp(r'حضور|انصراف').hasMatch(text)) {
    return styleFromCategory(NotificationCategory.attendance);
  }
  if (RegExp(r'تأكيد حل واجب|تأكيد.*واجب').hasMatch(text)) {
    return styleFromCategory(NotificationCategory.homeworkConfirm);
  }
  if (RegExp(r'واجب').hasMatch(text)) {
    return styleFromCategory(NotificationCategory.homework);
  }
  if (RegExp(r'وجبة|الفطور|الغداء|الوجبة الخفيفة').hasMatch(text)) {
    return styleFromCategory(NotificationCategory.meal);
  }
  if (RegExp(r'صورة').hasMatch(text)) {
    return styleFromCategory(NotificationCategory.photo);
  }
  if (RegExp(r'ملصق').hasMatch(text)) {
    return styleFromCategory(NotificationCategory.sticker);
  }
  if (RegExp(r'بث').hasMatch(text)) {
    return styleFromCategory(NotificationCategory.live);
  }
  if (RegExp(r'رسالة|دردش').hasMatch(text)) {
    return styleFromCategory(NotificationCategory.chat);
  }
  return styleFromCategory(NotificationCategory.announcement);
}

String formatNotificationTime(String? iso) {
  if (iso == null || iso.isEmpty) return '';
  try {
    final dt = DateTime.parse(iso).toLocal();
    final diff = DateTime.now().difference(dt);

    if (diff.inSeconds < 45) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (_isSameDay(dt, DateTime.now().subtract(const Duration(days: 1)))) {
      return 'أمس ${DateFormat('HH:mm').format(dt)}';
    }
    if (diff.inDays < 7) return 'منذ ${diff.inDays} أيام';

    return DateFormat('d/M/y — HH:mm').format(dt);
  } catch (_) {
    return iso;
  }
}

String formatNotificationTimeFull(String? iso) {
  if (iso == null || iso.isEmpty) return '';
  try {
    final dt = DateTime.parse(iso).toLocal();
    final time = DateFormat('HH:mm').format(dt);
    final now = DateTime.now();
    if (_isSameDay(dt, now)) return 'اليوم — $time';
    if (_isSameDay(dt, now.subtract(const Duration(days: 1)))) {
      return 'أمس — $time';
    }
    return '${DateFormat('d/M/y').format(dt)} — $time';
  } catch (_) {
    return iso;
  }
}

String notificationGroupLabel(String? iso) {
  if (iso == null || iso.isEmpty) return 'سابقاً';
  try {
    final dt = DateTime.parse(iso).toLocal();
    final now = DateTime.now();
    if (_isSameDay(dt, now)) return 'اليوم';
    if (_isSameDay(dt, now.subtract(const Duration(days: 1)))) return 'أمس';
    if (now.difference(dt).inDays < 7) return 'هذا الأسبوع';
    return 'سابقاً';
  } catch (_) {
    return 'سابقاً';
  }
}

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

const notificationFilterLabels = <String, String>{
  'all': 'الكل',
  'attendance': 'حضور',
  'homework': 'واجبات',
  'meal': 'وجبات',
  'chat': 'رسائل',
  'announcement': 'إعلانات',
};

String _categoryApiKey(NotificationCategory category) {
  switch (category) {
    case NotificationCategory.homeworkConfirm:
      return 'homework_confirm';
    case NotificationCategory.general:
      return 'announcement';
    default:
      return category.name;
  }
}

/// Resolved category: API field first, then title/body heuristics.
NotificationCategory effectiveNotificationCategory(Map<String, dynamic> item) {
  final fromApi = parseNotificationCategory(item['category']?.toString());
  if (fromApi != null) return fromApi;

  return styleForNotification(
    item['title']?.toString() ?? '',
    item['body']?.toString() ?? '',
  ).category;
}

bool notificationMatchesFilter(Map<String, dynamic> item, String filter) {
  if (filter == 'all') return true;
  final cat = _categoryApiKey(effectiveNotificationCategory(item));
  if (filter == 'attendance') {
    return cat == 'attendance' || cat == 'absence';
  }
  if (filter == 'homework') {
    return cat == 'homework' || cat == 'homework_confirm' || cat == 'sticker';
  }
  return cat == filter;
}
