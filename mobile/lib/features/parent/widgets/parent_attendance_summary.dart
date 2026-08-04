import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/api/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/student_model.dart';
import '../screens/parent_attendance_screen.dart';

/// Attendance summary for parent home — today status + recent records.
class ParentAttendanceSummary extends StatefulWidget {
  const ParentAttendanceSummary({
    super.key,
    required this.student,
  });

  final StudentModel student;

  @override
  State<ParentAttendanceSummary> createState() =>
      _ParentAttendanceSummaryState();
}

class _ParentAttendanceSummaryState extends State<ParentAttendanceSummary> {
  List<Map<String, dynamic>> _records = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(ParentAttendanceSummary oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.student.id != widget.student.id) {
      _load();
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await context.read<AuthProvider>().api.get(
            '/attendance/student/${widget.student.id}',
          );
      if (!mounted) return;
      setState(() {
        _records = asJsonList(data);
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _dateKey(dynamic date) {
    if (date is String) return date.split('T').first;
    return '';
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  List<Map<String, dynamic>> get _todayRecords {
    final today = _todayKey();
    return _records.where((r) => _dateKey(r['date']) == today).toList();
  }

  _TodayStatus get _todayStatus {
    final today = _todayRecords;
    if (today.any((r) => r['type'] == 'absent')) {
      return _TodayStatus(
        label: 'غائب اليوم',
        icon: Icons.cancel_outlined,
        color: AppColors.coralRed,
      );
    }
    final hasCheckIn = today.any((r) => r['type'] == 'check_in');
    final hasCheckOut = today.any((r) => r['type'] == 'check_out');
    if (hasCheckOut) {
      return _TodayStatus(
        label: 'انصراف — حضر اليوم',
        icon: Icons.logout,
        color: AppColors.linkGreen,
      );
    }
    if (hasCheckIn) {
      return _TodayStatus(
        label: 'حاضر في الروضة',
        icon: Icons.check_circle_outline,
        color: AppColors.linkGreen,
      );
    }
    return _TodayStatus(
      label: 'لم يُسجّل حضور اليوم بعد',
      icon: Icons.schedule,
      color: AppColors.textSecondary,
    );
  }

  String _typeLabel(String? type) {
    switch (type) {
      case 'check_in':
        return 'حضور';
      case 'check_out':
        return 'انصراف';
      case 'absent':
        return 'غياب';
      default:
        return type ?? '';
    }
  }

  IconData _typeIcon(String? type) {
    switch (type) {
      case 'check_in':
        return Icons.login;
      case 'check_out':
        return Icons.logout;
      case 'absent':
        return Icons.cancel;
      default:
        return Icons.event;
    }
  }

  Color _typeColor(String? type) {
    switch (type) {
      case 'check_in':
        return AppColors.linkGreen;
      case 'check_out':
        return AppColors.kiddyBlue;
      case 'absent':
        return AppColors.coralRed;
      default:
        return AppColors.textSecondary;
    }
  }

  void _openFullHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ParentAttendanceScreen(student: widget.student),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = _todayStatus;
    final recent = _records.take(5).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.fact_check, color: AppColors.linkGreen),
                const SizedBox(width: 8),
                Text(
                  'الحضور والغياب',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: CircularProgressIndicator(),
                ),
              )
            else ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: status.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(status.icon, color: status.color, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'اليوم',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                          Text(
                            status.label,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: status.color),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (recent.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'آخر السجلات',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                ...recent.map((r) {
                  final date = _dateKey(r['date']);
                  final type = r['type']?.toString();
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      _typeIcon(type),
                      color: _typeColor(type),
                      size: 22,
                    ),
                    title: Text(_typeLabel(type)),
                    subtitle: Text(date),
                  );
                }),
              ] else ...[
                const SizedBox(height: 12),
                const Text(
                  'لا يوجد سجل حضور بعد',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _openFullHistory,
                  icon: const Icon(Icons.history),
                  label: const Text('عرض السجل الكامل'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TodayStatus {
  const _TodayStatus({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;
}
