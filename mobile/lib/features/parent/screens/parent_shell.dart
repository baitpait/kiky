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
import 'parent_home_tab.dart';
import 'parent_learning_tab.dart';
import 'parent_more_tab.dart';
import 'parent_photos_screen.dart';

/// DEVELOPER_SPEC §8.4 — ولي الأمر مع Bottom Navigation حسب الدور
class ParentShell extends StatefulWidget {
  const ParentShell({super.key});

  @override
  State<ParentShell> createState() => _ParentShellState();
}

class _ParentShellState extends State<ParentShell> {
  int _tabIndex = 0;
  List<StudentModel> _children = [];
  StudentModel? _selected;
  bool _loading = true;
  String? _error;

  static const _titles = [
    'الرئيسية',
    'الصور',
    'التعلّم',
    'الدردشة',
    'المزيد',
  ];

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  Future<void> _loadChildren() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final children = await StudentsRepository(
        context.read<AuthProvider>().api,
      ).myChildren();
      if (!mounted) return;
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
      if (!mounted) return;
      setState(() {
        _error = formatAdminError(e);
        _loading = false;
      });
    }
  }

  Widget _emptyChildHint(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading && _tabIndex == 0) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _children.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadChildren,
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }

    final selected = _selected;
    final user = context.watch<AuthProvider>().user!;

    switch (_tabIndex) {
      case 0:
        return ParentHomeTab(
          userName: user.name,
          children: _children,
          selected: selected,
          onChildChanged: (v) => setState(() => _selected = v),
          onRefresh: _loadChildren,
          loading: _loading,
        );
      case 1:
        if (selected == null) {
          return _emptyChildHint('لا يوجد أطفال مرتبطين لعرض الصور');
        }
        return ParentPhotosScreen(student: selected, embedded: true);
      case 2:
        if (selected == null) {
          return _emptyChildHint('لا يوجد أطفال مرتبطين');
        }
        return ParentLearningTab(student: selected);
      case 3:
        return const ChatListScreen(embedded: true);
      case 4:
        if (selected == null) {
          return _emptyChildHint('لا يوجد أطفال مرتبطين');
        }
        return ParentMoreTab(student: selected);
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.forRole('parent'),
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
                    onPressed: _loading ? null : _loadChildren,
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
                  icon: Icon(Icons.photo_album_outlined),
                  selectedIcon: Icon(Icons.photo_album),
                  label: 'الصور',
                ),
                NavigationDestination(
                  icon: Icon(Icons.school_outlined),
                  selectedIcon: Icon(Icons.school),
                  label: 'التعلّم',
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
