import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/student_model.dart';
import '../../chat/screens/chat_list_screen.dart';
import '../../live/screens/parent_live_screen.dart';
import '../../notifications/screens/notifications_screen.dart';
import 'parent_attendance_screen.dart';
import 'parent_calendar_screen.dart';
import 'parent_meals_screen.dart';

class ParentMoreTab extends StatelessWidget {
  const ParentMoreTab({
    super.key,
    required this.student,
  });

  final StudentModel student;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _MenuTile(
          icon: Icons.fact_check,
          title: 'الحضور والغياب',
          subtitle: 'سجل حضور وانصراف طفلك',
          color: AppColors.linkGreen,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ParentAttendanceScreen(student: student),
            ),
          ),
        ),
        _MenuTile(
          icon: Icons.restaurant,
          title: 'الوجبات',
          subtitle: 'تأكيد تناول الوجبة',
          color: AppColors.warmOrange,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ParentMealsScreen(student: student),
            ),
          ),
        ),
        _MenuTile(
          icon: Icons.calendar_month,
          title: 'التقويم والبانرات',
          subtitle: 'عطلات وإعلانات الروضة',
          color: AppColors.linkGreen,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ParentCalendarScreen()),
          ),
        ),
        _MenuTile(
          icon: Icons.live_tv,
          title: 'مشاهدة البث المباشر',
          subtitle: 'بث معلمة طفلك',
          color: AppColors.coralRed,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ParentLiveScreen()),
          ),
        ),
        _MenuTile(
          icon: Icons.notifications,
          title: 'الإشعارات',
          subtitle: 'حضور، واجبات، صور، إعلانات',
          color: AppColors.kiddyBlue,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotificationsScreen()),
          ),
        ),
        _MenuTile(
          icon: Icons.chat,
          title: 'بدء محادثة جديدة',
          subtitle: 'مع المعلمات والمديرة',
          color: AppColors.kiddyBlue,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ChatListScreen()),
          ),
        ),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_left),
      ),
    );
  }
}
