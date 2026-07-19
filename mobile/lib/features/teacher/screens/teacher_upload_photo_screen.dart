import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/student_model.dart';
import '../../../shared/services/students_repository.dart';
import '../../../shared/utils/image_mime_utils.dart';
import '../../admin/widgets/admin_feedback.dart';

class TeacherUploadPhotoScreen extends StatefulWidget {
  const TeacherUploadPhotoScreen({super.key});

  @override
  State<TeacherUploadPhotoScreen> createState() =>
      _TeacherUploadPhotoScreenState();
}

class _TeacherUploadPhotoScreenState extends State<TeacherUploadPhotoScreen> {
  List<StudentModel> _students = [];
  StudentModel? _selected;
  bool _loading = true;
  bool _uploading = false;
  String? _error;
  final _captionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final api = context.read<AuthProvider>().api;
    try {
      final students = await StudentsRepository(api).myClass();
      setState(() {
        _students = students;
        _selected = students.isNotEmpty ? students.first : null;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = formatAdminError(e);
      });
    }
  }

  Future<void> _pickAndUpload() async {
    if (_selected == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا يوجد طلاب مرتبطين بك'),
          backgroundColor: AppColors.coralRed,
        ),
      );
      return;
    }

    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null) return;

    setState(() => _uploading = true);
    try {
      final bytes = await file.readAsBytes();
      final mime = resolveImageMime(file.name, file.mimeType);
      final filename = ensureImageFilename(file.name, mime);
      await context.read<AuthProvider>().api.uploadMultipart(
            '/photos',
            fileField: 'image',
            bytes: bytes,
            filename: filename,
            contentType: mime,
            fields: {
              'studentId': _selected!.id.toString(),
              if (_captionController.text.isNotEmpty)
                'caption': _captionController.text,
            },
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم رفع الصورة — بانتظار موافقة المديرة'),
            backgroundColor: AppColors.linkGreen,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(formatAdminError(e)),
            backgroundColor: AppColors.coralRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('رفع صورة')),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
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
                  )
                : _students.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            'لا يوجد طلاب مرتبطين بك.\nاطلبي من المديرة ربط طلاب بحسابك.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            DropdownButtonFormField<StudentModel>(
                              value: _selected,
                              decoration:
                                  const InputDecoration(labelText: 'الطالب'),
                              items: _students
                                  .map((s) => DropdownMenuItem(
                                        value: s,
                                        child: Text('${s.name} — ${s.className}'),
                                      ))
                                  .toList(),
                              onChanged: (v) => setState(() => _selected = v),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _captionController,
                              decoration: const InputDecoration(
                                labelText: 'وصف (اختياري)',
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: _uploading ? null : _pickAndUpload,
                              icon: _uploading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.upload),
                              label: const Text('اختيار صورة ورفع'),
                            ),
                          ],
                        ),
                      ),
      ),
    );
  }
}
