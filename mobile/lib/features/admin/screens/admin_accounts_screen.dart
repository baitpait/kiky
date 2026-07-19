import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/services/admin_repository.dart';
import '../widgets/admin_feedback.dart';
import 'admin_teachers_screen.dart';
import 'admin_parents_screen.dart';
import 'admin_students_screen.dart';

/// DEVELOPER_SPEC §8.2 #11 — إنشاء/تعديل حساب
/// المديرة تنشئ كل الحسابات — لا تسجيل ذاتي.
class AdminAccountsScreen extends StatefulWidget {
  const AdminAccountsScreen({super.key});

  @override
  State<AdminAccountsScreen> createState() => _AdminAccountsScreenState();
}

class _AdminAccountsScreenState extends State<AdminAccountsScreen> {
  Map<String, dynamic>? _stats;
  bool _loading = true;
  String? _error;

  AdminRepository get _repo =>
      AdminRepository(context.read<AuthProvider>().api);

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
      final stats = await _repo.getDashboardStats();
      setState(() {
        _stats = stats;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = formatAdminError(e);
        _loading = false;
      });
    }
  }

  int _count(String key) {
    if (_stats == null) return 0;
    final v = _stats![key];
    if (v is int) return v;
    if (v is num) return v.toInt();
    return 0;
  }

  void _open(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen))
        .then((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('إنشاء/تعديل حساب')),
        body: RefreshIndicator(
          onRefresh: _load,
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      color: AppColors.softSky,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'المديرة تنشئ كل الحسابات',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'لا يوجد تسجيل ذاتي. أنشئي حساباً ثم سلّمي اسم المستخدم وكلمة المرور للمستخدم.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(_error!, style: const TextStyle(color: AppColors.coralRed)),
                    ],
                    const SizedBox(height: 16),
                    _AccountCard(
                      icon: Icons.person_outline,
                      color: AppColors.kiddyBlue,
                      title: 'حساب معلمة',
                      count: _count('teachers'),
                      onManage: () => _open(const AdminTeachersScreen()),
                    ),
                    _AccountCard(
                      icon: Icons.family_restroom,
                      color: AppColors.linkGreen,
                      title: 'حساب ولي أمر',
                      count: _count('parents'),
                      onManage: () => _open(const AdminParentsScreen()),
                    ),
                    _AccountCard(
                      icon: Icons.child_care,
                      color: AppColors.warmOrange,
                      title: 'حساب طالب + الربط',
                      count: _count('students'),
                      subtitle: 'اربطي الطالب بمعلمة وولي أمر',
                      onManage: () => _open(const AdminStudentsScreen()),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.count,
    required this.onManage,
    this.subtitle,
  });

  final IconData icon;
  final Color color;
  final String title;
  final int count;
  final String? subtitle;
  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onManage,
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(subtitle ?? '$count حساب نشط — اضغطي لإنشاء أو تعديل'),
        trailing: const Icon(Icons.chevron_left),
      ),
    );
  }
}
