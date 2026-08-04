import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../homework/screens/teacher_homework_screen.dart';
import '../../live/screens/teacher_live_screen.dart';
import '../../notifications/screens/notifications_screen.dart';
import 'teacher_calendar_screen.dart';

class TeacherMoreTab extends StatelessWidget {
  const TeacherMoreTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _MenuTile(
          icon: Icons.add_circle_outline,
          title: 'إنشاء واجب',
          subtitle: 'نشاط أو واجب منزلي لطالب',
          color: AppColors.warmOrange,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const TeacherHomeworkScreen(mode: TeacherHomeworkMode.create),
            ),
          ),
        ),
        _MenuTile(
          icon: Icons.grade,
          title: 'تصحيح واجبات',
          subtitle: 'بعد تأكيد ولي الأمر',
          color: AppColors.coralRed,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const TeacherHomeworkScreen(mode: TeacherHomeworkMode.grade),
            ),
          ),
        ),
        _MenuTile(
          icon: Icons.live_tv,
          title: 'بدء بث مباشر',
          subtitle: 'المعلمة تبدأ — أولياء الأمور يشاهدون',
          color: AppColors.coralRed,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TeacherLiveScreen()),
          ),
        ),
        _MenuTile(
          icon: Icons.calendar_month,
          title: 'التقويم',
          subtitle: 'عطلات وفعاليات الروضة',
          color: AppColors.linkGreen,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TeacherCalendarScreen()),
          ),
        ),
        _MenuTile(
          icon: Icons.notifications,
          title: 'الإشعارات',
          subtitle: 'واجبات، وجبات، رسائل، إعلانات',
          color: AppColors.kiddyBlue,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotificationsScreen()),
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
