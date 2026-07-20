import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/api/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/json_utils.dart';
import '../../../shared/utils/media_url_utils.dart';
import '../widgets/admin_feedback.dart';
import '../widgets/safe_admin_feedback.dart';

class AdminPendingPhotosScreen extends StatefulWidget {
  const AdminPendingPhotosScreen({super.key});

  @override
  State<AdminPendingPhotosScreen> createState() =>
      _AdminPendingPhotosScreenState();
}

class _AdminPendingPhotosScreenState extends State<AdminPendingPhotosScreen> {
  List<Map<String, dynamic>> _photos = [];
  bool _loading = true;
  String? _error;

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
      final data =
          await context.read<AuthProvider>().api.get('/admin/photos/pending');
      setState(() {
        _photos = asJsonList(data);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = formatAdminError(e);
        _loading = false;
      });
    }
  }

  Future<void> _approve(int id) async {
    try {
      await context.read<AuthProvider>().api.put('/admin/photos/$id/approve');
      await _load();
      if (mounted) {
        adminSuccess('تمت الموافقة — أُرسل إشعار لأولياء الأمور');
      }
    } catch (e) {
      if (mounted) adminError(e);
    }
  }

  Future<void> _reject(int id) async {
    final noteCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('رفض صورة'),
          content: TextField(
            controller: noteCtrl,
            decoration: const InputDecoration(
              labelText: 'سبب الرفض (اختياري)',
            ),
            maxLines: 2,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.coralRed),
              child: const Text('رفض'),
            ),
          ],
        ),
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await context.read<AuthProvider>().api.put(
        '/admin/photos/$id/reject',
        body: noteCtrl.text.trim().isEmpty ? {} : {'note': noteCtrl.text.trim()},
      );
      await _load();
      if (mounted) adminSuccess('تم رفض الصورة');
    } catch (e) {
      if (mounted) adminError(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('موافقة الصور')),
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
                  : _photos.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 120),
                            Center(child: Text('لا توجد صور بانتظار الموافقة')),
                          ],
                        )
                      : ListView.builder(
                          itemCount: _photos.length,
                          itemBuilder: (_, i) {
                            final p = _photos[i];
                            final student =
                                p['student'] as Map<String, dynamic>?;
                            final url = resolveMediaUrl(
                              p['imageUrl']?.toString() ??
                                  p['image_url']?.toString(),
                            );
                            return Card(
                              margin: const EdgeInsets.all(8),
                              child: Column(
                                children: [
                                  if (url.isNotEmpty)
                                    Image.network(
                                      url,
                                      height: 180,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const SizedBox(
                                        height: 120,
                                        child: Center(child: Icon(Icons.broken_image)),
                                      ),
                                    ),
                                  ListTile(
                                    title: Text(
                                      student?['name']?.toString() ?? 'طالب',
                                    ),
                                    subtitle: Text(p['caption']?.toString() ?? ''),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      TextButton.icon(
                                        onPressed: () =>
                                            _approve(asInt(p['id'])),
                                        icon: const Icon(
                                          Icons.check,
                                          color: AppColors.linkGreen,
                                        ),
                                        label: const Text('موافقة'),
                                      ),
                                      TextButton.icon(
                                        onPressed: () =>
                                            _reject(asInt(p['id'])),
                                        icon: const Icon(
                                          Icons.close,
                                          color: AppColors.coralRed,
                                        ),
                                        label: const Text('رفض'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
        ),
      ),
    );
  }
}
