import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/services/admin_repository.dart';
import '../widgets/admin_feedback.dart';
import 'admin_pending_photos_screen.dart';
import 'admin_teachers_screen.dart';
import 'admin_parents_screen.dart';
import 'admin_students_screen.dart';
import 'admin_banners_screen.dart';
import 'admin_calendar_screen.dart';
import 'admin_notify_screen.dart';
import 'admin_sticker_levels_screen.dart';
import 'admin_stickers_screen.dart';
import 'admin_accounts_screen.dart';
import '../../../shared/widgets/role_badge.dart';
import '../../chat/screens/chat_list_screen.dart';
import '../../notifications/screens/notifications_screen.dart';

/// DEVELOPER_SPEC §8.2 #1 + §12 — لوحة تحكم المديرة
class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  Map<String, dynamic>? _stats;
  bool _loadingStats = true;
  String? _statsError;

  AdminRepository get _repo =>
      AdminRepository(context.read<AuthProvider>().api);

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _loadingStats = true;
      _statsError = null;
    });
    try {
      final stats = await _repo.getDashboardStats();
      setState(() {
        _stats = stats;
        _loadingStats = false;
      });
    } catch (e) {
      setState(() {
        _statsError = formatAdminError(e);
        _loadingStats = false;
      });
    }
  }

  bool get _apiOffline =>
      _statsError != null && isApiConnectionError(_statsError!);

  int _count(String key) {
    if (_stats == null) return 0;
    final v = _stats![key];
    if (v is int) return v;
    if (v is num) return v.toInt();
    return 0;
  }

  void _open(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen))
        .then((_) => _loadStats());
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;

    return Theme(
      data: AppTheme.forRole('admin'),
      child: Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('لوحة التحكم'),
          actions: [
            const NotificationsBellButton(),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadingStats ? null : _loadStats,
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => context.read<AuthProvider>().logout(),
            ),
          ],
        ),
        body: Column(
          children: [
            if (_apiOffline)
              ApiOfflineBanner(message: _statsError!),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadStats,
                child: ListView(
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
                                    'مرحباً، ${user.name}',
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                ),
                                const RoleBadge(role: 'admin'),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Kiddy Link — إدارة الروضة داخل التطبيق',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
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
                    if (_loadingStats)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_statsError != null)
                      Card(
                        child: ListTile(
                          title: const Text('تعذّر تحميل الإحصائيات'),
                          subtitle: Text(_statsError!),
                          trailing: TextButton(
                            onPressed: _loadStats,
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
                              value: _count('teachers'),
                              color: AppColors.kiddyBlue,
                              icon: Icons.person_outline,
                              onTap: () => _open(const AdminTeachersScreen()),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _QuickStat(
                              label: 'طلاب',
                              value: _count('students'),
                              color: AppColors.warmOrange,
                              icon: Icons.child_care,
                              onTap: () => _open(const AdminStudentsScreen()),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _QuickStat(
                              label: 'صور بانتظار الموافقة',
                              value: _count('pendingPhotos'),
                              color: AppColors.coralRed,
                              icon: Icons.photo_library,
                              highlight: _count('pendingPhotos') > 0,
                              onTap: () =>
                                  _open(const AdminPendingPhotosScreen()),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 24),
                    _SectionTitle('إدارة الحسابات'),
                    _MenuTile(
                      icon: Icons.person_outline,
                      title: 'إدارة المعلمات',
                      subtitle: '${_count('teachers')} معلمة نشطة',
                      color: AppColors.kiddyBlue,
                      onTap: () => _open(const AdminTeachersScreen()),
                    ),
                    _MenuTile(
                      icon: Icons.family_restroom,
                      title: 'إدارة أولياء الأمور',
                      subtitle: '${_count('parents')} ولي نشط',
                      color: AppColors.linkGreen,
                      onTap: () => _open(const AdminParentsScreen()),
                    ),
                    _MenuTile(
                      icon: Icons.child_care,
                      title: 'إدارة الطلاب + الربط',
                      subtitle: '${_count('students')} طالب — ربط معلمة وولي',
                      color: AppColors.warmOrange,
                      onTap: () => _open(const AdminStudentsScreen()),
                    ),
                    _MenuTile(
                      icon: Icons.manage_accounts,
                      title: 'إنشاء/تعديل حساب',
                      subtitle: 'المديرة تنشئ كل الحسابات',
                      color: AppColors.kiddyBlue,
                      onTap: () => _open(const AdminAccountsScreen()),
                    ),
                    _SectionTitle('موافقة الصور'),
                    _MenuTile(
                      icon: Icons.photo_library,
                      title: 'قائمة انتظار الصور',
                      subtitle: _count('pendingPhotos') > 0
                          ? '${_count('pendingPhotos')} صورة بانتظارك'
                          : 'لا صور معلّقة',
                      color: AppColors.coralRed,
                      onTap: () => _open(const AdminPendingPhotosScreen()),
                    ),
                    _SectionTitle('البانرات والتقويم'),
                    _MenuTile(
                      icon: Icons.campaign,
                      title: 'إدارة البانرات',
                      subtitle: '${_count('activeBanners')} بانر نشط',
                      color: AppColors.warmOrange,
                      onTap: () => _open(const AdminBannersScreen()),
                    ),
                    _MenuTile(
                      icon: Icons.calendar_month,
                      title: 'التقويم السنوي',
                      subtitle: '${_count('calendarEvents')} حدث',
                      color: AppColors.linkGreen,
                      onTap: () => _open(const AdminCalendarScreen()),
                    ),
                    _SectionTitle('الملصقات والمستويات'),
                    _MenuTile(
                      icon: Icons.layers,
                      title: 'إدارة مستويات الملصقات',
                      subtitle: '${_count('stickerLevels')} مستويات',
                      color: AppColors.linkGreen,
                      onTap: () => _open(const AdminStickerLevelsScreen()),
                    ),
                    _MenuTile(
                      icon: Icons.emoji_events,
                      title: 'إدارة الملصقات',
                      subtitle: '${_count('stickers')} ملصق نشط',
                      color: AppColors.warmOrange,
                      onTap: () => _open(const AdminStickersScreen()),
                    ),
                    _SectionTitle('التواصل'),
                    _MenuTile(
                      icon: Icons.chat,
                      title: 'الدردشة',
                      subtitle: 'مع المعلمات وأولياء الأمور',
                      color: AppColors.kiddyBlue,
                      onTap: () => _open(const ChatListScreen()),
                    ),
                    _SectionTitle('الإشعارات'),
                    _MenuTile(
                      icon: Icons.notifications,
                      title: 'صندوق الإشعارات',
                      subtitle: 'عرض الإشعارات الواردة',
                      color: AppColors.kiddyBlue,
                      onTap: () => _open(const NotificationsScreen()),
                    ),
                    _MenuTile(
                      icon: Icons.notifications_active,
                      title: 'إرسال إشعارات Push',
                      subtitle: 'للجميع / معلمات / أولياء أمور',
                      color: AppColors.coralRed,
                      onTap: () => _open(const AdminNotifyScreen()),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
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

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;

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
