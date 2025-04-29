class ClassInfo {
  final String id;
  final String name;
  final int students;
  final String schedule;

  const ClassInfo({
    required this.id,
    required this.name,
    required this.students,
    required this.schedule,
  });
}

class StudentInfo {
  final String id;
  final String name;
  final String email;
  final String className;
  final double attendanceRate;
  final String? group;

  const StudentInfo({
    required this.id,
    required this.name,
    required this.email,
    required this.className,
    required this.attendanceRate,
    this.group,
  });
}

class AttendanceRecord {
  final String studentId;
  final String studentName;
  final String status;
  final String checkInTime;

  const AttendanceRecord({
    required this.studentId,
    required this.studentName,
    required this.status,
    required this.checkInTime,
  });
}
