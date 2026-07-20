import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/labeled_dropdown.dart';
import '../../../shared/models/student_model.dart';
import '../../../shared/services/students_repository.dart';

class TeacherAttendanceScreen extends StatefulWidget {
  const TeacherAttendanceScreen({super.key, this.initialStudent});

  final StudentModel? initialStudent;

  @override
  State<TeacherAttendanceScreen> createState() =>
      _TeacherAttendanceScreenState();
}

class _TeacherAttendanceScreenState extends State<TeacherAttendanceScreen> {
  List<StudentModel> _students = [];
  StudentModel? _selected;
  String _type = 'check_in';
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = StudentsRepository(context.read<AuthProvider>().api);
    try {
      final students = await repo.myClass();
      setState(() {
        _students = students;
        _selected = widget.initialStudent ??
            (students.isNotEmpty ? students.first : null);
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _submit() async {
    if (_selected == null) return;
    setState(() => _saving = true);
    final today = DateTime.now().toIso8601String().split('T').first;
    try {
      await context.read<AuthProvider>().api.post('/attendance', body: {
        'studentId': _selected!.id,
        'type': _type,
        'date': today,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تسجيل الحضور وإرسال إشعار لولي الأمر'),
            backgroundColor: AppColors.linkGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.coralRed),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('تسجيل حضور')),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    LabeledDropdown<StudentModel>(
                      label: 'الطالب',
                      value: _selected,
                      items: _students
                          .map((s) => DropdownMenuItem(
                                value: s,
                                child: Text(s.name),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _selected = v),
                    ),
                    const SizedBox(height: 16),
                    LabeledDropdown<String>(
                      label: 'النوع',
                      value: _type,
                      items: const [
                        DropdownMenuItem(value: 'check_in', child: Text('حضور')),
                        DropdownMenuItem(value: 'check_out', child: Text('انصراف')),
                        DropdownMenuItem(value: 'absent', child: Text('غياب')),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _type = v);
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _saving ? null : _submit,
                      child: _saving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('تسجيل'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
