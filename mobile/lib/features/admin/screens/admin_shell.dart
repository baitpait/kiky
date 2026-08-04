import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/services/admin_repository.dart';
import '../widgets/admin_feedback.dart';
import '../../chat/screens/chat_list_screen.dart';
import '../../notifications/screens/notifications_screen.dart';
import '../../../shared/widgets/role_navigation_bar.dart';
import 'admin_accounts_tab.dart';
import 'admin_approvals_tab.dart';
import 'admin_home_tab.dart';
import 'admin_more_tab.dart';
import 'admin_pending_photos_screen.dart';
import 'admin_students_screen.dart';
import 'admin_teachers_screen.dart';

/// DEVELOPER_SPEC §8.2 — المديرة مع Bottom Navigation
class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _tabIndex = 0;
  Map<String, dynamic>? _stats;
  bool _loadingStats = true;
  String? _statsError;

  static const _titles = [
    'لوحة التحكم',
    'الحسابات',
    'الموافقات',
    'الدردشة',
    'المزيد',
  ];

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
      if (!mounted) return;
      setState(() {
        _stats = stats;
        _loadingStats = false;
      });
    } catch (e) {
      if (!mounted) return;
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

  Widget _buildBody() {
    final user = context.watch<AuthProvider>().user!;

    switch (_tabIndex) {
      case 0:
        return AdminHomeTab(
          userName: user.name,
          stats: _stats,
          loading: _loadingStats,
          statsError: _statsError,
          apiOffline: _apiOffline,
          onRefresh: _loadStats,
          count: _count,
          onOpenTeachers: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminTeachersScreen()),
          ).then((_) => _loadStats()),
          onOpenStudents: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminStudentsScreen()),
          ).then((_) => _loadStats()),
          onOpenPendingPhotos: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AdminPendingPhotosScreen(),
            ),
          ).then((_) => _loadStats()),
        );
      case 1:
        return AdminAccountsTab(count: _count);
      case 2:
        return AdminApprovalsTab(
          pendingCount: _count('pendingPhotos'),
          onRefresh: _loadStats,
        );
      case 3:
        return const ChatListScreen(embedded: true);
      case 4:
        return AdminMoreTab(count: _count);
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.forRole('admin'),
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
                    onPressed: _loadingStats ? null : _loadStats,
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
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: 'الرئيسية',
                ),
                NavigationDestination(
                  icon: Icon(Icons.manage_accounts_outlined),
                  selectedIcon: Icon(Icons.manage_accounts),
                  label: 'الحسابات',
                ),
                NavigationDestination(
                  icon: Icon(Icons.photo_library_outlined),
                  selectedIcon: Icon(Icons.photo_library),
                  label: 'الموافقات',
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
