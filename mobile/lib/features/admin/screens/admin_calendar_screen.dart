import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/json_utils.dart';
import '../../../shared/services/content_repository.dart';
import '../widgets/admin_feedback.dart';

class AdminCalendarScreen extends StatefulWidget {
  const AdminCalendarScreen({super.key});

  @override
  State<AdminCalendarScreen> createState() => _AdminCalendarScreenState();
}

class _AdminCalendarScreenState extends State<AdminCalendarScreen> {
  List<Map<String, dynamic>> _events = [];
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
      final list = await _repo.listEvents();
      setState(() {
        _events = list;
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
    final descCtrl =
        TextEditingController(text: existing?['description']?.toString());
    final dateCtrl = TextEditingController(
      text: existing?['startDate']?.toString().split('T').first ??
          DateTime.now().toIso8601String().split('T').first,
    );
    String type = existing?['eventType']?.toString() ?? 'event';

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: StatefulBuilder(
          builder: (ctx, setS) => AlertDialog(
            title: Text(isEdit ? 'تعديل حدث' : 'حدث تقويمي'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(labelText: 'العنوان'),
                  ),
                  TextField(
                    controller: descCtrl,
                    decoration: const InputDecoration(labelText: 'الوصف'),
                  ),
                  TextField(
                    controller: dateCtrl,
                    decoration: const InputDecoration(
                      labelText: 'التاريخ (YYYY-MM-DD)',
                    ),
                  ),
                  DropdownButtonFormField<String>(
                    value: type,
                    items: const [
                      DropdownMenuItem(value: 'holiday', child: Text('عطلة')),
                      DropdownMenuItem(value: 'vacation', child: Text('إجازة')),
                      DropdownMenuItem(value: 'event', child: Text('فعالية')),
                    ],
                    onChanged: (v) => setS(() => type = v!),
                    decoration: const InputDecoration(labelText: 'النوع'),
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
                child: Text(isEdit ? 'حفظ' : 'إضافة'),
              ),
            ],
          ),
        ),
      ),
    );
    if (ok != true || !mounted) return;

    final title = titleCtrl.text.trim();
    final date = dateCtrl.text.trim();
    if (title.isEmpty || date.isEmpty) {
      showAdminError(context, 'العنوان والتاريخ مطلوبان');
      return;
    }

    final payload = {
      'title': title,
      'description': descCtrl.text.trim(),
      'eventType': type,
      'startDate': date,
    };

    setState(() => _submitting = true);
    try {
      if (isEdit) {
        await _repo.updateEvent(asInt(existing['id']), payload);
        if (!mounted) return;
        showAdminSuccess(context, 'تم تحديث الحدث');
      } else {
        await _repo.createEvent(payload);
        if (!mounted) return;
        showAdminSuccess(context, 'تم إضافة الحدث');
      }
      await _load();
    } catch (e) {
      if (mounted) showAdminError(context, e);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _deactivate(Map<String, dynamic> event) async {
    final title = event['title']?.toString() ?? '';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('حذف حدث'),
          content: Text('حذف "$title"؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.coralRed),
              child: const Text('حذف'),
            ),
          ],
        ),
      ),
    );
    if (confirm != true || !mounted) return;
    try {
      await _repo.deleteEvent(asInt(event['id']));
      showAdminSuccess(context, 'تم الحذف');
      await _load();
    } catch (e) {
      if (mounted) showAdminError(context, e);
    }
  }

  String _typeLabel(String? t) {
    switch (t) {
      case 'holiday':
        return 'عطلة';
      case 'vacation':
        return 'إجازة';
      default:
        return 'فعالية';
    }
  }

  Color _typeColor(String? t) {
    switch (t) {
      case 'holiday':
        return AppColors.linkGreen;
      case 'vacation':
        return AppColors.warmOrange;
      default:
        return AppColors.kiddyBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('التقويم السنوي')),
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
                  : _events.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 120),
                            Center(child: Text('لا توجد أحداث')),
                          ],
                        )
                      : ListView.builder(
                          itemCount: _events.length,
                          itemBuilder: (_, i) {
                            final e = _events[i];
                            final type = e['eventType']?.toString();
                            final date =
                                e['startDate']?.toString().split('T').first ?? '';
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      _typeColor(type).withValues(alpha: 0.2),
                                  child: Icon(Icons.event, color: _typeColor(type)),
                                ),
                                title: Text(e['title']?.toString() ?? ''),
                                subtitle: Text(
                                  '${_typeLabel(type)} — $date\n${e['description'] ?? ''}',
                                ),
                                isThreeLine: true,
                                trailing: PopupMenuButton<String>(
                                  onSelected: (v) {
                                    if (v == 'edit') _showForm(existing: e);
                                    if (v == 'delete') _deactivate(e);
                                  },
                                  itemBuilder: (_) => const [
                                    PopupMenuItem(value: 'edit', child: Text('تعديل')),
                                    PopupMenuItem(value: 'delete', child: Text('حذف')),
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
