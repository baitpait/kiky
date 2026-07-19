import '../../core/api/api_client.dart';

class HomeworkRepository {
  HomeworkRepository(this._api);
  final ApiClient _api;

  Future<List<Map<String, dynamic>>> listForTeacher() async {
    return asJsonList(await _api.get('/homeworks/my-students'));
  }

  Future<List<Map<String, dynamic>>> listForStudent(int studentId) async {
    return asJsonList(await _api.get('/homeworks/student/$studentId'));
  }

  Future<void> create({
    required int studentId,
    required String title,
    required String description,
    String? dueDate,
  }) async {
    await _api.post('/homeworks', body: {
      'studentId': studentId,
      'title': title,
      'description': description,
      if (dueDate != null && dueDate.isNotEmpty) 'dueDate': dueDate,
    });
  }

  Future<void> confirm(int homeworkId) async {
    await _api.put('/homeworks/$homeworkId/confirm');
  }

  Future<Map<String, dynamic>> grade({
    required int homeworkId,
    required String teacherGrade,
    String? teacherNote,
  }) async {
    final result = await _api.put(
      '/homeworks/$homeworkId/grade',
      body: {
        'teacherGrade': teacherGrade,
        if (teacherNote != null && teacherNote.isNotEmpty)
          'teacherNote': teacherNote,
      },
    );
    if (result is Map<String, dynamic>) return result;
    return {};
  }

  Future<Map<String, dynamic>> stickerForHomework(int homeworkId) async {
    final result = await _api.get('/homeworks/$homeworkId/sticker');
    if (result is Map<String, dynamic>) return result;
    return {};
  }

  Future<List<Map<String, dynamic>>> studentStickers(int studentId) async {
    return asJsonList(await _api.get('/students/$studentId/stickers'));
  }

  Future<List<Map<String, dynamic>>> activeStickers() async {
    return asJsonList(await _api.get('/stickers/active'));
  }

  Future<void> updateStudentSticker(
    int recordId, {
    int? stickerId,
    String? note,
  }) async {
    await _api.put('/student-stickers/$recordId', body: {
      if (stickerId != null) 'stickerId': stickerId,
      if (note != null) 'note': note,
    });
  }

  Future<void> removeStudentSticker(int recordId) async {
    await _api.delete('/student-stickers/$recordId');
  }
}
