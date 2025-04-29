class TeacherProfile {
  final String id;
  final String firstName;
  final String lastName;
  final String employeeId;
  final String? phone;
  final String? departmentId;
  final String? departmentName;
  final String? departmentCode;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TeacherProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.employeeId,
    required this.createdAt,
    required this.updatedAt,
    this.departmentId,
    this.departmentName,
    this.departmentCode,
    this.phone,
  });

  factory TeacherProfile.fromJson(Map<String, dynamic> json) {
    print('[TeacherProfile] Parsing JSON: $json');

    if (json['profiles'] == null) {
      throw Exception('Profile data is null in response');
    }

    final profileData = json['profiles'] as Map<String, dynamic>;
    final departmentData = json['departments'] as Map<String, dynamic>?;

    print('[TeacherProfile] Profile data: $profileData');
    print('[TeacherProfile] Department data: $departmentData');

    return TeacherProfile(
      id: json['id'] as String,
      firstName: profileData['first_name'] as String,
      lastName: profileData['last_name'] as String,
      employeeId: json['employee_id'] as String,
      phone: profileData['phone'] as String?,
      departmentId: json['department_id'] as String?,
      departmentName: departmentData?['name'] as String?,
      departmentCode: departmentData?['code'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
