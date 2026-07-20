import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/student_model.dart';
import '../../../shared/services/students_repository.dart';
import '../../admin/widgets/admin_feedback.dart';
import 'teacher_students_screen.dart';
import 'teacher_upload_photo_screen.dart';
import 'teacher_attendance_screen.dart';
import 'teacher_meals_screen.dart';
import 'teacher_calendar_screen.dart';
import '../../homework/screens/teacher_homework_screen.dart';
import '../../chat/screens/chat_list_screen.dart';
import '../../live/screens/teacher_live_screen.dart';
import '../../../shared/widgets/role_badge.dart';
import '../../notifications/screens/notifications_screen.dart';

/// DEVELOPER_SPEC §8.3 — واجهة المعلمة
class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  List<StudentModel> _students = [];
  List<dynamic> _todayAttendance = [];
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
    final api = context.read<AuthProvider>().api;
    try {
      final students = await StudentsRepository(api).myClass();
      final today = await api.get('/attendance/today');
      setState(() {
        _students = students;
        _todayAttendance = today is List ? today : [];
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
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen))
        .then((_) => _load());
  }

  int get _checkedInToday {
    final types = _todayAttendance.map((r) {
      if (r is Map) return r['type']?.toString();
      return null;
    });
    return types.where((t) => t == 'check_in').length;
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;

    return Theme(
      data: AppTheme.forRole('teacher'),
      child: Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('طلابي اليوم'),
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
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(_error!, style: const TextStyle(color: AppColors.coralRed)),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            label: 'طلابي',
                            value: '${_students.length}',
                            color: AppColors.kiddyBlue,
                            icon: Icons.groups,
                            onTap: () => _open(const TeacherStudentsScreen()),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _StatCard(
                            label: 'حضور اليوم',
                            value: '$_checkedInToday',
                            color: AppColors.linkGreen,
                            icon: Icons.fact_check,
                            onTap: () => _open(const TeacherAttendanceScreen()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _SectionTitle('الطلاب'),
                    _MenuTile(
                      icon: Icons.groups,
                      title: 'قائمة طلابي',
                      subtitle: '${_students.length} طالب مرتبط بك',
                      color: AppColors.kiddyBlue,
                      onTap: () => _open(const TeacherStudentsScreen()),
                    ),
                    _SectionTitle('الصور والمحتوى'),
                    _MenuTile(
                      icon: Icons.photo_camera,
                      title: 'رفع صور (ألبوم)',
                      subtitle: 'بانتظار موافقة المديرة',
                      color: AppColors.kiddyBlue,
                      onTap: () => _open(const TeacherUploadPhotoScreen()),
                    ),
                    _MenuTile(
                      icon: Icons.calendar_month,
                      title: 'التقويم',
                      subtitle: 'عطلات وفعاليات الروضة',
                      color: AppColors.linkGreen,
                      onTap: () => _open(const TeacherCalendarScreen()),
                    ),
                    _SectionTitle('الواجبات'),
                    _MenuTile(
                      icon: Icons.add_circle_outline,
                      title: 'إنشاء واجب',
                      subtitle: 'نشاط أو واجب منزلي لطالب',
                      color: AppColors.warmOrange,
                      onTap: () => _open(
                        const TeacherHomeworkScreen(mode: TeacherHomeworkMode.create),
                      ),
                    ),
                    _MenuTile(
                      icon: Icons.grade,
                      title: 'تصحيح واجبات',
                      subtitle: 'بعد تأكيد ولي الأمر',
                      color: AppColors.coralRed,
                      onTap: () => _open(
                        const TeacherHomeworkScreen(mode: TeacherHomeworkMode.grade),
                      ),
                    ),
                    _SectionTitle('اليومي'),
                    _MenuTile(
                      icon: Icons.fact_check,
                      title: 'تسجيل حضور/انصراف',
                      subtitle: 'حضور · انصراف · غياب',
                      color: AppColors.linkGreen,
                      onTap: () => _open(const TeacherAttendanceScreen()),
                    ),
                    _MenuTile(
                      icon: Icons.restaurant,
                      title: 'تأكيد وجبات',
                      subtitle: 'تأكيد تناول الوجبة في الروضة',
                      color: AppColors.warmOrange,
                      onTap: () => _open(const TeacherMealsScreen()),
                    ),
                    _SectionTitle('التواصل'),
                    _MenuTile(
                      icon: Icons.notifications,
                      title: 'الإشعارات',
                      subtitle: 'واجبات، وجبات، رسائل، إعلانات',
                      color: AppColors.kiddyBlue,
                      onTap: () => _open(const NotificationsScreen()),
                    ),
                    _MenuTile(
                      icon: Icons.live_tv,
                      title: 'بدء بث مباشر',
                      subtitle: 'المعلمة فقط تبدأ البث',
                      color: AppColors.coralRed,
                      onTap: () => _open(const TeacherLiveScreen()),
                    ),
                    _MenuTile(
                      icon: Icons.chat,
                      title: 'الدردشة',
                      subtitle: 'مع أولياء الأمور والمديرة',
                      color: AppColors.kiddyBlue,
                      onTap: () => _open(const ChatListScreen()),
                    ),
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
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
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
