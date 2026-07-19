import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/student_model.dart';
import '../../../shared/services/students_repository.dart';
import '../../../shared/services/homework_repository.dart';

import '../../admin/widgets/admin_feedback.dart';

enum TeacherHomeworkMode { all, create, grade }

class TeacherHomeworkScreen extends StatefulWidget {
  const TeacherHomeworkScreen({
    super.key,
    this.mode = TeacherHomeworkMode.all,
    this.studentFilter,
  });

  final TeacherHomeworkMode mode;
  final StudentModel? studentFilter;

  @override
  State<TeacherHomeworkScreen> createState() => _TeacherHomeworkScreenState();
}

class _TeacherHomeworkScreenState extends State<TeacherHomeworkScreen> {
  List<Map<String, dynamic>> _homeworks = [];
  bool _loading = true;
  String? _error;

  HomeworkRepository get _repo =>
      HomeworkRepository(context.read<AuthProvider>().api);

  @override
  void initState() {
    super.initState();
    _load().then((_) {
      if (widget.mode == TeacherHomeworkMode.create && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _createHomework());
      }
    });
  }

  List<Map<String, dynamic>> get _visibleHomeworks {
    var list = _homeworks;
    if (widget.studentFilter != null) {
      final id = widget.studentFilter!.id;
      list = list.where((h) {
        final student = h['student'] as Map<String, dynamic>?;
        return student?['id'] == id;
      }).toList();
    }
    if (widget.mode == TeacherHomeworkMode.grade) {
      list = list.where((h) => h['status'] == 'submitted').toList();
    }
    return list;
  }

  String get _title {
    switch (widget.mode) {
      case TeacherHomeworkMode.create:
        return 'إنشاء واجب';
      case TeacherHomeworkMode.grade:
        return 'تصحيح واجبات';
      case TeacherHomeworkMode.all:
        return 'الواجبات';
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _repo.listForTeacher();
      if (!mounted) return;
      setState(() {
        _homeworks = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = formatAdminError(e);
      });
    }
  }

  Future<void> _createHomework() async {
    final repo = StudentsRepository(context.read<AuthProvider>().api);
    final students = await repo.myClass();
    if (students.isEmpty || !mounted) return;

    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    StudentModel? selected =
        widget.studentFilter ?? (students.isNotEmpty ? students.first : null);

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('واجب جديد'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<StudentModel>(
                  value: selected,
                  items: students
                      .map((s) => DropdownMenuItem(
                            value: s,
                            child: Text(s.name),
                          ))
                      .toList(),
                  onChanged: (v) => selected = v,
                  decoration: const InputDecoration(labelText: 'الطالب'),
                ),
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'العنوان *'),
                ),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'الوصف *'),
                  maxLines: 3,
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
              child: const Text('إنشاء'),
            ),
          ],
        ),
      ),
    );

    if (ok != true || selected == null) return;

    final title = titleCtrl.text.trim();
    final description = descCtrl.text.trim();
    if (title.isEmpty || description.isEmpty) {
      if (mounted) {
        showAdminError(context, 'العنوان والوصف مطلوبان');
      }
      return;
    }

    try {
      await _repo.create(
        studentId: selected!.id,
        title: title,
        description: description,
      );
      await _load();
      if (mounted) showAdminSuccess(context, 'تم إنشاء الواجب');
    } catch (e) {
      if (mounted) showAdminError(context, e);
    }
  }

  Future<void> _grade(int id) async {
    final gradeCtrl = TextEditingController(text: 'ممتاز');
    final noteCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تصحيح الواجب'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: gradeCtrl,
                decoration: const InputDecoration(labelText: 'الدرجة'),
              ),
              TextField(
                controller: noteCtrl,
                decoration: const InputDecoration(labelText: 'ملاحظة'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('تصحيح + AI'),
            ),
          ],
        ),
      ),
    );

    if (ok != true) return;

    try {
      final result = await _repo.grade(
        homeworkId: id,
        teacherGrade: gradeCtrl.text.trim(),
        teacherNote: noteCtrl.text.trim(),
      );
      await _load();
      if (mounted) {
        final ai = result['ai'] as Map<String, dynamic>?;
        showAdminSuccess(
          context,
          ai != null
              ? 'تم التصحيح — AI اختار ملصق (ثقة: ${ai['confidence']})'
              : 'تم التصحيح',
        );
      }
    } catch (e) {
      if (mounted) showAdminError(context, e);
    }
  }

  String _statusLabel(String? status) {
    switch (status) {
      case 'assigned':
        return 'بانتظار الحل';
      case 'submitted':
        return 'بانتظار التصحيح';
      case 'graded':
        return 'مُصحَّح';
      default:
        return status ?? '';
    }
  }

  String? _submissionGrade(Map<String, dynamic> homework) {
    final submissions = homework['submissions'] as List<dynamic>?;
    if (submissions == null || submissions.isEmpty) return null;
    final sub = submissions.first as Map<String, dynamic>;
    return sub['teacherGrade']?.toString();
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off, size: 48, color: AppColors.coralRed),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _load, child: const Text('إعادة المحاولة')),
            ],
          ),
        ),
      );
    }
    if (_visibleHomeworks.isEmpty) {
      return Center(
        child: Text(
          widget.mode == TeacherHomeworkMode.grade
              ? 'لا توجد واجبات بانتظار التصحيح'
              : 'لا توجد واجبات',
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _visibleHomeworks.length,
        itemBuilder: (_, i) {
          final h = _visibleHomeworks[i];
          final student = h['student'] as Map<String, dynamic>?;
          final status = h['status'] as String?;
          final grade = _submissionGrade(h);
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(h['title']?.toString() ?? ''),
              subtitle: Text(
                '${student?['name'] ?? ''} — ${_statusLabel(status)}'
                '${grade != null ? ' — $grade' : ''}',
              ),
              isThreeLine: h['description'] != null,
              trailing: status == 'submitted'
                  ? IconButton(
                      icon: const Icon(Icons.grade, color: AppColors.kiddyBlue),
                      onPressed: () => _grade(h['id'] as int),
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text(_title)),
        floatingActionButton: widget.mode != TeacherHomeworkMode.grade
            ? FloatingActionButton(
                onPressed: _createHomework,
                child: const Icon(Icons.add),
              )
            : null,
        body: _buildBody(),
      ),
    );
  }
}
