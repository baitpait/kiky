import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/role_badge.dart';
import '../widgets/admin_feedback.dart';

class AdminHomeTab extends StatelessWidget {
  const AdminHomeTab({
    super.key,
    required this.userName,
    required this.stats,
    required this.loading,
    required this.statsError,
    required this.apiOffline,
    required this.onRefresh,
    required this.count,
    required this.onOpenTeachers,
    required this.onOpenStudents,
    required this.onOpenPendingPhotos,
  });

  final String userName;
  final Map<String, dynamic>? stats;
  final bool loading;
  final String? statsError;
  final bool apiOffline;
  final Future<void> Function() onRefresh;
  final int Function(String key) count;
  final VoidCallback onOpenTeachers;
  final VoidCallback onOpenStudents;
  final VoidCallback onOpenPendingPhotos;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (apiOffline)
          ApiOfflineBanner(message: statsError ?? 'تعذّر الاتصال'),
        Expanded(
          child: RefreshIndicator(
            onRefresh: onRefresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
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
                            const RoleBadge(role: 'admin'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Kiddy Link — إدارة الروضة داخل التطبيق',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'إحصائيات سريعة',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                if (loading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (statsError != null)
                  Card(
                    child: ListTile(
                      title: const Text('تعذّر تحميل الإحصائيات'),
                      subtitle: Text(statsError!),
                      trailing: TextButton(
                        onPressed: () => onRefresh(),
                        child: const Text('إعادة'),
                      ),
                    ),
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: _QuickStat(
                          label: 'معلمات',
                          value: count('teachers'),
                          color: AppColors.kiddyBlue,
                          icon: Icons.person_outline,
                          onTap: onOpenTeachers,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _QuickStat(
                          label: 'طلاب',
                          value: count('students'),
                          color: AppColors.warmOrange,
                          icon: Icons.child_care,
                          onTap: onOpenStudents,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _QuickStat(
                          label: 'صور معلّقة',
                          value: count('pendingPhotos'),
                          color: AppColors.coralRed,
                          icon: Icons.photo_library,
                          highlight: count('pendingPhotos') > 0,
                          onTap: onOpenPendingPhotos,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickStat extends StatelessWidget {
  const _QuickStat({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    required this.onTap,
    this.highlight = false,
  });

  final String label;
  final int value;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: highlight ? color.withValues(alpha: 0.08) : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 8),
              Text(
                '$value',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
