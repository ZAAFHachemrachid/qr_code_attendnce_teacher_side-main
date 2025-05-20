import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/session_attendance.dart';
import '../../teacher/services/teacher_student_service.dart';

final courseAttendanceProvider =
    FutureProvider.family<List<SessionAttendance>, String>(
        (ref, courseId) async {
  final service = ref.watch(teacherStudentServiceProvider);
  try {
    // Here we'll integrate with the real API once it's available
    // For now returning placeholder data
    return [
      SessionAttendance(
        id: '1',
        date: DateTime.now().subtract(const Duration(days: 7)),
        roomNumber: 'A101',
        topic: 'Introduction',
        isPresent: true,
        type: SessionType.course,
      ),
      SessionAttendance(
        id: '2',
        date: DateTime.now().subtract(const Duration(days: 14)),
        roomNumber: 'A101',
        topic: 'Basic Concepts',
        isPresent: false,
        type: SessionType.course,
      ),
    ];
  } catch (e) {
    return [];
  }
});

final courseAttendanceStatsProvider =
    Provider.family<Map<SessionType, AttendanceStats>, String>((ref, courseId) {
  final attendanceAsync = ref.watch(courseAttendanceProvider(courseId));

  return attendanceAsync.when(
    data: (sessions) {
      final stats = <SessionType, AttendanceStats>{};

      for (final type in SessionType.values) {
        final typeSessions = sessions.where((s) => s.type == type).toList();
        final attended = typeSessions.where((s) => s.isPresent).length;

        stats[type] = AttendanceStats(
          attended: attended,
          total: typeSessions.length,
          percentage:
              typeSessions.isEmpty ? 0 : (attended / typeSessions.length * 100),
        );
      }

      return stats;
    },
    error: (_, __) => {
      for (var type in SessionType.values)
        type: const AttendanceStats(attended: 0, total: 0, percentage: 0)
    },
    loading: () => {
      for (var type in SessionType.values)
        type: const AttendanceStats(attended: 0, total: 0, percentage: 0)
    },
  );
});

class AttendanceStats {
  final int attended;
  final int total;
  final double percentage;

  const AttendanceStats({
    required this.attended,
    required this.total,
    required this.percentage,
  });
}
