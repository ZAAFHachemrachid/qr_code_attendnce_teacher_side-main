import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/attendance_history.dart';

class AttendanceService {
  Future<AttendanceHistory> getAttendanceHistory(String studentId) async {
    // TODO: Implement actual API call
    // This is dummy data for now
    await Future.delayed(const Duration(seconds: 1));

    final records = [
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
      // Add more dummy records...
    ];

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
}

final attendanceServiceProvider = Provider<AttendanceService>((ref) {
  return AttendanceService();
});

final attendanceHistoryProvider =
    FutureProvider.family<AttendanceHistory, String>((ref, studentId) async {
  final service = ref.read(attendanceServiceProvider);
  return service.getAttendanceHistory(studentId);
});
