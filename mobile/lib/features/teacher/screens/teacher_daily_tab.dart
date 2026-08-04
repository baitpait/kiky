import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'teacher_attendance_screen.dart';
import 'teacher_meals_screen.dart';
import 'teacher_upload_photo_screen.dart';

class TeacherDailyTab extends StatelessWidget {
  const TeacherDailyTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _MenuTile(
          icon: Icons.fact_check,
          title: 'تسجيل حضور/انصراف',
          subtitle: 'حضور · انصراف · غياب',
          color: AppColors.linkGreen,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TeacherAttendanceScreen()),
          ),
        ),
        _MenuTile(
          icon: Icons.restaurant,
          title: 'تأكيد وجبات',
          subtitle: 'تأكيد تناول الوجبة في الروضة',
          color: AppColors.warmOrange,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TeacherMealsScreen()),
          ),
        ),
        _MenuTile(
          icon: Icons.photo_camera,
          title: 'رفع صور (ألبوم)',
          subtitle: 'بانتظار موافقة المديرة',
          color: AppColors.kiddyBlue,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const TeacherUploadPhotoScreen(),
            ),
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
