import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_code_attendance/features/shared/widgets/date_range_filter.dart';

void main() {
  group('DateRangeFilter Widget Tests', () {
    testWidgets('renders correctly with no dates selected',
        (WidgetTester tester) async {
      DateTime? capturedStartDate;
      DateTime? capturedEndDate;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DateRangeFilter(
              onDateRangeChanged: (start, end) {
                capturedStartDate = start;
                capturedEndDate = end;
              },
            ),
          ),
        ),
      );

      expect(find.text('Filter by Date'), findsOneWidget);
      expect(find.text('Start Date'), findsOneWidget);
      expect(find.text('End Date'), findsOneWidget);
      expect(find.text('Select Date'), findsNWidgets(2));
      expect(find.text('Clear'), findsNothing);
    });

    testWidgets('shows clear button when dates are selected',
        (WidgetTester tester) async {
      final now = DateTime.now();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DateRangeFilter(
              startDate: now,
              endDate: now.add(const Duration(days: 1)),
              onDateRangeChanged: (_, __) {},
            ),
          ),
        ),
      );

      expect(find.text('Clear'), findsOneWidget);
    });

    testWidgets('clear button resets dates', (WidgetTester tester) async {
      DateTime? capturedStartDate;
      DateTime? capturedEndDate;
      final now = DateTime.now();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DateRangeFilter(
              startDate: now,
              endDate: now.add(const Duration(days: 1)),
              onDateRangeChanged: (start, end) {
                capturedStartDate = start;
                capturedEndDate = end;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Clear'));
      await tester.pump();

      expect(capturedStartDate, isNull);
      expect(capturedEndDate, isNull);
    });

    testWidgets('formats date correctly', (WidgetTester tester) async {
      final date = DateTime(2025, 5, 4);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DateRangeFilter(
              startDate: date,
              onDateRangeChanged: (_, __) {},
            ),
          ),
        ),
      );

      expect(find.text('4/5/2025'), findsOneWidget);
    });

    testWidgets('tapping start date opens date picker',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DateRangeFilter(
              onDateRangeChanged: (_, __) {},
            ),
          ),
        ),
      );

      await tester.tap(find.text('Select Date').first);
      await tester.pumpAndSettle();

      expect(find.byType(DatePickerDialog), findsOneWidget);
    });

    testWidgets('selecting date triggers callback',
        (WidgetTester tester) async {
      DateTime? capturedStartDate;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DateRangeFilter(
              onDateRangeChanged: (start, end) {
                capturedStartDate = start;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Select Date').first);
      await tester.pumpAndSettle();

      // Find and tap today's date in the date picker
      await tester.tap(find.text(DateTime.now().day.toString()).first);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(capturedStartDate, isNotNull);
      expect(
        capturedStartDate?.year,
        equals(DateTime.now().year),
      );
    });
  });
}
