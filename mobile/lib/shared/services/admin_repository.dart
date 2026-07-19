import '../../core/api/api_client.dart';

/// Admin CRUD — all data from `/api/admin/*` (MySQL via NestJS).
class AdminRepository {
  AdminRepository(this._api);

  final ApiClient _api;

  // ─── Teachers ───

  Future<List<Map<String, dynamic>>> listTeachers() async {
    return asJsonList(await _api.get('/admin/teachers'));
  }

  Future<List<Map<String, dynamic>>> listTeacherOptions() async {
    return asJsonList(await _api.get('/admin/teachers/options'));
  }

  Future<Map<String, dynamic>> createTeacher({
    required String username,
    required String password,
    required String name,
    String? phone,
  }) async {
    return (await _api.post('/admin/teachers', body: {
      'username': username,
      'password': password,
      'name': name,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
    })) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateTeacher(
    int id, {
    String? username,
    String? password,
    String? name,
    String? phone,
  }) async {
    return (await _api.put('/admin/teachers/$id', body: {
      if (username != null) 'username': username,
      if (password != null && password.isNotEmpty) 'password': password,
      if (name != null) 'name': name,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
    })) as Map<String, dynamic>;
  }

  Future<void> deactivateTeacher(int id) async {
    await _api.delete('/admin/teachers/$id');
  }

  // ─── Parents ───

  Future<List<Map<String, dynamic>>> listParents() async {
    return asJsonList(await _api.get('/admin/parents'));
  }

  Future<List<Map<String, dynamic>>> listParentOptions() async {
    return asJsonList(await _api.get('/admin/parents/options'));
  }

  Future<Map<String, dynamic>> createParent({
    required String username,
    required String password,
    required String name,
    String? phone,
  }) async {
    return (await _api.post('/admin/parents', body: {
      'username': username,
      'password': password,
      'name': name,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
    })) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateParent(
    int id, {
    String? username,
    String? password,
    String? name,
    String? phone,
  }) async {
    return (await _api.put('/admin/parents/$id', body: {
      if (username != null) 'username': username,
      if (password != null && password.isNotEmpty) 'password': password,
      if (name != null) 'name': name,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
    })) as Map<String, dynamic>;
  }

  Future<void> deactivateParent(int id) async {
    await _api.delete('/admin/parents/$id');
  }

  // ─── Students ───

  Future<List<Map<String, dynamic>>> listStudents() async {
    return asJsonList(await _api.get('/admin/students'));
  }

  Future<Map<String, dynamic>> createStudent({
    required String name,
    required String className,
    String? birthDate,
  }) async {
    return (await _api.post('/admin/students', body: {
      'name': name,
      'className': className,
      if (birthDate != null && birthDate.isNotEmpty) 'birthDate': birthDate,
    })) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateStudent(
    int id, {
    String? name,
    String? className,
    String? birthDate,
  }) async {
    return (await _api.put('/admin/students/$id', body: {
      if (name != null) 'name': name,
      if (className != null) 'className': className,
      if (birthDate != null) 'birthDate': birthDate,
    })) as Map<String, dynamic>;
  }

  Future<void> deactivateStudent(int id) async {
    await _api.delete('/admin/students/$id');
  }

  Future<void> linkParent(int studentId, int parentId) async {
    await _api.post('/admin/students/$studentId/link-parent', body: {
      'parentId': parentId,
    });
  }

  Future<void> linkTeacher(int studentId, int teacherId) async {
    await _api.post('/admin/students/$studentId/link-teacher', body: {
      'teacherId': teacherId,
    });
  }

  Future<Map<String, dynamic>> getDashboardStats() async {
    return await _api.get('/admin/stats') as Map<String, dynamic>;
  }
}
