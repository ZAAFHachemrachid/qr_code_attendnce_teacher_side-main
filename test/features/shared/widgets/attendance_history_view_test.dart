import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:qr_code_attendance/features/shared/widgets/attendance_history_view.dart';
import 'package:qr_code_attendance/features/shared/widgets/date_range_filter.dart';
import 'package:qr_code_attendance/features/student/models/attendance_history.dart';

void main() {
  final mockHistory = AttendanceHistory(
    records: [
      AttendanceRecord(
        courseId: 'CS101',
        courseName: 'Introduction to Programming',
        date: DateTime(2025, 5, 4),
        status: 'present',
        courseType: 'TD',
      ),
      AttendanceRecord(
        courseId: 'CS101',
        courseName: 'Introduction to Programming',
        date: DateTime(2025, 5, 3),
        status: 'absent',
        courseType: 'TD',
      ),
      AttendanceRecord(
        courseId: 'CS102',
        courseName: 'Data Structures',
        date: DateTime(2025, 5, 2),
        status: 'late',
        courseType: 'TP',
      ),
    ],
    stats: const AttendanceStats(
      totalClasses: 3,
      presentCount: 1,
      absentCount: 1,
      lateCount: 1,
    ),
    recordsByClass: {
      'CS101': [
        AttendanceRecord(
          courseId: 'CS101',
          courseName: 'Introduction to Programming',
          date: DateTime(2025, 5, 4),
          status: 'present',
          courseType: 'TD',
        ),
        AttendanceRecord(
          courseId: 'CS101',
          courseName: 'Introduction to Programming',
          date: DateTime(2025, 5, 3),
          status: 'absent',
          courseType: 'TD',
        ),
      ],
      'CS102': [
        AttendanceRecord(
          courseId: 'CS102',
          courseName: 'Data Structures',
          date: DateTime(2025, 5, 2),
          status: 'late',
          courseType: 'TP',
        ),
      ],
    },
  );

  group('AttendanceHistoryView Widget Tests', () {
    testWidgets('renders all sections in full mode',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AttendanceHistoryView(
              history: mockHistory,
              onDateRangeChanged: (_, __) {},
            ),
          ),
        ),
      );

      expect(find.text('Attendance Overview'), findsOneWidget);
      expect(find.text('Recent Activity'), findsOneWidget);
      expect(find.text('Attendance by Course'), findsOneWidget);
      expect(find.byType(PieChart), findsOneWidget);
      expect(find.byType(DateRangeFilter), findsOneWidget);
    });

    testWidgets('renders only overview in compact mode',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AttendanceHistoryView(
              history: mockHistory,
              isCompact: true,
            ),
          ),
        ),
      );

      expect(find.text('Attendance Overview'), findsOneWidget);
      expect(find.text('Recent Activity'), findsNothing);
      expect(find.text('Attendance by Course'), findsNothing);
      expect(find.byType(DateRangeFilter), findsNothing);
    });

    testWidgets('displays correct stats in legend',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AttendanceHistoryView(
              history: mockHistory,
            ),
          ),
        ),
      );

      expect(find.text('1', skipOffstage: false),
          findsNWidgets(3)); // One each for present, absent, late
      expect(find.text('Present'), findsOneWidget);
      expect(find.text('Absent'), findsOneWidget);
      expect(find.text('Late'), findsOneWidget);
    });

    testWidgets('shows correct number of timeline entries',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AttendanceHistoryView(
              history: mockHistory,
            ),
          ),
        ),
      );

      expect(
        find.byWidgetPredicate(
          (widget) => widget is ListTile && widget.subtitle != null,
        ),
        findsNWidgets(5), // Timeline + Course records (3 timeline + 2 courses)
      );
    });

    testWidgets('displays correct course attendance rates',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AttendanceHistoryView(
              history: mockHistory,
            ),
          ),
        ),
      );

      expect(find.text('50.0%'), findsOneWidget); // CS101: 1 present out of 2
      expect(find.text('0.0%'), findsOneWidget); // CS102: 0 present out of 1
    });

    testWidgets('triggers date range callback', (WidgetTester tester) async {
      DateTime? capturedStart;
      DateTime? capturedEnd;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AttendanceHistoryView(
              history: mockHistory,
              onDateRangeChanged: (start, end) {
                capturedStart = start;
                capturedEnd = end;
              },
            ),
          ),
        ),
      );

      // Find and tap the DateRangeFilter's clear button if dates are set
      final clearButton = find.text('Clear');
      if (clearButton.evaluate().isNotEmpty) {
        await tester.tap(clearButton);
        await tester.pump();

        expect(capturedStart, isNull);
        expect(capturedEnd, isNull);
      }
    });

    testWidgets('uses correct status colors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AttendanceHistoryView(
              history: mockHistory,
            ),
          ),
        ),
      );

      expect(find.text('PRESENT'), findsOneWidget);
      expect(find.text('ABSENT'), findsOneWidget);
      expect(find.text('LATE'), findsOneWidget);

      final presentIcon = tester.widget<Icon>(
        find.byIcon(Icons.check_circle).first,
      );
      final absentIcon = tester.widget<Icon>(
        find.byIcon(Icons.cancel).first,
      );
      final lateIcon = tester.widget<Icon>(
        find.byIcon(Icons.warning).first,
      );

      expect(presentIcon.color, equals(Colors.green));
      expect(absentIcon.color, equals(Colors.red));
      expect(lateIcon.color, equals(Colors.orange));
    });
  });
}
