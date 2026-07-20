import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/json_utils.dart';
import '../../../shared/services/sticker_repository.dart';
import '../../../shared/widgets/labeled_dropdown.dart';
import '../widgets/admin_feedback.dart';
import '../widgets/safe_admin_feedback.dart';

/// DEVELOPER_SPEC §8.2 #10 — إدارة الملصقات
class AdminStickersScreen extends StatefulWidget {
  const AdminStickersScreen({super.key});

  @override
  State<AdminStickersScreen> createState() => _AdminStickersScreenState();
}

class _AdminStickersScreenState extends State<AdminStickersScreen> {
  List<Map<String, dynamic>> _levels = [];
  List<Map<String, dynamic>> _stickers = [];
  bool _loading = true;
  bool _submitting = false;
  String? _error;

  StickerRepository get _repo =>
      StickerRepository(context.read<AuthProvider>().api);

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
      final levels = await _repo.listLevels();
      final stickers = await _repo.listStickers();
      setState(() {
        _levels = levels;
        _stickers = stickers;
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
    if (_levels.isEmpty) {
      showAdminError(context, 'أضف مستوى ملصق أولاً من شاشة المستويات');
      return;
    }

    final isEdit = existing != null;
    final nameCtrl =
        TextEditingController(text: existing?['name']?.toString());
    final iconCtrl = TextEditingController(
      text: existing?['iconUrl']?.toString() ?? '/stickers/new.png',
    );
    final descCtrl =
        TextEditingController(text: existing?['description']?.toString());
    int levelId = asInt(existing?['levelId'] ?? _levels.first['id']);

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: StatefulBuilder(
          builder: (ctx, setS) => AlertDialog(
            title: Text(isEdit ? 'تعديل ملصق' : 'ملصق جديد'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'اسم الملصق'),
                  ),
                  TextField(
                    controller: iconCtrl,
                    decoration: const InputDecoration(labelText: 'رابط الأيقونة'),
                  ),
                  TextField(
                    controller: descCtrl,
                    decoration: const InputDecoration(labelText: 'الوصف (اختياري)'),
                  ),
                  LabeledDropdown<int>(
                    label: 'المستوى',
                    value: levelId,
                    items: _levels
                        .map((l) => DropdownMenuItem(
                              value: asInt(l['id']),
                              child: Text(l['name']?.toString() ?? ''),
                            ))
                        .toList(),
                    onChanged: (v) => setS(() => levelId = v!),
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
    if (nameCtrl.text.trim().isEmpty || iconCtrl.text.trim().isEmpty) {
      showAdminError(context, 'اسم الملصق ورابط الأيقونة مطلوبان');
      return;
    }

    setState(() => _submitting = true);
    try {
      final name = nameCtrl.text.trim();
      final iconUrl = iconCtrl.text.trim();
      final description = descCtrl.text.trim();
      if (isEdit) {
        await _repo.updateSticker(
          asInt(existing['id']),
          name: name,
          iconUrl: iconUrl,
          levelId: levelId,
          description: description,
        );
        adminSuccess('تم تحديث الملصق');
      } else {
        await _repo.createSticker(
          name: name,
          iconUrl: iconUrl,
          levelId: levelId,
          description: description,
        );
        adminSuccess('تم إضافة الملصق');
      }
      await _load();
    } catch (e) {
      if (mounted) adminError(e);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _deactivate(Map<String, dynamic> sticker) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تعطيل ملصق'),
          content: Text('تعطيل "${sticker['name']}"؟'),
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
      await _repo.deactivateSticker(asInt(sticker['id']));
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
        appBar: AppBar(title: const Text('إدارة الملصقات')),
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
                  : _stickers.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 120),
                            Center(child: Text('لا توجد ملصقات — أضف ملصقاً جديداً')),
                          ],
                        )
                      : ListView.builder(
                          itemCount: _stickers.length,
                          itemBuilder: (_, i) {
                            final s = _stickers[i];
                            final level = s['level'] as Map<String, dynamic>?;
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.emoji_events,
                                  color: AppColors.warmOrange,
                                ),
                                title: Text(s['name']?.toString() ?? ''),
                                subtitle: Text(
                                  'المستوى: ${level?['name'] ?? '—'}\n${s['description'] ?? ''}',
                                ),
                                isThreeLine: true,
                                trailing: PopupMenuButton<String>(
                                  onSelected: (v) {
                                    if (v == 'edit') _showForm(existing: s);
                                    if (v == 'delete') _deactivate(s);
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
