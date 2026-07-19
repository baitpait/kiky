import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';
import '../../../shared/models/student_model.dart';

class StudentsRepository {
  StudentsRepository(this._api);
  final ApiClient _api;

  Future<List<StudentModel>> myClass() async {
    final data = await _api.get('/students/my-class');
    return asJsonList(data).map(StudentModel.fromJson).toList();
  }

  Future<List<StudentModel>> myChildren() async {
    final data = await _api.get('/students/my-children');
    return asJsonList(data).map(StudentModel.fromJson).toList();
  }
}
