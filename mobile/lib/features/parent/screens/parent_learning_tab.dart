import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/student_model.dart';
import '../../homework/screens/parent_homework_screen.dart';
import '../../stickers/screens/parent_stickers_screen.dart';

class ParentLearningTab extends StatelessWidget {
  const ParentLearningTab({
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
          icon: Icons.assignment,
          title: 'الواجبات',
          subtitle: 'عرض + تأكيد "تم الحل"',
          color: AppColors.coralRed,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ParentHomeworkScreen(student: student),
            ),
          ),
        ),
        _MenuTile(
          icon: Icons.emoji_events,
          title: 'ملصقات الطفل',
          subtitle: 'الملصقات المكتسبة مع المستوى',
          color: AppColors.warmOrange,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ParentStickersScreen(student: student),
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
