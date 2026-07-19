import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/api/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/student_model.dart';
import '../../../shared/utils/media_url_utils.dart';
import '../../admin/widgets/admin_feedback.dart';

class ParentPhotosScreen extends StatefulWidget {
  const ParentPhotosScreen({super.key, required this.student});

  final StudentModel student;

  @override
  State<ParentPhotosScreen> createState() => _ParentPhotosScreenState();
}

class _ParentPhotosScreenState extends State<ParentPhotosScreen> {
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
      final data = await context.read<AuthProvider>().api.get(
            '/photos/student/${widget.student.id}',
          );
      if (!mounted) return;
      setState(() {
        _photos = asJsonList(data);
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

  void _openPhoto(Map<String, dynamic> photo) {
    final url = resolveMediaUrl(
      photo['imageUrl']?.toString() ?? photo['image_url']?.toString(),
    );
    if (url.isEmpty) return;

    showDialog<void>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (photo['caption'] != null)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(photo['caption'].toString()),
                ),
              InteractiveViewer(
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.broken_image, size: 64),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('إغلاق'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text('صور ${widget.student.name}')),
        body: RefreshIndicator(
          onRefresh: _load,
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              const Icon(Icons.error_outline,
                                  size: 48, color: AppColors.coralRed),
                              const SizedBox(height: 12),
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
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 120),
                            Center(child: Text('لا توجد صور منشورة بعد')),
                          ],
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(8),
                          physics: const AlwaysScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: _photos.length,
                          itemBuilder: (_, i) {
                            final p = _photos[i];
                            final url = resolveMediaUrl(
                              p['imageUrl']?.toString() ??
                                  p['image_url']?.toString(),
                            );
                            return GestureDetector(
                              onTap: () => _openPhoto(p),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: url.isEmpty
                                    ? Container(
                                        color: AppColors.softSky,
                                        child: const Icon(Icons.broken_image),
                                      )
                                    : Image.network(
                                        url,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(Icons.broken_image),
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
