import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/student_model.dart';
import '../../../shared/widgets/role_badge.dart';
import 'teacher_attendance_screen.dart';
import 'teacher_students_screen.dart';

class TeacherHomeTab extends StatelessWidget {
  const TeacherHomeTab({
    super.key,
    required this.userName,
    required this.students,
    required this.checkedInToday,
    required this.onRefresh,
    this.loading = false,
    this.error,
  });

  final String userName;
  final List<StudentModel> students;
  final int checkedInToday;
  final Future<void> Function() onRefresh;
  final bool loading;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'مرحباً، $userName',
                                style:
                                    Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            const RoleBadge(role: 'teacher'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'متابعة طلابك اليوم — حضور، واجبات، صور',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
                if (error != null) ...[
                  const SizedBox(height: 12),
                  Text(error!, style: const TextStyle(color: AppColors.coralRed)),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'طلابي',
                        value: '${students.length}',
                        color: AppColors.kiddyBlue,
                        icon: Icons.groups,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const TeacherStudentsScreen(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatCard(
                        label: 'حضور اليوم',
                        value: '$checkedInToday',
                        color: AppColors.linkGreen,
                        icon: Icons.fact_check,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TeacherAttendanceScreen(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          AppColors.linkGreen.withValues(alpha: 0.15),
                      child: const Icon(Icons.fact_check, color: AppColors.linkGreen),
                    ),
                    title: const Text('تسجيل حضور/انصراف/غياب'),
                    subtitle: Text(
                      checkedInToday > 0
                          ? '$checkedInToday طالب سجّل حضوراً اليوم'
                          : 'لم يُسجّل حضور بعد اليوم',
                    ),
                    trailing: const Icon(Icons.chevron_left),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TeacherAttendanceScreen(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 8),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
