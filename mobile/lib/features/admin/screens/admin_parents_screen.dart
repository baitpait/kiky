import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/json_utils.dart';
import '../../../shared/services/admin_repository.dart';
import '../widgets/admin_feedback.dart';
import '../widgets/safe_admin_feedback.dart';

class AdminParentsScreen extends StatefulWidget {
  const AdminParentsScreen({super.key});

  @override
  State<AdminParentsScreen> createState() => _AdminParentsScreenState();
}

class _AdminParentsScreenState extends State<AdminParentsScreen> {
  List<Map<String, dynamic>> _parents = [];
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
      final list = await _repo.listParents();
      setState(() {
        _parents = list;
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
    final user = existing?['user'] as Map<String, dynamic>?;
    final usernameCtrl = TextEditingController(text: user?['username']?.toString());
    final nameCtrl = TextEditingController(text: user?['name']?.toString());
    final phoneCtrl = TextEditingController(text: user?['phone']?.toString() ?? '');
    final passwordCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(isEdit ? 'تعديل ولي أمر' : 'ولي أمر جديد'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: usernameCtrl,
                    decoration: const InputDecoration(labelText: 'اسم المستخدم'),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'مطلوب' : null,
                  ),
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'الاسم'),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'مطلوب' : null,
                  ),
                  TextFormField(
                    controller: phoneCtrl,
                    decoration: const InputDecoration(labelText: 'الهاتف (اختياري)'),
                    keyboardType: TextInputType.phone,
                  ),
                  TextFormField(
                    controller: passwordCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: isEdit ? 'كلمة مرور جديدة (اختياري)' : 'كلمة المرور',
                    ),
                    validator: (v) {
                      if (!isEdit && (v == null || v.length < 6)) {
                        return '6 أحرف على الأقل';
                      }
                      if (isEdit && v != null && v.isNotEmpty && v.length < 6) {
                        return '6 أحرف على الأقل';
                      }
                      return null;
                    },
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
      if (isEdit) {
        await _repo.updateParent(
          asInt(existing['id']),
          username: usernameCtrl.text.trim(),
          name: nameCtrl.text.trim(),
          phone: phoneCtrl.text.trim(),
          password: passwordCtrl.text.isEmpty ? null : passwordCtrl.text,
        );
        adminSuccess('تم تحديث ولي الأمر');
      } else {
        await _repo.createParent(
          username: usernameCtrl.text.trim(),
          password: passwordCtrl.text,
          name: nameCtrl.text.trim(),
          phone: phoneCtrl.text.trim(),
        );
        adminSuccess('تم إنشاء ولي الأمر');
      }
      await _load();
    } catch (e) {
      if (mounted) adminError(e);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _deactivate(Map<String, dynamic> parent) async {
    final user = parent['user'] as Map<String, dynamic>?;
    final name = user?['name']?.toString() ?? '';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تعطيل حساب'),
          content: Text('تعطيل حساب $name؟'),
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
      await _repo.deactivateParent(asInt(parent['id']));
      adminSuccess('تم التعطيل');
      await _load();
    } catch (e) {
      if (mounted) adminError(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('إدارة أولياء الأمور')),
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
                  : _parents.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 120),
                            Center(child: Text('لا يوجد أولياء — أضف ولياً جديداً')),
                          ],
                        )
                      : ListView.builder(
                          itemCount: _parents.length,
                          itemBuilder: (_, i) {
                            final p = _parents[i];
                            final user = p['user'] as Map<String, dynamic>?;
                            final students = (p['students'] as List?) ?? [];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              child: ListTile(
                                title: Text(user?['name']?.toString() ?? ''),
                                subtitle: Text(
                                  '${user?['username']} · ${students.length} طفل',
                                ),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (v) {
                                    if (v == 'edit') _showForm(existing: p);
                                    if (v == 'delete') _deactivate(p);
                                  },
                                  itemBuilder: (_) => const [
                                    PopupMenuItem(value: 'edit', child: Text('تعديل')),
                                    PopupMenuItem(value: 'delete', child: Text('تعطيل')),
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
