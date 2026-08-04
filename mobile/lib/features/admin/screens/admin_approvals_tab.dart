import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'admin_pending_photos_screen.dart';

class AdminApprovalsTab extends StatelessWidget {
  const AdminApprovalsTab({
    super.key,
    required this.pendingCount,
    required this.onRefresh,
  });

  final int pendingCount;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: pendingCount > 0
              ? AppColors.coralRed.withValues(alpha: 0.08)
              : null,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.coralRed.withValues(alpha: 0.15),
              child: const Icon(Icons.photo_library, color: AppColors.coralRed),
            ),
            title: const Text('قائمة انتظار الصور'),
            subtitle: Text(
              pendingCount > 0
                  ? '$pendingCount صورة بانتظار الموافقة'
                  : 'لا صور معلّقة — كل شيء محدّث',
            ),
            trailing: pendingCount > 0
                ? Chip(
                    label: Text('$pendingCount'),
                    backgroundColor: AppColors.coralRed.withValues(alpha: 0.2),
                  )
                : const Icon(Icons.check_circle, color: AppColors.linkGreen),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AdminPendingPhotosScreen(),
              ),
            ).then((_) => onRefresh()),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AdminPendingPhotosScreen(),
            ),
          ).then((_) => onRefresh()),
          icon: const Icon(Icons.photo_library_outlined),
          label: const Text('فتح قائمة الموافقة'),
        ),
      ],
    );
  }
}
