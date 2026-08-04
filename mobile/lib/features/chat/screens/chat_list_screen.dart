import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/student_model.dart';
import '../../../shared/services/admin_repository.dart';
import '../../../shared/services/students_repository.dart';
import '../services/chat_repository.dart';
import 'chat_room_screen.dart';

/// درdشة — admin ↔ teacher ↔ parent (كل الأدوار)
class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<Map<String, dynamic>> _conversations = [];
  bool _loading = true;

  ChatRepository _repo(BuildContext context) {
    final auth = context.read<AuthProvider>();
    return ChatRepository(auth.api, auth.accessToken);
  }

  Future<void> _load() async {
    try {
      final list = await _repo(context).listConversations();
      if (!mounted) return;
      setState(() {
        _conversations = list;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  String _title(Map<String, dynamic> c) {
    final user = context.read<AuthProvider>().user!;
    final student = c['student'] as Map<String, dynamic>?;
    final studentSuffix =
        student != null ? ' — ${student['name'] ?? ''}' : '';

    final kind = c['kind']?.toString() ?? 'teacher_parent';
    final teacher = c['teacher'] as Map<String, dynamic>?;
    final teacherUser = teacher?['user'] as Map<String, dynamic>?;
    final parent = c['parent'] as Map<String, dynamic>?;
    final parentUser = parent?['user'] as Map<String, dynamic>?;
    final adminUser = c['adminUser'] as Map<String, dynamic>?;

    if (user.isAdmin) {
      if (kind == 'admin_teacher') {
        return 'المعلمة ${teacherUser?['name'] ?? ''}$studentSuffix';
      }
      return 'ولي الأمر ${parentUser?['name'] ?? ''}$studentSuffix';
    }

    if (user.isTeacher) {
      if (kind == 'admin_teacher') {
        return 'المديرة ${adminUser?['name'] ?? ''}$studentSuffix';
      }
      return 'ولي الأمر ${parentUser?['name'] ?? ''}$studentSuffix';
    }

    if (kind == 'admin_parent') {
      return 'المديرة ${adminUser?['name'] ?? ''}$studentSuffix';
    }
    return 'المعلمة ${teacherUser?['name'] ?? ''}$studentSuffix';
  }

  String _preview(Map<String, dynamic> c) {
    final messages = c['messages'] as List<dynamic>?;
    if (messages == null || messages.isEmpty) return 'لا رسائل بعد';
    final last = messages.first as Map<String, dynamic>;
    return last['body']?.toString() ?? 'مرفق';
  }

  Future<void> _startChat() async {
    final auth = context.read<AuthProvider>();
    final user = auth.user!;
    final repo = _repo(context);
    final studentsRepo = StudentsRepository(auth.api);
    final adminRepo = AdminRepository(auth.api);

    try {
      if (user.isParent) {
        final target = await _pickTarget(['teacher', 'admin'], {
          'teacher': 'المعلمة',
          'admin': 'المديرة',
        });
        if (target == null) return;

        final children = await studentsRepo.myChildren();
        if (children.isEmpty || !mounted) {
          _snack('لا يوجد أطفال مرتبطين');
          return;
        }
        final child = await _pickStudent(children);
        if (child == null) return;

        final conv = await repo.createConversation(
          targetRole: target,
          studentId: child.id,
        );
        await _openRoom(conv);
        return;
      }

      if (user.isTeacher) {
        final target = await _pickTarget(['parent', 'admin'], {
          'parent': 'ولي أمر',
          'admin': 'المديرة',
        });
        if (target == null) return;

        if (target == 'admin') {
          final conv = await repo.createConversation(targetRole: 'admin');
          await _openRoom(conv);
          return;
        }

        final students = await studentsRepo.myClass();
        if (students.isEmpty || !mounted) {
          _snack('لا يوجد طلاب في صفك');
          return;
        }
        final student = await _pickStudent(students);
        if (student == null) return;

        final conv = await repo.createConversation(
          targetRole: 'parent',
          studentId: student.id,
        );
        await _openRoom(conv);
        return;
      }

      if (user.isAdmin) {
        final target = await _pickTarget(['teacher', 'parent'], {
          'teacher': 'معلمة',
          'parent': 'ولي أمر',
        });
        if (target == null) return;

        if (target == 'teacher') {
          final teachers = await adminRepo.listTeacherOptions();
          if (teachers.isEmpty || !mounted) {
            _snack('لا توجد معلمات');
            return;
          }
          final teacher = await _pickMap(
            teachers,
            title: 'اختر معلمة',
            label: (t) {
              final u = t['user'] as Map<String, dynamic>?;
              return u?['name']?.toString() ?? 'معلمة';
            },
          );
          if (teacher == null) return;

          final conv = await repo.createConversation(
            targetRole: 'teacher',
            teacherId: teacher['id'] as int,
          );
          await _openRoom(conv);
          return;
        }

        final parents = await adminRepo.listParents();
        if (parents.isEmpty || !mounted) {
          _snack('لا يوجد أولياء أمور');
          return;
        }
        final parent = await _pickMap(
          parents,
          title: 'اختر ولي أمر',
          label: (p) {
            final u = p['user'] as Map<String, dynamic>?;
            return u?['name']?.toString() ?? 'ولي أمر';
          },
        );
        if (parent == null) return;

        final links = parent['students'] as List<dynamic>? ?? [];
        if (links.isEmpty) {
          _snack('لا يوجد أطفال مرتبطين بهذا ولي الأمر');
          return;
        }
        final student = await _pickMap(
          links,
          title: 'اختر الطفل',
          label: (l) {
            final s = l['student'] as Map<String, dynamic>?;
            return s?['name']?.toString() ?? 'طالب';
          },
        );
        if (student == null) return;
        final s = student['student'] as Map<String, dynamic>;

        final conv = await repo.createConversation(
          targetRole: 'parent',
          parentId: parent['id'] as int,
          studentId: s['id'] as int,
        );
        await _openRoom(conv);
      }
    } catch (e) {
      _snack(e.toString());
    }
  }

  Future<void> _openRoom(Map<String, dynamic> conv) async {
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatRoomScreen(conversation: conv)),
    );
    await _load();
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.coralRed),
    );
  }

  Future<String?> _pickTarget(
    List<String> keys,
    Map<String, String> labels,
  ) async {
    return showDialog<String>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: SimpleDialog(
          title: const Text('محادثة جديدة مع'),
          children: keys
              .map(
                (k) => SimpleDialogOption(
                  onPressed: () => Navigator.pop(ctx, k),
                  child: Text(labels[k] ?? k),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Future<StudentModel?> _pickStudent(List<StudentModel> students) async {
    if (students.length == 1) return students.first;
    return showDialog<StudentModel>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: SimpleDialog(
          title: const Text('اختر الطفل'),
          children: students
              .map(
                (s) => SimpleDialogOption(
                  onPressed: () => Navigator.pop(ctx, s),
                  child: Text(s.name),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Future<Map<String, dynamic>?> _pickMap(
    List<dynamic> items, {
    required String title,
    required String Function(Map<String, dynamic>) label,
  }) async {
    final maps = items.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    if (maps.isEmpty) return null;
    if (maps.length == 1) return maps.first;
    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: SimpleDialog(
          title: Text(title),
          children: maps
              .map(
                (item) => SimpleDialogOption(
                  onPressed: () => Navigator.pop(ctx, item),
                  child: Text(label(item)),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = _loading
        ? const Center(child: CircularProgressIndicator())
        : _conversations.isEmpty
            ? const Center(child: Text('لا محادثات بعد — اضغط + لبدء محادثة'))
            : RefreshIndicator(
                onRefresh: _load,
                child: ListView.builder(
                  itemCount: _conversations.length,
                  itemBuilder: (_, i) {
                    final c = _conversations[i];
                    return ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.chat_bubble_outline),
                      ),
                      title: Text(_title(c)),
                      subtitle: Text(_preview(c)),
                      onTap: () => _openRoom(c),
                    );
                  },
                ),
              );

    if (widget.embedded) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            Positioned.fill(child: body),
            Positioned(
              left: 16,
              bottom: 16,
              child: FloatingActionButton(
                onPressed: _startChat,
                tooltip: 'محادثة جديدة',
                child: const Icon(Icons.add_comment),
              ),
            ),
          ],
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('الدردشة')),
        floatingActionButton: FloatingActionButton(
          onPressed: _startChat,
          tooltip: 'محادثة جديدة',
          child: const Icon(Icons.add_comment),
        ),
        body: body,
      ),
    );
  }
}
