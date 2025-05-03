import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/dummy_course.dart';
import '../models/student_profile.dart';
import 'student_providers.dart';
import 'student_courses_provider.dart';

final dummyCourseProvider =
    StateNotifierProvider<DummyCourseNotifier, AsyncValue<List<DummyCourse>>>(
        (ref) {
  final studentProfileAsync = ref.watch(studentProfileProvider);
  return DummyCourseNotifier(ref, studentProfileAsync);
});

class DummyCourseNotifier extends StateNotifier<AsyncValue<List<DummyCourse>>> {
  final Ref _ref;
  final AsyncValue<StudentProfile> _studentProfileAsync;
  static const int maxDummyCourses = 5;

  DummyCourseNotifier(this._ref, this._studentProfileAsync)
      : super(const AsyncValue.loading()) {
    _initialize();
  }

  Future<void> _initialize() async {
    state = const AsyncValue.loading();

    try {
      final studentProfile = _studentProfileAsync.value;
      if (studentProfile == null) {
        state = const AsyncValue.data([]);
        return;
      }

      final numDummyCourses = await _getNumberOfDummyCourses(studentProfile);
      if (numDummyCourses > 0) {
        state = AsyncValue.data(
          List.generate(
            numDummyCourses,
            (index) => DummyCourse.create(
              studentId: studentProfile.id,
              academicYear: DateTime.now().year,
              semester: _getCurrentSemester(),
              index: index,
            ),
          ),
        );
      } else {
        state = const AsyncValue.data([]);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<int> _getNumberOfDummyCourses(StudentProfile studentProfile) async {
    try {
      final hasRealCourses = await _ref
          .read(studentCoursesProvider.notifier)
          .hasValidCourses(studentProfile.groupId);

      if (!hasRealCourses) {
        // If no real courses, show 3 dummy courses
        return maxDummyCourses;
      } else {
        // If has real courses, show 3 dummy courses
        return 3;
      }
    } catch (e) {
      // Default to 3 dummy courses on error
      return 3;
    }
  }

  String _getCurrentSemester() {
    // Always return SPRING for Spring 2025 semester
    return 'SPRING';
  }

  void refreshDummyCourses() async {
    final studentProfile = _studentProfileAsync.value;
    if (studentProfile != null) {
      await _initialize();
    }
  }

  void clearDummyCourses() {
    state = const AsyncValue.data([]);
  }
}
