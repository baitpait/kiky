import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/json_utils.dart';
import '../../../shared/services/content_repository.dart';

import '../widgets/admin_feedback.dart';

class AdminBannersScreen extends StatefulWidget {
  const AdminBannersScreen({super.key});

  @override
  State<AdminBannersScreen> createState() => _AdminBannersScreenState();
}

class _AdminBannersScreenState extends State<AdminBannersScreen> {
  List<Map<String, dynamic>> _banners = [];
  bool _loading = true;
  bool _submitting = false;
  String? _error;

  ContentRepository get _repo =>
      ContentRepository(context.read<AuthProvider>().api);

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
      final list = await _repo.listBanners();
      setState(() {
        _banners = list;
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
    final titleCtrl =
        TextEditingController(text: existing?['title']?.toString());
    final bodyCtrl = TextEditingController(text: existing?['body']?.toString());
    String target = existing?['target']?.toString() ?? 'all';

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: StatefulBuilder(
          builder: (ctx, setS) => AlertDialog(
            title: Text(isEdit ? 'تعديل بانر' : 'بانر جديد'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'العنوان'),
                ),
                TextField(
                  controller: bodyCtrl,
                  decoration: const InputDecoration(labelText: 'النص'),
                  maxLines: 3,
                ),
                DropdownButtonFormField<String>(
                  value: target,
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('الجميع')),
                    DropdownMenuItem(value: 'teachers', child: Text('معلمات')),
                    DropdownMenuItem(value: 'parents', child: Text('أولياء')),
                  ],
                  onChanged: (v) => setS(() => target = v!),
                  decoration: const InputDecoration(labelText: 'الاستهداف'),
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
                child: Text(isEdit ? 'حفظ' : 'إضافة'),
              ),
            ],
          ),
        ),
      ),
    );
    if (ok != true || !mounted) return;

    final title = titleCtrl.text.trim();
    final bodyText = bodyCtrl.text.trim();
    if (title.isEmpty || bodyText.isEmpty) {
      showAdminError(context, 'العنوان والنص مطلوبان');
      return;
    }

    setState(() => _submitting = true);
    try {
      final payload = {'title': title, 'body': bodyText, 'target': target};
      if (isEdit) {
        await _repo.updateBanner(asInt(existing['id']), payload);
        if (!mounted) return;
        showAdminSuccess(context, 'تم تحديث البانر');
      } else {
        await _repo.createBanner(payload);
        if (!mounted) return;
        showAdminSuccess(context, 'تم إضافة البانر');
      }
      await _load();
    } catch (e) {
      if (mounted) showAdminError(context, e);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _deactivate(Map<String, dynamic> banner) async {
    final title = banner['title']?.toString() ?? '';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تعطيل بانر'),
          content: Text('تعطيل "$title"؟'),
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
      await _repo.deleteBanner(asInt(banner['id']));
      showAdminSuccess(context, 'تم التعطيل');
      await _load();
    } catch (e) {
      if (mounted) showAdminError(context, e);
    }
  }

  String _targetLabel(String? t) {
    switch (t) {
      case 'teachers':
        return 'معلمات';
      case 'parents':
        return 'أولياء';
      default:
        return 'الجميع';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('إدارة البانرات')),
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
                  : _banners.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 120),
                            Center(child: Text('لا توجد بانرات')),
                          ],
                        )
                      : ListView.builder(
                    itemCount: _banners.length,
                    itemBuilder: (_, i) {
                      final b = _banners[i];
                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: ListTile(
                          title: Text(b['title']?.toString() ?? ''),
                          subtitle: Text(
                            '${b['body']?.toString() ?? ''}\nاستهداف: ${_targetLabel(b['target']?.toString())}',
                          ),
                          isThreeLine: true,
                          trailing: PopupMenuButton<String>(
                            onSelected: (v) {
                              if (v == 'edit') _showForm(existing: b);
                              if (v == 'delete') _deactivate(b);
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
