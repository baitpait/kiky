import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'admin_accounts_screen.dart';
import 'admin_parents_screen.dart';
import 'admin_students_screen.dart';
import 'admin_teachers_screen.dart';

class AdminAccountsTab extends StatelessWidget {
  const AdminAccountsTab({
    super.key,
    required this.count,
  });

  final int Function(String key) count;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _MenuTile(
          icon: Icons.person_outline,
          title: 'إدارة المعلمات',
          subtitle: '${count('teachers')} معلمة نشطة',
          color: AppColors.kiddyBlue,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminTeachersScreen()),
          ),
        ),
        _MenuTile(
          icon: Icons.family_restroom,
          title: 'إدارة أولياء الأمور',
          subtitle: '${count('parents')} ولي نشط',
          color: AppColors.linkGreen,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminParentsScreen()),
          ),
        ),
        _MenuTile(
          icon: Icons.child_care,
          title: 'إدارة الطلاب + الربط',
          subtitle: '${count('students')} طالب — ربط معلمة وولي',
          color: AppColors.warmOrange,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminStudentsScreen()),
          ),
        ),
        _MenuTile(
          icon: Icons.manage_accounts,
          title: 'إنشاء/تعديل حساب',
          subtitle: 'المديرة تنشئ كل الحسابات',
          color: AppColors.kiddyBlue,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminAccountsScreen()),
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
