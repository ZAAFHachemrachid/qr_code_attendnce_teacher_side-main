import 'package:flutter/foundation.dart';
import '../../teacher/models/course.dart' show ClassInfo, CourseGroup;
import '../../teacher/models/class_type.dart';
import 'session_attendance.dart';

@immutable
class DummyCourse extends ClassInfo {
  final bool isDummy;
  final String studentId;
  final List<SessionAttendance> courseAttendance;
  final List<SessionAttendance> tdAttendance;
  final List<SessionAttendance> tpAttendance;

  static const List<Map<String, dynamic>> _dummyCourseData = [
    {
      'code': 'CS101',
      'title': 'Programming 101',
      'description': 'Introduction to programming concepts and problem solving',
      'credits': 3,
      'schedule': 'Mon/Wed 09:30-11:00',
      'professor': 'Dr. Sarah Thompson',
      'room': 'B201'
    },
    {
      'code': 'MATH201',
      'title': 'Mathematics',
      'description': 'Advanced mathematical concepts and applications',
      'credits': 4,
      'schedule': 'Tue/Thu 11:00-12:30',
      'professor': 'Dr. Michael Chen',
      'room': 'A102'
    },
    {
      'code': 'PHY102',
      'title': 'Physics',
      'description': 'Fundamental principles of physics and their applications',
      'credits': 4,
      'schedule': 'Mon/Wed 13:00-14:30',
      'professor': 'Dr. James Wilson',
      'room': 'C305'
    },
    {
      'code': 'ENG205',
      'title': 'English Literature',
      'description': 'Study of classic and contemporary literature',
      'credits': 3,
      'schedule': 'Tue/Thu 09:00-10:30',
      'professor': 'Prof. Emily Martinez',
      'room': 'D401'
    },
    {
      'code': 'CS202',
      'title': 'Data Structures',
      'description': 'Advanced data structures and algorithms',
      'credits': 4,
      'schedule': 'Wed/Fri 14:00-15:30',
      'professor': 'Dr. Robert Lee',
      'room': 'B205'
    }
  ];

  DummyCourse({
    required super.id,
    required this.studentId,
    required int academicYear,
    required super.semester,
    required Map<String, dynamic> courseData,
  })  : isDummy = true,
        courseAttendance = _generateCourseAttendance(courseData['room']),
        tdAttendance = _generateTDAttendance(courseData['room']),
        tpAttendance = _generateTPAttendance(courseData['room']),
        super(
          code: courseData['code'],
          title: courseData['title'],
          description: courseData['description'],
          creditHours: courseData['credits'],
          yearOfStudy: academicYear,
          groups: [DummyGroup(professor: courseData['professor'])],
          schedule: courseData['schedule'],
          type: ClassType.course,
        );

  static List<SessionAttendance> _generateCourseAttendance(String room) {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month - 2, 1);
    final sessions = <SessionAttendance>[];

    for (int i = 0; i < 8; i++) {
      final sessionDate = startDate.add(Duration(days: i * 7));
      sessions.add(
        SessionAttendance(
          id: 'course-$i',
          date: sessionDate,
          roomNumber: room,
          topic: 'Week ${i + 1} Lecture',
          isPresent: i < 6, // Missed last two sessions
          type: SessionType.course,
        ),
      );
    }
    return sessions;
  }

  static List<SessionAttendance> _generateTDAttendance(String room) {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month - 2, 2);
    final sessions = <SessionAttendance>[];

    for (int i = 0; i < 6; i++) {
      final sessionDate = startDate.add(Duration(days: i * 7));
      sessions.add(
        SessionAttendance(
          id: 'td-$i',
          date: sessionDate,
          roomNumber: '${room}A',
          topic: 'TD Session ${i + 1}',
          isPresent: i != 2, // Missed one session
          type: SessionType.td,
        ),
      );
    }
    return sessions;
  }

  static List<SessionAttendance> _generateTPAttendance(String room) {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month - 2, 3);
    final sessions = <SessionAttendance>[];

    for (int i = 0; i < 5; i++) {
      final sessionDate =
          startDate.add(Duration(days: i * 14)); // Every two weeks
      sessions.add(
        SessionAttendance(
          id: 'tp-$i',
          date: sessionDate,
          roomNumber: '${room}B',
          topic: 'Lab Session ${i + 1}',
          isPresent: i != 1 && i != 3, // Missed two sessions
          type: SessionType.tp,
        ),
      );
    }
    return sessions;
  }

  int getAttendanceCount(SessionType type) {
    switch (type) {
      case SessionType.course:
        return courseAttendance.where((session) => session.isPresent).length;
      case SessionType.td:
        return tdAttendance.where((session) => session.isPresent).length;
      case SessionType.tp:
        return tpAttendance.where((session) => session.isPresent).length;
    }
  }

  int getTotalSessions(SessionType type) {
    switch (type) {
      case SessionType.course:
        return courseAttendance.length;
      case SessionType.td:
        return tdAttendance.length;
      case SessionType.tp:
        return tpAttendance.length;
    }
  }

  double getAttendancePercentage(SessionType type) {
    final attended = getAttendanceCount(type);
    final total = getTotalSessions(type);
    return total > 0 ? (attended / total) * 100 : 0;
  }

  factory DummyCourse.create({
    required String studentId,
    required int academicYear,
    required String semester,
    int? index,
  }) {
    final courseIndex =
        index ?? DateTime.now().microsecond % _dummyCourseData.length;
    final courseData = _dummyCourseData[courseIndex];

    return DummyCourse(
      id: 'dummy-${courseData['code']}-$studentId-$semester',
      studentId: studentId,
      academicYear: academicYear,
      semester: semester,
      courseData: courseData,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DummyCourse &&
        other.isDummy == isDummy &&
        other.studentId == studentId &&
        other.id == id;
  }

  @override
  int get hashCode => Object.hash(isDummy, studentId, id);
}

class DummyGroup extends CourseGroup {
  final String professor;

  DummyGroup({required this.professor})
      : super(
          id: 'dummy-group',
          name: 'Example Group',
          academicYear: DateTime.now().year,
          currentYear: DateTime.now().year,
          section: 'A',
          studentCount: 25,
        );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DummyGroup && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
