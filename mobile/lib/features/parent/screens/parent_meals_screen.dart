import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/api/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/labeled_dropdown.dart';
import '../../../shared/models/student_model.dart';

class ParentMealsScreen extends StatefulWidget {
  const ParentMealsScreen({super.key, required this.student});

  final StudentModel student;

  @override
  State<ParentMealsScreen> createState() => _ParentMealsScreenState();
}

class _ParentMealsScreenState extends State<ParentMealsScreen> {
  List<Map<String, dynamic>> _records = [];
  bool _loading = true;
  String _mealType = 'lunch';
  bool _confirming = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await context.read<AuthProvider>().api.get(
            '/meals/student/${widget.student.id}',
          );
      setState(() {
        _records = asJsonList(data);
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _parentConfirm() async {
    setState(() => _confirming = true);
    final today = DateTime.now().toIso8601String().split('T').first;
    try {
      await context.read<AuthProvider>().api.post('/meals/parent-confirm', body: {
        'studentId': widget.student.id,
        'date': today,
        'mealType': _mealType,
      });
      await _load();
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
      if (mounted) setState(() => _confirming = false);
    }
  }

  String _mealLabel(String type) {
    switch (type) {
      case 'breakfast':
        return 'فطور';
      case 'lunch':
        return 'غداء';
      case 'snack':
        return 'وجبة خفيفة';
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text('وجبات ${widget.student.name}')),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        LabeledDropdown<String>(
                          label: 'تأكيد وجبة اليوم',
                          value: _mealType,
                          items: const [
                            DropdownMenuItem(
                                value: 'breakfast', child: Text('فطور')),
                            DropdownMenuItem(value: 'lunch', child: Text('غداء')),
                            DropdownMenuItem(
                                value: 'snack', child: Text('وجبة خفيفة')),
                          ],
                          onChanged: (v) => setState(() => _mealType = v!),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _confirming ? null : _parentConfirm,
                          child: _confirming
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('تأكيد تناول الوجبة في المنزل'),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _records.isEmpty
                        ? const Center(child: Text('لا يوجد سجل وجبات'))
                        : ListView.builder(
                            itemCount: _records.length,
                            itemBuilder: (_, i) {
                              final r = _records[i];
                              final date =
                                  (r['date'] as String?)?.split('T').first ?? '';
                              final teacher = r['teacherConfirmed'] == true;
                              final parent = r['parentConfirmed'] == true;
                              return ListTile(
                                title: Text(
                                    '${_mealLabel(r['mealType'] as String? ?? '')} — $date'),
                                subtitle: Text(
                                  'المعلمة: ${teacher ? '✓' : '—'} | ولي الأمر: ${parent ? '✓' : '—'}',
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}
