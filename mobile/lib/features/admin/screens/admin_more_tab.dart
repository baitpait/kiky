import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../notifications/screens/notifications_screen.dart';
import 'admin_banners_screen.dart';
import 'admin_calendar_screen.dart';
import 'admin_notify_screen.dart';
import 'admin_sticker_levels_screen.dart';
import 'admin_stickers_screen.dart';

class AdminMoreTab extends StatelessWidget {
  const AdminMoreTab({
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
          icon: Icons.campaign,
          title: 'إدارة البانرات',
          subtitle: '${count('activeBanners')} بانر نشط',
          color: AppColors.warmOrange,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminBannersScreen()),
          ),
        ),
        _MenuTile(
          icon: Icons.calendar_month,
          title: 'التقويم السنوي',
          subtitle: '${count('calendarEvents')} حدث',
          color: AppColors.linkGreen,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminCalendarScreen()),
          ),
        ),
        _MenuTile(
          icon: Icons.layers,
          title: 'إدارة مستويات الملصقات',
          subtitle: '${count('stickerLevels')} مستويات',
          color: AppColors.linkGreen,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AdminStickerLevelsScreen(),
            ),
          ),
        ),
        _MenuTile(
          icon: Icons.emoji_events,
          title: 'إدارة الملصقات',
          subtitle: '${count('stickers')} ملصق نشط',
          color: AppColors.warmOrange,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminStickersScreen()),
          ),
        ),
        _MenuTile(
          icon: Icons.notifications,
          title: 'صندوق الإشعارات',
          subtitle: 'عرض الإشعارات الواردة',
          color: AppColors.kiddyBlue,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotificationsScreen()),
          ),
        ),
        _MenuTile(
          icon: Icons.notifications_active,
          title: 'إرسال إشعارات Push',
          subtitle: 'للجميع / معلمات / أولياء أمور',
          color: AppColors.coralRed,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminNotifyScreen()),
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
