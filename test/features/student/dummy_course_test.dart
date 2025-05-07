import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:qr_code_attendance/features/student/models/dummy_course.dart';
import 'package:qr_code_attendance/features/student/models/student_profile.dart';
import 'package:qr_code_attendance/features/student/providers/dummy_course_provider.dart';
import 'package:qr_code_attendance/features/student/providers/student_courses_provider.dart';
import 'package:qr_code_attendance/features/student/providers/student_providers.dart';
import 'package:qr_code_attendance/features/student/widgets/dummy_course_card.dart';

class MockStudentCoursesNotifier extends StudentCoursesNotifier {
  @override
  Future<bool> hasValidCourses(String? groupId) async {
    return false; // Always return false to trigger dummy course creation
  }
}

void main() {
  group('DummyCourse Tests', () {
    test('DummyCourse creation with correct values', () {
      final dummyCourse = DummyCourse.create(
        studentId: 'test-student',
        academicYear: 2025,
        semester: 'FALL',
      );

      expect(dummyCourse.isDummy, true);
      expect(dummyCourse.code, 'DUMMY-2025-FALL');
      expect(dummyCourse.title, 'Pending Course Assignment');
      expect(dummyCourse.creditHours, 0);
      expect(dummyCourse.groups.length, 1);
      expect(dummyCourse.groups.first, isA<DummyGroup>());
    });

    testWidgets('DummyCourseCard renders correctly', (tester) async {
      final dummyCourse = DummyCourse.create(
        studentId: 'test-student',
        academicYear: 2025,
        semester: 'FALL',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DummyCourseCard(course: dummyCourse),
          ),
        ),
      );

      expect(find.text('Pending Course Assignment'), findsOneWidget);
      expect(
          find.text('Your courses have not been assigned yet'), findsOneWidget);
      expect(
        find.text('Please contact your administrator for course assignment.'),
        findsOneWidget,
      );
    });

    testWidgets('DummyCourse integration test', (tester) async {
      // Create test providers
      final container = ProviderContainer(
        overrides: [
          studentProfileProvider.overrideWith(
            (ref) => Future.value(
              const StudentProfile(
                id: 'test-student',
                studentNumber: 'TEST001',
                groupId: 'no-group',
                firstName: 'Test',
                lastName: 'Student',
              ),
            ),
          ),
          studentCoursesProvider
              .overrideWith((ref) => MockStudentCoursesNotifier()),
        ],
      );

      addTearDown(container.dispose);

      // Build widget with providers
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                final dummyCourses = container.read(dummyCourseProvider);
                return dummyCourses.when(
                  loading: () => const CircularProgressIndicator(),
                  error: (e, s) => Text('Error: $e'),
                  data: (courses) => ListView.builder(
                    itemCount: courses.length,
                    itemBuilder: (context, index) =>
                        DummyCourseCard(course: courses[index]),
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Wait for async operations
      await tester.pumpAndSettle();

      // Verify dummy course is created and displayed
      expect(find.text('Pending Course Assignment'), findsOneWidget);
      expect(
          find.text('Your courses have not been assigned yet'), findsOneWidget);
    });
  });
}
