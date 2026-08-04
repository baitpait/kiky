import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/student_model.dart';
import '../../../shared/services/students_repository.dart';
import '../../admin/widgets/admin_feedback.dart';
import '../../chat/screens/chat_list_screen.dart';
import '../../notifications/screens/notifications_screen.dart';
import '../../../shared/widgets/role_navigation_bar.dart';
import 'teacher_daily_tab.dart';
import 'teacher_home_tab.dart';
import 'teacher_more_tab.dart';
import 'teacher_students_screen.dart';

/// DEVELOPER_SPEC §8.3 — المعلمة مع Bottom Navigation
class TeacherShell extends StatefulWidget {
  const TeacherShell({super.key});

  @override
  State<TeacherShell> createState() => _TeacherShellState();
}

class _TeacherShellState extends State<TeacherShell> {
  int _tabIndex = 0;
  List<StudentModel> _students = [];
  List<dynamic> _todayAttendance = [];
  bool _loading = true;
  String? _error;

  static const _titles = [
    'الرئيسية',
    'الطلاب',
    'اليومي',
    'الدردشة',
    'المزيد',
  ];

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
      if (!mounted) return;
      setState(() {
        _students = students;
        _todayAttendance = today is List ? today : [];
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = formatAdminError(e);
        _loading = false;
      });
    }
  }

  int get _checkedInToday {
    return _todayAttendance
        .map((r) => r is Map ? r['type']?.toString() : null)
        .where((t) => t == 'check_in')
        .length;
  }

  Widget _buildBody() {
    final user = context.watch<AuthProvider>().user!;

    switch (_tabIndex) {
      case 0:
        return TeacherHomeTab(
          userName: user.name,
          students: _students,
          checkedInToday: _checkedInToday,
          onRefresh: _load,
          loading: _loading,
          error: _error,
        );
      case 1:
        return const TeacherStudentsScreen(embedded: true);
      case 2:
        return const TeacherDailyTab();
      case 3:
        return const ChatListScreen(embedded: true);
      case 4:
        return const TeacherMoreTab();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.forRole('teacher'),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: PopScope(
          canPop: _tabIndex == 0,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop && _tabIndex > 0) {
              setState(() => _tabIndex = 0);
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(_titles[_tabIndex]),
              actions: [
                const NotificationsBellButton(),
                if (_tabIndex == 0)
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
            body: _buildBody(),
            bottomNavigationBar: RoleNavigationBar(
              selectedIndex: _tabIndex,
              onDestinationSelected: (i) => setState(() => _tabIndex = i),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: 'الرئيسية',
                ),
                NavigationDestination(
                  icon: Icon(Icons.groups_outlined),
                  selectedIcon: Icon(Icons.groups),
                  label: 'الطلاب',
                ),
                NavigationDestination(
                  icon: Icon(Icons.today_outlined),
                  selectedIcon: Icon(Icons.today),
                  label: 'اليومي',
                ),
                NavigationDestination(
                  icon: Icon(Icons.chat_outlined),
                  selectedIcon: Icon(Icons.chat),
                  label: 'الدردشة',
                ),
                NavigationDestination(
                  icon: Icon(Icons.more_horiz),
                  selectedIcon: Icon(Icons.more_horiz),
                  label: 'المزيد',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
