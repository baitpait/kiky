import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/student_model.dart';
import '../../../shared/services/students_repository.dart';
import '../../admin/widgets/admin_feedback.dart';
import 'parent_photos_screen.dart';
import 'parent_attendance_screen.dart';
import 'parent_meals_screen.dart';
import '../../homework/screens/parent_homework_screen.dart';
import '../../chat/screens/chat_list_screen.dart';
import 'parent_calendar_screen.dart';
import '../../live/screens/parent_live_screen.dart';
import '../../stickers/screens/parent_stickers_screen.dart';
import '../../../shared/widgets/role_badge.dart';
import '../../notifications/screens/notifications_screen.dart';

/// DEVELOPER_SPEC §8.4 — واجهة ولي الأمر
class ParentHomeScreen extends StatefulWidget {
  const ParentHomeScreen({super.key});

  @override
  State<ParentHomeScreen> createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends State<ParentHomeScreen> {
  List<StudentModel> _children = [];
  StudentModel? _selected;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final children =
          await StudentsRepository(context.read<AuthProvider>().api).myChildren();
      setState(() {
        _children = children;
        if (children.isEmpty) {
          _selected = null;
        } else if (_selected == null ||
            !children.any((c) => c.id == _selected!.id)) {
          _selected = children.first;
        }
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = formatAdminError(e);
        _loading = false;
      });
    }
  }

  void _open(Widget screen) {
    if (_selected == null) return;
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;

    return Theme(
      data: AppTheme.forRole('parent'),
      child: Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ملخص الطفل'),
          actions: [
            const NotificationsBellButton(),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loading ? null : _load,
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => context.read<AuthProvider>().logout(),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _load,
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
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
                                    'مرحباً، ${user.name}',
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                ),
                                const RoleBadge(role: 'parent'),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _children.isEmpty
                                  ? 'لا يوجد أطفال مرتبطين بحسابك'
                                  : 'متابعة طفلك في الروضة',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 8),
                      Text(_error!, style: const TextStyle(color: AppColors.coralRed)),
                    ],
                    if (_children.length > 1) ...[
                      const SizedBox(height: 12),
                      _SectionTitle('تبديل بين الأطفال'),
                      DropdownButtonFormField<StudentModel>(
                        value: _selected,
                        decoration:
                            const InputDecoration(labelText: 'اختر الطفل'),
                        items: _children
                            .map((c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(c.name),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => _selected = v),
                      ),
                    ],
                    if (_selected != null) ...[
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
                          title: Text(_selected!.name),
                          subtitle: Text('الصف: ${_selected!.className}'),
                        ),
                      ),
                      _SectionTitle('الصور والمحتوى'),
                      _MenuTile(
                        icon: Icons.photo_album,
                        title: 'ألبوم الصور',
                        subtitle: 'صور طفلك المنشورة فقط',
                        color: AppColors.kiddyBlue,
                        onTap: () =>
                            _open(ParentPhotosScreen(student: _selected!)),
                      ),
                      _MenuTile(
                        icon: Icons.calendar_month,
                        title: 'التقويم والبانرات',
                        subtitle: 'عطلات وإعلانات الروضة',
                        color: AppColors.linkGreen,
                        onTap: () => _open(const ParentCalendarScreen()),
                      ),
                      _SectionTitle('التعلم'),
                      _MenuTile(
                        icon: Icons.assignment,
                        title: 'الواجبات',
                        subtitle: 'عرض + تأكيد "تم الحل"',
                        color: AppColors.coralRed,
                        onTap: () =>
                            _open(ParentHomeworkScreen(student: _selected!)),
                      ),
                      _MenuTile(
                        icon: Icons.emoji_events,
                        title: 'ملصقات الطفل',
                        subtitle: 'الملصقات المكتسبة مع المستوى',
                        color: AppColors.warmOrange,
                        onTap: () =>
                            _open(ParentStickersScreen(student: _selected!)),
                      ),
                      _SectionTitle('اليومي'),
                      _MenuTile(
                        icon: Icons.fact_check,
                        title: 'الحضور والغياب',
                        subtitle: 'سجل حضور وانصراف طفلك',
                        color: AppColors.linkGreen,
                        onTap: () =>
                            _open(ParentAttendanceScreen(student: _selected!)),
                      ),
                      _MenuTile(
                        icon: Icons.restaurant,
                        title: 'الوجبات',
                        subtitle: 'تأكيد تناول الوجبة',
                        color: AppColors.warmOrange,
                        onTap: () =>
                            _open(ParentMealsScreen(student: _selected!)),
                      ),
                      _SectionTitle('التواصل'),
                      _MenuTile(
                        icon: Icons.notifications,
                        title: 'الإشعارات',
                        subtitle: 'حضور، واجبات، صور، إعلانات',
                        color: AppColors.kiddyBlue,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NotificationsScreen(),
                          ),
                        ),
                      ),
                      _MenuTile(
                        icon: Icons.live_tv,
                        title: 'مشاهدة البث المباشر',
                        subtitle: 'بث معلمة طفلك',
                        color: AppColors.coralRed,
                        onTap: () => _open(const ParentLiveScreen()),
                      ),
                      _MenuTile(
                        icon: Icons.chat,
                        title: 'الدردشة',
                        subtitle: 'مع معلمة الطفل فقط',
                        color: AppColors.kiddyBlue,
                        onTap: () =>
                            _open(const ChatListScreen(isParent: true)),
                      ),
                    ],
                  ],
                ),
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
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
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
