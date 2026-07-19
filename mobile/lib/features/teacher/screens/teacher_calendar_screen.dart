import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/services/content_repository.dart';
import '../../admin/widgets/admin_feedback.dart';

/// DEVELOPER_SPEC §8.3 #11 — التقويم (قراءة فقط)
class TeacherCalendarScreen extends StatefulWidget {
  const TeacherCalendarScreen({super.key});

  @override
  State<TeacherCalendarScreen> createState() => _TeacherCalendarScreenState();
}

class _TeacherCalendarScreenState extends State<TeacherCalendarScreen> {
  List<Map<String, dynamic>> _events = [];
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
      final events =
          await ContentRepository(context.read<AuthProvider>().api)
              .publicCalendar();
      setState(() {
        _events = events;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = formatAdminError(e);
        _loading = false;
      });
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

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('التقويم السنوي')),
        body: RefreshIndicator(
          onRefresh: _load,
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? ListView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(_error!, textAlign: TextAlign.center),
                        ),
                      ],
                    )
                  : _events.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 120),
                            Center(child: Text('لا توجد أحداث في التقويم')),
                          ],
                        )
                      : ListView.builder(
                          itemCount: _events.length,
                          itemBuilder: (_, i) {
                            final e = _events[i];
                            final date =
                                e['startDate']?.toString().split('T').first ?? '';
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.event,
                                  color: AppColors.linkGreen,
                                ),
                                title: Text(e['title']?.toString() ?? ''),
                                subtitle: Text(
                                  '${_typeLabel(e['eventType']?.toString())} — $date',
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
