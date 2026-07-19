import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/api/api_client.dart';
import '../../../shared/models/student_model.dart';

class ParentAttendanceScreen extends StatefulWidget {
  const ParentAttendanceScreen({super.key, required this.student});

  final StudentModel student;

  @override
  State<ParentAttendanceScreen> createState() => _ParentAttendanceScreenState();
}

class _ParentAttendanceScreenState extends State<ParentAttendanceScreen> {
  List<Map<String, dynamic>> _records = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await context.read<AuthProvider>().api.get(
            '/attendance/student/${widget.student.id}',
          );
      setState(() {
        _records = asJsonList(data);
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'check_in':
        return 'حضور';
      case 'check_out':
        return 'انصراف';
      case 'absent':
        return 'غياب';
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text('حضور ${widget.student.name}')),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _records.isEmpty
                ? const Center(child: Text('لا يوجد سجل حضور'))
                : ListView.builder(
                    itemCount: _records.length,
                    itemBuilder: (_, i) {
                      final r = _records[i];
                      final date = (r['date'] as String?)?.split('T').first ?? '';
                      return ListTile(
                        leading: Icon(
                          r['type'] == 'absent'
                              ? Icons.cancel
                              : Icons.check_circle,
                        ),
                        title: Text(_typeLabel(r['type'] as String? ?? '')),
                        subtitle: Text(date),
                      );
                    },
                  ),
      ),
    );
  }
}
