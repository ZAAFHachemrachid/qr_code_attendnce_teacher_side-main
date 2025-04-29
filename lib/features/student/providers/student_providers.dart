import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/student_profile.dart';
import '../models/attendance_record.dart';
import '../models/timeline_entry.dart';
import '../services/student_service.dart';

final studentServiceProvider = Provider<StudentService>((ref) {
  return StudentService();
});

final studentProfileProvider = FutureProvider<StudentProfile>((ref) async {
  final studentService = ref.watch(studentServiceProvider);
  return await studentService.getStudentProfile();
});

final studentAttendanceProvider =
    FutureProvider<List<AttendanceRecord>>((ref) async {
  final studentService = ref.watch(studentServiceProvider);
  return await studentService.getAttendanceRecords();
});

final studentTimelineProvider =
    FutureProvider<List<TimelineEntry>>((ref) async {
  final studentService = ref.watch(studentServiceProvider);
  return await studentService.getWeeklySchedule();
});

final selectedDayProvider = StateProvider<String>((ref) {
  final now = DateTime.now();
  final days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  return days[now.weekday - 1]; // weekday is 1-7 where 1 is Monday
});

final dayTimelineProvider = Provider<List<TimelineEntry>>((ref) {
  final timelineAsync = ref.watch(studentTimelineProvider);
  final selectedDay = ref.watch(selectedDayProvider);

  return timelineAsync.when(
    data: (timeline) =>
        timeline.where((entry) => entry.dayOfWeek == selectedDay).toList()
          ..sort((a, b) => a.slotNumber.compareTo(b.slotNumber)),
    error: (_, __) => [],
    loading: () => [],
  );
});

final markAttendanceProvider =
    FutureProvider.family<void, ({String sessionId, String qrCode})>(
  (ref, params) async {
    final studentService = ref.watch(studentServiceProvider);
    await studentService.markAttendance(params.sessionId, params.qrCode);
    // Refresh attendance records after marking attendance
    ref.invalidate(studentAttendanceProvider);
  },
);

// Provider to filter and sort attendance records
final filteredAttendanceProvider = Provider<List<AttendanceRecord>>((ref) {
  final attendanceAsync = ref.watch(studentAttendanceProvider);

  return attendanceAsync.when(
    data: (records) {
      // Sort by date, most recent first
      final sortedRecords = List<AttendanceRecord>.from(records)
        ..sort((a, b) => b.sessionDate.compareTo(a.sessionDate));
      return sortedRecords;
    },
    error: (_, __) => [],
    loading: () => [],
  );
});

// Provider to get attendance statistics
final attendanceStatsProvider = Provider<
    ({
      int totalSessions,
      int present,
      int absent,
      int late,
      double attendanceRate
    })>((ref) {
  final attendanceAsync = ref.watch(studentAttendanceProvider);

  return attendanceAsync.when(
    data: (records) {
      final total = records.length;
      final present = records.where((r) => r.status == 'present').length;
      final absent = records.where((r) => r.status == 'absent').length;
      final late = records.where((r) => r.status == 'late').length;
      final rate = total > 0 ? (present + late) / total * 100 : 0.0;

      return (
        totalSessions: total,
        present: present,
        absent: absent,
        late: late,
        attendanceRate: rate,
      );
    },
    error: (_, __) => (
      totalSessions: 0,
      present: 0,
      absent: 0,
      late: 0,
      attendanceRate: 0.0,
    ),
    loading: () => (
      totalSessions: 0,
      present: 0,
      absent: 0,
      late: 0,
      attendanceRate: 0.0,
    ),
  );
});
