import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/student_model.dart';
import '../../../shared/services/homework_repository.dart';

import '../../admin/widgets/admin_feedback.dart';

class ParentHomeworkScreen extends StatefulWidget {
  const ParentHomeworkScreen({super.key, required this.student});

  final StudentModel student;

  @override
  State<ParentHomeworkScreen> createState() => _ParentHomeworkScreenState();
}

class _ParentHomeworkScreenState extends State<ParentHomeworkScreen> {
  List<Map<String, dynamic>> _homeworks = [];
  final Map<int, Map<String, dynamic>> _stickers = {};
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
      final data = await _repo.listForStudent(widget.student.id);
      final stickers = <int, Map<String, dynamic>>{};
      for (final h in data) {
        if (h['status'] == 'graded') {
          try {
            stickers[h['id'] as int] =
                await _repo.stickerForHomework(h['id'] as int);
          } catch (_) {}
        }
      }
      if (!mounted) return;
      setState(() {
        _homeworks = data;
        _stickers
          ..clear()
          ..addAll(stickers);
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

  Future<void> _confirm(int id) async {
    try {
      await _repo.confirm(id);
      await _load();
      if (mounted) showAdminSuccess(context, 'تم تأكيد حل الواجب');
    } catch (e) {
      if (mounted) showAdminError(context, e);
    }
  }

  Map<String, dynamic>? _firstSubmission(Map<String, dynamic> homework) {
    final submissions = homework['submissions'] as List<dynamic>?;
    if (submissions == null || submissions.isEmpty) return null;
    return submissions.first as Map<String, dynamic>;
  }

  List<Widget> _statusActions(Map<String, dynamic> homework) {
    final status = homework['status'] as String?;
    final id = homework['id'] as int;
    final submission = _firstSubmission(homework);

    if (status == 'assigned') {
      return [
        ElevatedButton(
          onPressed: () => _confirm(id),
          child: const Text('تم الحل ✓'),
        ),
      ];
    }
    if (status == 'graded' && submission != null) {
      final stickerRecord = _stickers[id];
      final sticker = stickerRecord?['sticker'] as Map<String, dynamic>?;
      return [
        Chip(
          label: Text('الدرجة: ${submission['teacherGrade'] ?? '—'}'),
          backgroundColor: AppColors.softSky,
        ),
        if (submission['teacherNote'] != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'ملاحظة المعلمة: ${submission['teacherNote']}',
              style: const TextStyle(fontSize: 13),
            ),
          ),
        if (sticker != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                const Icon(Icons.emoji_events, color: AppColors.warmOrange, size: 20),
                const SizedBox(width: 6),
                Text(
                  'ملصق: ${sticker['name']}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
      ];
    }
    return const [
      Chip(label: Text('بانتظار تصحيح المعلمة')),
    ];
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
    if (_homeworks.isEmpty) {
      return const Center(child: Text('لا توجد واجبات'));
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _homeworks.length,
        itemBuilder: (_, i) {
          final h = _homeworks[i];
          return Card(
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    h['title']?.toString() ?? '',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(h['description']?.toString() ?? ''),
                  const SizedBox(height: 8),
                  ..._statusActions(h),
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
        appBar: AppBar(title: Text('واجبات ${widget.student.name}')),
        body: _buildBody(),
      ),
    );
  }
}
