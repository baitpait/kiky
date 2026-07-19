import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/student_model.dart';
import '../../../shared/services/students_repository.dart';
import '../services/chat_repository.dart';
import 'chat_room_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key, this.isParent = false});

  final bool isParent;

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<Map<String, dynamic>> _conversations = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  ChatRepository _repo(BuildContext context) {
    final auth = context.read<AuthProvider>();
    return ChatRepository(auth.api, auth.accessToken);
  }

  Future<void> _load() async {
    try {
      final list = await _repo(context).listConversations();
      setState(() {
        _conversations = list;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _startChat() async {
    if (!widget.isParent) return;
    final students =
        await StudentsRepository(context.read<AuthProvider>().api).myChildren();
    if (students.isEmpty || !mounted) return;

    StudentModel? selected = students.first;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('محادثة جديدة'),
          content: DropdownButtonFormField<StudentModel>(
            value: selected,
            items: students
                .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
                .toList(),
            onChanged: (v) => selected = v,
            decoration: const InputDecoration(labelText: 'الطفل'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('بدء'),
            ),
          ],
        ),
      ),
    );
    if (ok != true || selected == null) return;

    try {
      final conv = await _repo(context).openConversation(selected!.id);
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatRoomScreen(conversation: conv),
        ),
      );
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  String _title(Map<String, dynamic> c) {
    final student = c['student'] as Map<String, dynamic>?;
    final user = context.read<AuthProvider>().user!;
    if (user.isTeacher) {
      final parent = c['parent'] as Map<String, dynamic>?;
      final parentUser = parent?['user'] as Map<String, dynamic>?;
      return '${parentUser?['name'] ?? 'ولي أمر'} — ${student?['name'] ?? ''}';
    }
    final teacher = c['teacher'] as Map<String, dynamic>?;
    final teacherUser = teacher?['user'] as Map<String, dynamic>?;
    return '${teacherUser?['name'] ?? 'المعلمة'} — ${student?['name'] ?? ''}';
  }

  String _preview(Map<String, dynamic> c) {
    final messages = c['messages'] as List<dynamic>?;
    if (messages == null || messages.isEmpty) return 'لا رسائل بعد';
    final last = messages.first as Map<String, dynamic>;
    return last['body']?.toString() ?? 'مرفق';
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('الدردشة')),
        floatingActionButton: widget.isParent
            ? FloatingActionButton(
                onPressed: _startChat,
                child: const Icon(Icons.add_comment),
              )
            : null,
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _conversations.isEmpty
                ? const Center(child: Text('لا محادثات بعد'))
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
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ChatRoomScreen(conversation: c),
                              ),
                            );
                            await _load();
                          },
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}
