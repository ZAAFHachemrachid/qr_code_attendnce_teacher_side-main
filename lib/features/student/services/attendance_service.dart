import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/attendance_history.dart';

class AttendanceService {
  Future<AttendanceHistory> getAttendanceHistory(
    String studentId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // TODO: Implement actual API call
    // This is dummy data for now
    await Future.delayed(const Duration(seconds: 1));

    List<AttendanceRecord> records = [
      AttendanceRecord(
        courseId: 'CS101',
        courseName: 'Introduction to Programming',
        date: DateTime.now().subtract(const Duration(days: 1)),
        status: 'present',
        courseType: 'TD',
      ),
      AttendanceRecord(
        courseId: 'CS102',
        courseName: 'Data Structures',
        date: DateTime.now().subtract(const Duration(days: 2)),
        status: 'absent',
        courseType: 'TP',
        notes: 'Medical leave',
      ),
      AttendanceRecord(
        courseId: 'CS101',
        courseName: 'Introduction to Programming',
        date: DateTime.now().subtract(const Duration(days: 3)),
        status: 'present',
        courseType: 'TD',
      ),
      AttendanceRecord(
        courseId: 'CS103',
        courseName: 'Database Systems',
        date: DateTime.now().subtract(const Duration(days: 4)),
        status: 'late',
        courseType: 'TP',
      ),
      AttendanceRecord(
        courseId: 'CS102',
        courseName: 'Data Structures',
        date: DateTime.now().subtract(const Duration(days: 5)),
        status: 'present',
        courseType: 'TD',
      ),
    ];

    // Filter records by date range if provided
    if (startDate != null) {
      records = records
          .where((record) =>
              record.date.isAtSameMomentAs(startDate) ||
              record.date.isAfter(startDate))
          .toList();
    }
    if (endDate != null) {
      records = records
          .where((record) =>
              record.date.isAtSameMomentAs(endDate) ||
              record.date.isBefore(endDate.add(const Duration(days: 1))))
          .toList();
    }

    // Sort records by date
    records.sort((a, b) => b.date.compareTo(a.date));

    final recordsByClass = <String, List<AttendanceRecord>>{};
    for (final record in records) {
      if (!recordsByClass.containsKey(record.courseId)) {
        recordsByClass[record.courseId] = [];
      }
      recordsByClass[record.courseId]!.add(record);
    }

    final stats = AttendanceStats(
      totalClasses: records.length,
      presentCount: records.where((r) => r.status == 'present').length,
      absentCount: records.where((r) => r.status == 'absent').length,
      lateCount: records.where((r) => r.status == 'late').length,
    );

    return AttendanceHistory(
      records: records,
      stats: stats,
      recordsByClass: recordsByClass,
    );
  }
  /// Validates if the session is valid for attendance (stub).
  Future<bool> validateSession(String sessionId) async {
    // TODO: Implement actual session validation logic (API call)
    await Future.delayed(const Duration(milliseconds: 500));
    // For demonstration, treat any non-empty sessionId as valid except "INVALID"
    return sessionId.isNotEmpty && sessionId != "INVALID";
  }

  /// Adds the student's attendance for the session (stub).
  Future<void> addAttendance(String sessionId, String studentId) async {
    // TODO: Implement actual attendance marking logic (API call)
    await Future.delayed(const Duration(milliseconds: 500));
    // No-op for stub
  }
}

final attendanceServiceProvider = Provider<AttendanceService>((ref) {
  return AttendanceService();
});

/// Provider that fetches attendance history with optional date range filtering
final attendanceHistoryProvider =
    FutureProvider.family<AttendanceHistory, (String, DateTime?, DateTime?)>(
        (ref, params) async {
  final service = ref.read(attendanceServiceProvider);
  return service.getAttendanceHistory(params.$1,
      startDate: params.$2, endDate: params.$3);
});
