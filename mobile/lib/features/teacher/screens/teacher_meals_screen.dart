import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/student_model.dart';
import '../../../shared/services/students_repository.dart';

class TeacherMealsScreen extends StatefulWidget {
  const TeacherMealsScreen({super.key});

  @override
  State<TeacherMealsScreen> createState() => _TeacherMealsScreenState();
}

class _TeacherMealsScreenState extends State<TeacherMealsScreen> {
  List<StudentModel> _students = [];
  StudentModel? _selected;
  String _mealType = 'lunch';
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
        _selected = students.isNotEmpty ? students.first : null;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _confirm() async {
    if (_selected == null) return;
    setState(() => _saving = true);
    final today = DateTime.now().toIso8601String().split('T').first;
    try {
      await context.read<AuthProvider>().api.post('/meals/teacher-confirm', body: {
        'studentId': _selected!.id,
        'date': today,
        'mealType': _mealType,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تأكيد الوجبة'),
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
        appBar: AppBar(title: const Text('تأكيد وجبات')),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    DropdownButtonFormField<StudentModel>(
                      value: _selected,
                      decoration: const InputDecoration(labelText: 'الطالب'),
                      items: _students
                          .map((s) => DropdownMenuItem(
                                value: s,
                                child: Text(s.name),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _selected = v),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _mealType,
                      decoration: const InputDecoration(labelText: 'الوجبة'),
                      items: const [
                        DropdownMenuItem(value: 'breakfast', child: Text('فطور')),
                        DropdownMenuItem(value: 'lunch', child: Text('غداء')),
                        DropdownMenuItem(value: 'snack', child: Text('وجبة خفيفة')),
                      ],
                      onChanged: (v) => setState(() => _mealType = v!),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _saving ? null : _confirm,
                      child: _saving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('تأكيد تناول الوجبة'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
