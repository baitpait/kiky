import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/student_model.dart';
import '../../../shared/widgets/labeled_dropdown.dart';
import '../../../shared/services/homework_repository.dart';
import 'teacher_attendance_screen.dart';
import '../../homework/screens/teacher_homework_screen.dart';

import '../../admin/widgets/admin_feedback.dart';

/// DEVELOPER_SPEC §8.3 #3 — ملف طالب (حضور، واجبات، ملصقات)
class TeacherStudentProfileScreen extends StatefulWidget {
  const TeacherStudentProfileScreen({super.key, required this.student});

  final StudentModel student;

  @override
  State<TeacherStudentProfileScreen> createState() =>
      _TeacherStudentProfileScreenState();
}

class _TeacherStudentProfileScreenState extends State<TeacherStudentProfileScreen> {
  List<Map<String, dynamic>> _stickers = [];
  bool _loadingStickers = true;
  String? _stickerError;

  HomeworkRepository get _repo =>
      HomeworkRepository(context.read<AuthProvider>().api);

  @override
  void initState() {
    super.initState();
    _loadStickers();
  }

  Future<void> _loadStickers() async {
    setState(() {
      _loadingStickers = true;
      _stickerError = null;
    });
    try {
      final data = await _repo.studentStickers(widget.student.id);
      if (!mounted) return;
      setState(() {
        _stickers = data;
        _loadingStickers = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingStickers = false;
        _stickerError = formatAdminError(e);
      });
    }
  }

  Future<void> _editSticker(Map<String, dynamic> record) async {
    List<Map<String, dynamic>> available;
    try {
      available = await _repo.activeStickers();
    } catch (e) {
      if (mounted) showAdminError(context, e);
      return;
    }
    if (available.isEmpty) {
      if (mounted) showAdminError(context, 'لا توجد ملصقات نشطة');
      return;
    }

    final sticker = record['sticker'] as Map<String, dynamic>?;
    final currentId = sticker?['id'] as int? ?? available.first['id'] as int;
    final noteCtrl = TextEditingController(text: record['note']?.toString() ?? '');
    int selectedId = currentId;

    if (!mounted) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تعديل الملصق'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LabeledDropdown<int>(
                  label: 'الملصق',
                  value: selectedId,
                  items: available
                      .map((s) => DropdownMenuItem(
                            value: s['id'] as int,
                            child: Text(s['name']?.toString() ?? ''),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) selectedId = v;
                  },
                ),
                TextField(
                  controller: noteCtrl,
                  decoration: const InputDecoration(labelText: 'ملاحظة'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );

    if (ok != true) return;

    try {
      await _repo.updateStudentSticker(
        record['id'] as int,
        stickerId: selectedId,
        note: noteCtrl.text.trim(),
      );
      await _loadStickers();
      if (mounted) showAdminSuccess(context, 'تم تعديل الملصق');
    } catch (e) {
      if (mounted) showAdminError(context, e);
    }
  }

  Future<void> _removeSticker(Map<String, dynamic> record) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('إلغاء الملصق'),
          content: const Text('هل تريدين إلغاء هذا الملصق من الطالب؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('لا'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.coralRed),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('إلغاء الملصق'),
            ),
          ],
        ),
      ),
    );

    if (ok != true) return;

    try {
      await _repo.removeStudentSticker(record['id'] as int);
      await _loadStickers();
      if (mounted) showAdminSuccess(context, 'تم إلغاء الملصق');
    } catch (e) {
      if (mounted) showAdminError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.student;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text('ملف ${s.name}')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.kiddyBlue.withValues(alpha: 0.15),
                  child: const Icon(Icons.child_care, color: AppColors.kiddyBlue),
                ),
                title: Text(s.name),
                subtitle: Text('الصف: ${s.className}'),
              ),
            ),
            const SizedBox(height: 12),
            _ActionTile(
              icon: Icons.fact_check,
              title: 'الحضور والانصراف',
              color: AppColors.linkGreen,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TeacherAttendanceScreen(initialStudent: s),
                ),
              ),
            ),
            _ActionTile(
              icon: Icons.assignment,
              title: 'الواجبات',
              color: AppColors.coralRed,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TeacherHomeworkScreen(
                    mode: TeacherHomeworkMode.all,
                    studentFilter: s,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'ملصقات الطالب',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadStickers,
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_loadingStickers)
              const Center(child: CircularProgressIndicator())
            else if (_stickerError != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(_stickerError!, textAlign: TextAlign.center),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _loadStickers,
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                ),
              )
            else if (_stickers.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('لا توجد ملصقات بعد'),
                ),
              )
            else
              ..._stickers.map((st) {
                final sticker = st['sticker'] as Map<String, dynamic>?;
                final level = sticker?['level'] as Map<String, dynamic>?;
                final homework = st['homework'] as Map<String, dynamic>?;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(
                      Icons.emoji_events,
                      color: AppColors.warmOrange,
                    ),
                    title: Text(sticker?['name']?.toString() ?? ''),
                    subtitle: Text(
                      'المستوى: ${level?['name'] ?? '—'}'
                      '${homework != null ? ' — ${homework['title']}' : ''}',
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (action) {
                        if (action == 'edit') {
                          _editSticker(st);
                        } else if (action == 'delete') {
                          _removeSticker(st);
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('تعديل')),
                        PopupMenuItem(value: 'delete', child: Text('إلغاء')),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: color),
        title: Text(title),
        trailing: const Icon(Icons.chevron_left),
      ),
    );
  }
}
