enum ClassType { course, td, tp }

class ClassInfo {
  final String id;
  final String code;
  final String title;
  final String description;
  final int creditHours;
  final int yearOfStudy;
  final String semester;
  final List<CourseGroup> groups;
  final String schedule;
  final ClassType type;

  int get students => groups.fold(0, (sum, group) => sum + group.studentCount);

  const ClassInfo({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.creditHours,
    required this.yearOfStudy,
    required this.semester,
    required this.groups,
    required this.schedule,
    required this.type,
  });

  factory ClassInfo.fromJson(Map<String, dynamic> json) {
    return ClassInfo(
      id: json['id'] as String,
      code: json['code'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      creditHours: json['credit_hours'] as int,
      yearOfStudy: json['year_of_study'] as int,
      semester: json['semester'] as String,
      groups: (json['groups'] as List<dynamic>)
          .map((group) => CourseGroup.fromJson(group as Map<String, dynamic>))
          .toList(),
      schedule: json['schedule'] as String,
      type: ClassType.values.firstWhere(
        (t) => t.name == (json['type'] as String? ?? 'course'),
        orElse: () => ClassType.course,
      ),
    );
  }
}

class CourseGroup {
  final String id;
  final String name;
  final int academicYear;
  final int currentYear;
  final String section;
  final int studentCount;

  const CourseGroup({
    required this.id,
    required this.name,
    required this.academicYear,
    required this.currentYear,
    required this.section,
    required this.studentCount,
  });

  factory CourseGroup.fromJson(Map<String, dynamic> json) {
    return CourseGroup(
      id: json['id'] as String,
      name: json['name'] as String,
      academicYear: json['academic_year'] as int,
      currentYear: json['current_year'] as int,
      section: json['section'] as String,
      studentCount: json['student_count'] as int,
    );
  }
}
