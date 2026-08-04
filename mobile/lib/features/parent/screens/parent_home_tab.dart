import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/student_model.dart';
import '../../../shared/widgets/labeled_dropdown.dart';
import '../../../shared/widgets/role_badge.dart';
import '../widgets/parent_attendance_summary.dart';

/// Parent home tab — child summary + attendance/absence.
class ParentHomeTab extends StatelessWidget {
  const ParentHomeTab({
    super.key,
    required this.userName,
    required this.children,
    required this.selected,
    required this.onChildChanged,
    required this.onRefresh,
    this.loading = false,
  });

  final String userName;
  final List<StudentModel> children;
  final StudentModel? selected;
  final ValueChanged<StudentModel?> onChildChanged;
  final Future<void> Function() onRefresh;
  final bool loading;

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
                            const RoleBadge(role: 'parent'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          children.isEmpty
                              ? 'لا يوجد أطفال مرتبطين بحسابك'
                              : 'متابعة طفلك في الروضة',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
                if (children.length > 1) ...[
                  const SizedBox(height: 12),
                  LabeledDropdown<StudentModel>(
                    label: 'اختر الطفل',
                    value: selected,
                    items: children
                        .map(
                          (c) => DropdownMenuItem(
                            value: c,
                            child: Text(c.name),
                          ),
                        )
                        .toList(),
                    onChanged: onChildChanged,
                  ),
                ],
                if (selected != null) ...[
                  const SizedBox(height: 12),
                  Card(
                    color: AppColors.softSky,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            AppColors.kiddyBlue.withValues(alpha: 0.15),
                        child: const Icon(
                          Icons.child_care,
                          color: AppColors.kiddyBlue,
                        ),
                      ),
                      title: Text(selected!.name),
                      subtitle: Text('الصف: ${selected!.className}'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ParentAttendanceSummary(student: selected!),
                ],
              ],
            ),
    );
  }
}
