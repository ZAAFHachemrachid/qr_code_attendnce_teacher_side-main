import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../teacher/models/course.dart';
import '../../teacher/services/teacher_student_service.dart';

final studentCoursesProvider =
    StateNotifierProvider<StudentCoursesNotifier, AsyncValue<List<ClassInfo>>>(
        (ref) {
  final teacherStudentService = ref.watch(teacherStudentServiceProvider);
  return StudentCoursesNotifier(teacherStudentService);
});

class StudentCoursesNotifier
    extends StateNotifier<AsyncValue<List<ClassInfo>>> {
  final TeacherStudentService _teacherStudentService;

  StudentCoursesNotifier(this._teacherStudentService)
      : super(const AsyncValue.loading());

  Future<bool> hasValidCourses(String? groupId) async {
    if (groupId == null) return false;

    try {
      final courses = await _teacherStudentService.fetchStudentCourses(groupId);
      return courses.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<List<ClassInfo>> _fetchCoursesForGroup(String groupId) async {
    try {
      return await _teacherStudentService.fetchStudentCourses(groupId);
    } catch (e) {
      // Log error here if needed
      return [];
    }
  }

  Future<void> refreshCourses(String? groupId) async {
    if (groupId == null) {
      state = const AsyncValue.data([]);
      return;
    }

    try {
      state = const AsyncValue.loading();
      final courses = await _teacherStudentService.fetchStudentCourses(groupId);
      state = AsyncValue.data(courses);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
