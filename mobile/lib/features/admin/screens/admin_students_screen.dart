import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/json_utils.dart';
import '../../../shared/services/admin_repository.dart';
import '../../../shared/widgets/labeled_dropdown.dart';
import '../widgets/admin_feedback.dart';
import '../widgets/safe_admin_feedback.dart';

class AdminStudentsScreen extends StatefulWidget {
  const AdminStudentsScreen({super.key});

  @override
  State<AdminStudentsScreen> createState() => _AdminStudentsScreenState();
}

class _AdminStudentsScreenState extends State<AdminStudentsScreen> {
  List<Map<String, dynamic>> _students = [];
  bool _loading = true;
  bool _submitting = false;
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
      final students = await _repo.listStudents();
      setState(() {
        _students = students;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = formatAdminError(e);
        _loading = false;
      });
    }
  }

  Future<void> _showForm({Map<String, dynamic>? existing}) async {
    final isEdit = existing != null;
    final nameCtrl = TextEditingController(text: existing?['name']?.toString());
    final classCtrl =
        TextEditingController(text: existing?['className']?.toString());
    final birthCtrl = TextEditingController(
      text: existing?['birthDate']?.toString().split('T').first ?? '',
    );
    final formKey = GlobalKey<FormState>();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(isEdit ? 'تعديل طالب' : 'طالب جديد'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'اسم الطالب'),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'مطلوب' : null,
                  ),
                  TextFormField(
                    controller: classCtrl,
                    decoration: const InputDecoration(labelText: 'الصف / الفصل'),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'مطلوب' : null,
                  ),
                  TextFormField(
                    controller: birthCtrl,
                    decoration: const InputDecoration(
                      labelText: 'تاريخ الميلاد (YYYY-MM-DD)',
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(ctx, true);
                }
              },
              child: Text(isEdit ? 'حفظ' : 'إنشاء'),
            ),
          ],
        ),
      ),
    );

    if (ok != true || !mounted) return;

    setState(() => _submitting = true);
    try {
      final birth = birthCtrl.text.trim();
      if (isEdit) {
        await _repo.updateStudent(
          asInt(existing['id']),
          name: nameCtrl.text.trim(),
          className: classCtrl.text.trim(),
          birthDate: birth.isEmpty ? null : birth,
        );
        adminSuccess('تم تحديث الطالب');
      } else {
        await _repo.createStudent(
          name: nameCtrl.text.trim(),
          className: classCtrl.text.trim(),
          birthDate: birth.isEmpty ? null : birth,
        );
        adminSuccess('تم إنشاء الطالب');
      }
      await _load();
    } catch (e) {
      if (mounted) adminError(e);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _linkParent(Map<String, dynamic> student) async {
    List<Map<String, dynamic>> parents;
    try {
      parents = await _repo.listParentOptions();
    } catch (e) {
      if (mounted) adminError(e);
      return;
    }
    if (parents.isEmpty) {
      if (!mounted) return;
      showAdminError(context, 'أضف ولي أمر أولاً');
      return;
    }
    int? parentId = asInt(parents.first['id']);

    if (!mounted) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('ربط ولي أمر'),
          content: StatefulBuilder(
            builder: (ctx, setS) => LabeledDropdown<int>(
              label: 'ولي الأمر',
              value: parentId,
              items: parents.map((p) {
                final user = p['user'] as Map<String, dynamic>?;
                return DropdownMenuItem(
                  value: asInt(p['id']),
                  child: Text(user?['name']?.toString() ?? ''),
                );
              }).toList(),
              onChanged: (v) => setS(() => parentId = v),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('ربط'),
            ),
          ],
        ),
      ),
    );

    if (ok != true || parentId == null || !mounted) return;
    try {
      await _repo.linkParent(asInt(student['id']), parentId!);
      adminSuccess('تم الربط');
      await _load();
    } catch (e) {
      if (mounted) adminError(e);
    }
  }

  Future<void> _linkTeacher(Map<String, dynamic> student) async {
    List<Map<String, dynamic>> teachers;
    try {
      teachers = await _repo.listTeacherOptions();
    } catch (e) {
      if (mounted) adminError(e);
      return;
    }
    if (teachers.isEmpty) {
      if (!mounted) return;
      showAdminError(context, 'أضف معلمة أولاً');
      return;
    }
    int? teacherId = asInt(teachers.first['id']);

    if (!mounted) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('ربط معلمة'),
          content: StatefulBuilder(
            builder: (ctx, setS) => LabeledDropdown<int>(
              label: 'المعلمة',
              value: teacherId,
              items: teachers.map((t) {
                final user = t['user'] as Map<String, dynamic>?;
                return DropdownMenuItem(
                  value: asInt(t['id']),
                  child: Text(user?['name']?.toString() ?? ''),
                );
              }).toList(),
              onChanged: (v) => setS(() => teacherId = v),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('ربط'),
            ),
          ],
        ),
      ),
    );

    if (ok != true || teacherId == null || !mounted) return;
    try {
      await _repo.linkTeacher(asInt(student['id']), teacherId!);
      adminSuccess('تم الربط');
      await _load();
    } catch (e) {
      if (mounted) adminError(e);
    }
  }

  Future<void> _deactivate(Map<String, dynamic> student) async {
    final name = student['name']?.toString() ?? '';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تعطيل طالب'),
          content: Text('تعطيل $name؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.coralRed),
              child: const Text('تعطيل'),
            ),
          ],
        ),
      ),
    );
    if (confirm != true || !mounted) return;
    try {
      await _repo.deactivateStudent(asInt(student['id']));
      adminSuccess('تم التعطيل');
      await _load();
    } catch (e) {
      if (mounted) adminError(e);
    }
  }

  String _linkedNames(List? links, String nestedKey, String userKey) {
    if (links == null || links.isEmpty) return '—';
    return links.map((l) {
      final nested = l[nestedKey] as Map<String, dynamic>?;
      final user = nested?['user'] as Map<String, dynamic>?;
      return user?[userKey]?.toString() ?? nested?['name']?.toString() ?? '';
    }).join('، ');
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('إدارة الطلاب')),
        floatingActionButton: FloatingActionButton(
          onPressed: _submitting ? null : () => _showForm(),
          child: _submitting
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.add),
        ),
        body: RefreshIndicator(
          onRefresh: _load,
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? ListView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              Text(_error!, textAlign: TextAlign.center),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _load,
                                child: const Text('إعادة المحاولة'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : _students.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 120),
                            Center(child: Text('لا يوجد طلاب — أضف طالباً جديداً')),
                          ],
                        )
                      : ListView.builder(
                          itemCount: _students.length,
                          itemBuilder: (_, i) {
                            final s = _students[i];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            s['name']?.toString() ?? '',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                        ),
                                        PopupMenuButton<String>(
                                          onSelected: (v) {
                                            if (v == 'edit') _showForm(existing: s);
                                            if (v == 'delete') _deactivate(s);
                                          },
                                          itemBuilder: (_) => const [
                                            PopupMenuItem(
                                              value: 'edit',
                                              child: Text('تعديل'),
                                            ),
                                            PopupMenuItem(
                                              value: 'delete',
                                              child: Text('تعطيل'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Text('الصف: ${s['className']}'),
                                    Text(
                                      'أولياء: ${_linkedNames(s['parentLinks'] as List?, 'parent', 'name')}',
                                    ),
                                    Text(
                                      'معلمات: ${_linkedNames(s['teacherLinks'] as List?, 'teacher', 'name')}',
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        TextButton.icon(
                                          onPressed: () => _linkParent(s),
                                          icon: const Icon(Icons.link),
                                          label: const Text('ربط ولي'),
                                        ),
                                        TextButton.icon(
                                          onPressed: () => _linkTeacher(s),
                                          icon: const Icon(Icons.link),
                                          label: const Text('ربط معلمة'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
        ),
      ),
    );
  }
}
