import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/student_model.dart';
import '../../../shared/services/homework_repository.dart';

import '../../admin/widgets/admin_feedback.dart';

class ParentStickersScreen extends StatefulWidget {
  const ParentStickersScreen({super.key, required this.student});

  final StudentModel student;

  @override
  State<ParentStickersScreen> createState() => _ParentStickersScreenState();
}

class _ParentStickersScreenState extends State<ParentStickersScreen> {
  List<Map<String, dynamic>> _stickers = [];
  bool _loading = true;
  String? _error;

  HomeworkRepository get _repo =>
      HomeworkRepository(context.read<AuthProvider>().api);

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
      final data = await _repo.studentStickers(widget.student.id);
      if (!mounted) return;
      setState(() {
        _stickers = data;
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

  Color _parseColor(String? hex) {
    if (hex == null || !hex.startsWith('#') || hex.length < 7) {
      return AppColors.kiddyBlue;
    }
    return Color(int.parse(hex.substring(1), radix: 16) + 0xFF000000);
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
    if (_stickers.isEmpty) {
      return const Center(child: Text('لم يحصل على ملصقات بعد'));
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: _stickers.length,
        itemBuilder: (_, i) {
          final record = _stickers[i];
          final sticker = record['sticker'] as Map<String, dynamic>? ?? {};
          final level = sticker['level'] as Map<String, dynamic>? ?? {};
          final homework = record['homework'] as Map<String, dynamic>?;
          final color = _parseColor(level['color'] as String?);
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: color.withValues(alpha: 0.2),
                    child: Icon(Icons.emoji_events, color: color),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    sticker['name']?.toString() ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    level['name']?.toString() ?? '',
                    style: TextStyle(color: color, fontSize: 12),
                  ),
                  if (homework != null)
                    Text(
                      homework['title']?.toString() ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  if (record['note'] != null)
                    Text(
                      record['note'].toString(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
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
        appBar: AppBar(title: Text('ملصقات ${widget.student.name}')),
        body: _buildBody(),
      ),
    );
  }
}
