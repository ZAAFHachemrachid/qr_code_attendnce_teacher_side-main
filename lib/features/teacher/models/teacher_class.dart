import '../models/course.dart' show CourseGroup, ClassInfo, ClassType;

class TeacherClass {
  final String id;
  final String code;
  final String title;
  final String description;
  final int creditHours;
  final int yearOfStudy;
  final String semester;
  final String academicPeriod;
  final List<CourseGroup> groups;
  final String schedule;
  final ClassType type;

  // Get total student count
  int get students => groups.fold(0, (sum, group) => sum + group.studentCount);

  // Get flat list of all students across groups
  List<Map<String, dynamic>> getAllStudents() {
    print('[TeacherClass] Getting all students for class type: $type');
    final allStudents = groups
        .expand((group) => List.generate(group.studentCount,
            (i) => {'id': '$i', 'groupId': group.id, 'groupName': group.name}))
        .toList();
    print('[TeacherClass] Total students: ${allStudents.length}');
    print('[TeacherClass] Groups count: ${groups.length}');
    for (var group in groups) {
      print(
          '[TeacherClass] Group ${group.name} has ${group.studentCount} students');
    }
    return allStudents;
  }

  // Helper methods to check class type
  bool get isCourse => type == ClassType.course;
  bool get isTD => type == ClassType.td;
  bool get isTP => type == ClassType.tp;

  const TeacherClass({
    required this.id,
    required this.code,
    required this.title,
    required this.academicPeriod,
    required this.groups,
    required this.schedule,
    required this.type,
    this.description = '',
    this.creditHours = 3,
    this.yearOfStudy = 1,
    this.semester = 'current',
  });

  factory TeacherClass.fromJson(Map<String, dynamic> json) {
    final groups = (json['groups'] as List?)?.map((group) {
          final Map<String, dynamic> groupData = group as Map<String, dynamic>;
          return CourseGroup(
            id: groupData['id'] as String,
            name: groupData['name'] as String,
            academicYear:
                groupData['academic_year'] as int? ?? DateTime.now().year,
            currentYear: groupData['current_year'] as int? ?? 1,
            section: groupData['section'] as String? ?? 'A',
            studentCount: _extractStudentCount(groupData['student_count']),
          );
        }).toList() ??
        [];

    return TeacherClass(
      id: json['id'] as String,
      code: json['code'] as String,
      title: json['title'] as String,
      schedule: json['schedule'] as String? ?? '',
      academicPeriod:
          json['academic_period'] as String? ?? DateTime.now().year.toString(),
      description: json['description'] as String? ?? '',
      creditHours: json['credit_hours'] as int? ?? 3,
      yearOfStudy: json['year_of_study'] as int? ?? 1,
      semester: json['semester'] as String? ?? 'current',
      groups: groups,
      type: ClassType.values.firstWhere(
        (t) => t.name == (json['type'] as String? ?? 'course'),
        orElse: () => ClassType.course,
      ),
    );
  }

  factory TeacherClass.fromClassInfo(ClassInfo info) {
    return TeacherClass(
      id: info.id,
      code: info.code,
      title: info.title,
      description: info.description,
      creditHours: info.creditHours,
      yearOfStudy: info.yearOfStudy,
      semester: info.semester,
      academicPeriod: DateTime.now().year.toString(),
      groups: info.groups,
      schedule: info.schedule,
      type: info.type,
    );
  }

  static int _extractStudentCount(dynamic countData) {
    if (countData == null) return 0;

    if (countData is int) return countData;

    if (countData is List && countData.isNotEmpty) {
      final firstItem = countData[0];
      if (firstItem is Map && firstItem.containsKey('count')) {
        return firstItem['count'] as int? ?? 0;
      }
    }

    return 0;
  }

  ClassInfo toClassInfo() {
    return ClassInfo(
      id: id,
      code: code,
      title: title,
      description: description,
      creditHours: creditHours,
      yearOfStudy: yearOfStudy,
      semester: semester,
      groups: groups,
      schedule: schedule,
      type: type,
    );
  }
}
