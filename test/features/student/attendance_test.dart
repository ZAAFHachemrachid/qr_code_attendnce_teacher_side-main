import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../../../lib/features/student/models/attendance_history.dart';
import '../../../lib/features/student/services/attendance_service.dart';

void main() {
  late AttendanceService attendanceService;

  setUp(() {
    attendanceService = AttendanceService();
  });

  group('AttendanceService Tests', () {
    test('getAttendanceHistory returns correct data structure', () async {
      final history = await attendanceService.getAttendanceHistory('student1');

      expect(history, isA<AttendanceHistory>());
      expect(history.records, isA<List<AttendanceRecord>>());
      expect(history.stats, isA<AttendanceStats>());
      expect(
          history.recordsByClass, isA<Map<String, List<AttendanceRecord>>>());
    });

    test('date range filtering works correctly', () async {
      final now = DateTime.now();
      final startDate = now.subtract(const Duration(days: 3));
      final endDate = now.subtract(const Duration(days: 1));

      final history = await attendanceService.getAttendanceHistory(
        'student1',
        startDate: startDate,
        endDate: endDate,
      );

      for (final record in history.records) {
        expect(
          record.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
              record.date.isBefore(endDate.add(const Duration(days: 1))),
          isTrue,
          reason: 'Record date should be within the specified range',
        );
      }
    });

    test('records are sorted by date in descending order', () async {
      final history = await attendanceService.getAttendanceHistory('student1');

      for (int i = 0; i < history.records.length - 1; i++) {
        expect(
          history.records[i].date.isAfter(history.records[i + 1].date) ||
              history.records[i].date
                  .isAtSameMomentAs(history.records[i + 1].date),
          isTrue,
          reason: 'Records should be sorted by date in descending order',
        );
      }
    });

    test('handles same day start and end dates', () async {
      final sameDay = DateTime.now();

      final history = await attendanceService.getAttendanceHistory(
        'student1',
        startDate: sameDay,
        endDate: sameDay,
      );

      for (final record in history.records) {
        expect(
          record.date.year == sameDay.year &&
              record.date.month == sameDay.month &&
              record.date.day == sameDay.day,
          isTrue,
          reason: 'Should only include records from the specified day',
        );
      }
    });
  });

  group('AttendanceStats Tests', () {
    test('calculates percentages correctly', () {
      final stats = AttendanceStats(
        totalClasses: 10,
        presentCount: 6,
        absentCount: 3,
        lateCount: 1,
      );

      expect(stats.presentPercentage, 60.0);
      expect(stats.absentPercentage, 30.0);
      expect(stats.latePercentage, 10.0);
    });

    test('handles zero total classes', () {
      final stats = AttendanceStats(
        totalClasses: 0,
        presentCount: 0,
        absentCount: 0,
        lateCount: 0,
      );

      expect(stats.presentPercentage, 0.0);
      expect(stats.absentPercentage, 0.0);
      expect(stats.latePercentage, 0.0);
    });

    test('getStatusColor returns correct colors', () {
      final stats = AttendanceStats(
        totalClasses: 1,
        presentCount: 1,
        absentCount: 0,
        lateCount: 0,
      );

      expect(stats.getStatusColor('present'), Colors.green);
      expect(stats.getStatusColor('absent'), Colors.red);
      expect(stats.getStatusColor('late'), Colors.orange);
      expect(stats.getStatusColor('invalid'), Colors.grey);
    });
  });

  group('AttendanceHistory Records By Class Tests', () {
    test('records are correctly grouped by class', () async {
      final history = await attendanceService.getAttendanceHistory('student1');

      for (final courseId in history.recordsByClass.keys) {
        final records = history.recordsByClass[courseId]!;
        for (final record in records) {
          expect(record.courseId, equals(courseId));
        }
      }
    });

    test('all records are included in recordsByClass', () async {
      final history = await attendanceService.getAttendanceHistory('student1');

      final totalRecordsInGroups =
          history.recordsByClass.values.expand((records) => records).length;

      expect(totalRecordsInGroups, equals(history.records.length));
    });
  });

  group('Edge Cases', () {
    test('handles end date before start date', () async {
      final startDate = DateTime.now();
      final endDate = startDate.subtract(const Duration(days: 1));

      final history = await attendanceService.getAttendanceHistory(
        'student1',
        startDate: startDate,
        endDate: endDate,
      );

      expect(history.records, isEmpty);
    });

    test('handles null date ranges', () async {
      final history = await attendanceService.getAttendanceHistory('student1');
      expect(history.records, isNotEmpty);
    });

    test('handles future dates', () async {
      final futureDate = DateTime.now().add(const Duration(days: 30));

      final history = await attendanceService.getAttendanceHistory(
        'student1',
        startDate: futureDate,
      );

      expect(history.records, isEmpty);
    });
  });

  group('Provider Tests', () {
    test('attendanceServiceProvider provides AttendanceService instance', () {
      final container = ProviderContainer();
      final service = container.read(attendanceServiceProvider);
      expect(service, isA<AttendanceService>());
    });

    test('attendanceHistoryProvider returns attendance history', () async {
      final container = ProviderContainer();
      final futureHistory = container.read(
        attendanceHistoryProvider((
          'student1',
          DateTime.now().subtract(const Duration(days: 7)),
          DateTime.now(),
        )),
      );

      final history = await futureHistory.when(
        data: (data) => data,
        loading: () => null,
        error: (_, __) => null,
      );

      expect(history, isA<AttendanceHistory>());
    });
  });
}
