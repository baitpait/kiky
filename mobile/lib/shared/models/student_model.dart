class StudentModel {
  StudentModel({
    required this.id,
    required this.name,
    required this.className,
    this.avatarUrl,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'] as int,
      name: json['name'] as String,
      className: json['className'] as String? ?? json['class_name'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String? ?? json['avatar_url'] as String?,
    );
  }

  final int id;
  final String name;
  final String className;
  final String? avatarUrl;
}
