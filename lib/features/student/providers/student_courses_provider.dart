import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../teacher/models/course.dart';

final studentCoursesProvider =
    StateNotifierProvider<StudentCoursesNotifier, AsyncValue<List<ClassInfo>>>(
        (ref) {
  return StudentCoursesNotifier();
});

class StudentCoursesNotifier
    extends StateNotifier<AsyncValue<List<ClassInfo>>> {
  StudentCoursesNotifier() : super(const AsyncValue.loading());

  Future<bool> hasValidCourses(String? groupId) async {
    if (groupId == null) return false;

    final courses = await _fetchCoursesForGroup(groupId);
    return courses.isNotEmpty;
  }

  Future<List<ClassInfo>> _fetchCoursesForGroup(String groupId) async {
    try {
      // TODO: Implement actual API call to fetch courses
      // This is a placeholder implementation
      await Future.delayed(const Duration(seconds: 1));
      return [];
    } catch (e) {
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
      final courses = await _fetchCoursesForGroup(groupId);
      state = AsyncValue.data(courses);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
