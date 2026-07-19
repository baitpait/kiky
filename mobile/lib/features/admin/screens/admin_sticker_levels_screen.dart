import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/json_utils.dart';
import '../../../shared/services/sticker_repository.dart';
import '../widgets/admin_feedback.dart';

/// DEVELOPER_SPEC §8.2 #9 — إدارة مستويات الملصقات
class AdminStickerLevelsScreen extends StatefulWidget {
  const AdminStickerLevelsScreen({super.key});

  @override
  State<AdminStickerLevelsScreen> createState() =>
      _AdminStickerLevelsScreenState();
}

class _AdminStickerLevelsScreenState extends State<AdminStickerLevelsScreen> {
  List<Map<String, dynamic>> _levels = [];
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
      setState(() {
        _levels = levels;
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
    final nameCtrl =
        TextEditingController(text: existing?['name']?.toString());
    final colorCtrl = TextEditingController(
      text: existing?['color']?.toString() ?? '#6BC04B',
    );
    final orderCtrl = TextEditingController(
      text: '${existing?['sortOrder'] ?? _levels.length + 1}',
    );

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(isEdit ? 'تعديل مستوى' : 'مستوى جديد'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'اسم المستوى'),
              ),
              TextField(
                controller: colorCtrl,
                decoration: const InputDecoration(labelText: 'اللون (#hex)'),
              ),
              TextField(
                controller: orderCtrl,
                decoration: const InputDecoration(labelText: 'الترتيب'),
                keyboardType: TextInputType.number,
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
    );
    if (ok != true || !mounted) return;
    if (nameCtrl.text.trim().isEmpty) {
      showAdminError(context, 'اسم المستوى مطلوب');
      return;
    }

    setState(() => _submitting = true);
    try {
      final name = nameCtrl.text.trim();
      final color = normalizeStickerColor(colorCtrl.text);
      final sortOrder = int.tryParse(orderCtrl.text) ?? 1;
      if (isEdit) {
        await _repo.updateLevel(
          asInt(existing['id']),
          name: name,
          color: color,
          sortOrder: sortOrder,
        );
        showAdminSuccess(context, 'تم تحديث المستوى');
      } else {
        await _repo.createLevel(
          name: name,
          color: color,
          sortOrder: sortOrder,
        );
        showAdminSuccess(context, 'تم إضافة المستوى');
      }
      await _load();
    } catch (e) {
      if (mounted) showAdminError(context, e);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _deactivate(Map<String, dynamic> level) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تعطيل مستوى'),
          content: Text('تعطيل "${level['name']}"؟'),
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
      await _repo.deactivateLevel(asInt(level['id']));
      showAdminSuccess(context, 'تم التعطيل');
      await _load();
    } catch (e) {
      if (mounted) showAdminError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('إدارة مستويات الملصقات')),
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
                  : _levels.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 120),
                            Center(
                              child: Text('لا توجد مستويات — أضف مستوى أولاً'),
                            ),
                          ],
                        )
                      : ListView.builder(
                          itemCount: _levels.length,
                          itemBuilder: (_, i) {
                            final l = _levels[i];
                            final colorHex = l['color']?.toString() ?? '#6BC04B';
                            Color chipColor;
                            try {
                              chipColor = Color(
                                int.parse(colorHex.replaceFirst('#', '0xFF')),
                              );
                            } catch (_) {
                              chipColor = AppColors.linkGreen;
                            }
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: chipColor.withValues(alpha: 0.25),
                                  child: Text('${l['sortOrder']}'),
                                ),
                                title: Text(l['name']?.toString() ?? ''),
                                subtitle: Text('اللون: $colorHex'),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (v) {
                                    if (v == 'edit') _showForm(existing: l);
                                    if (v == 'delete') _deactivate(l);
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
