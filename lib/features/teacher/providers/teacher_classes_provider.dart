import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/teacher_class.dart';
import '../../auth/providers/auth_provider.dart';

final teacherClassesProvider =
    AsyncNotifierProvider<TeacherClassesNotifier, List<TeacherClass>>(() {
  return TeacherClassesNotifier();
});

class TeacherClassesNotifier extends AsyncNotifier<List<TeacherClass>> {
  String _academicPeriod = DateTime.now().year.toString();
  String get academicPeriod => _academicPeriod;

  Future<void> setAcademicPeriod(String period) async {
    _academicPeriod = period;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }

  Future<List<TeacherClass>> _fetchClasses(String teacherId) async {
    try {
      final response = await Supabase.instance.client
          .from('teacher_course_groups')
          .select('''
            course_id,
            courses (
              id,
              code,
              title,
              description,
              credit_hours,
              year_of_study,
              semester
            ),
            student_groups (
              id,
              name,
              academic_year,
              current_year,
              section,
              student_count:student_profiles(count)
            )
          ''')
          .eq('teacher_id', teacherId)
          .eq('academic_period', _academicPeriod);

      // Process the response to extract courses and their groups
      final classMap = <String, Map<String, dynamic>>{};

      for (final item in response as List) {
        final course = item['courses'] as Map<String, dynamic>;
        final group = item['student_groups'] as Map<String, dynamic>;
        final courseId = course['id'] as String;

        if (!classMap.containsKey(courseId)) {
          classMap[courseId] = {
            ...course,
            'groups': <Map<String, dynamic>>[],
            'academic_period': _academicPeriod,
            'schedule': _generateSchedule(courseId),
            'type': _determineClassType(item['type'] as String? ?? 'course'),
          };
        }
        classMap[courseId]!['groups'].add(group);
      }

      // Convert to TeacherClass objects
      return classMap.values
          .map((data) => TeacherClass.fromJson(data))
          .toList();
    } catch (error, stackTrace) {
      print('[TeacherClassesNotifier] Error fetching classes: $error');
      print('[TeacherClassesNotifier] Stack trace: $stackTrace');
      throw Exception('Failed to fetch teacher classes: $error');
    }
  }

  @override
  Future<List<TeacherClass>> build() async {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (state) async {
        if (state.session?.user.id == null) {
          return [];
        }
        return _fetchClasses(state.session!.user.id);
      },
      loading: () => [],
      error: (_, __) => [],
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }
}

String _determineClassType(String type) {
  switch (type.toLowerCase()) {
    case 'td':
      return 'td';
    case 'tp':
      return 'tp';
    default:
      return 'course';
  }
}

String _generateSchedule(String courseId) {
  final daysOfWeek = ['Mon', 'Tue', 'Wed', 'Thu'];
  final startTimes = ['08:00', '10:00', '13:00', '15:00'];

  final hash = courseId.hashCode;
  final day1 = daysOfWeek[hash % daysOfWeek.length];
  final day2 = daysOfWeek[(hash + 2) % daysOfWeek.length];
  final time = startTimes[(hash + 1) % startTimes.length];

  return '$day1, $day2 $time';
}

// Provider for managing the current academic period
final academicPeriodProvider =
    StateProvider<String>((ref) => DateTime.now().year.toString());

// Provider that generates a list of academic years (current ±2 years)
final academicPeriodsProvider = Provider<List<String>>((ref) {
  final currentYear = DateTime.now().year;
  return [
    (currentYear - 2).toString(),
    (currentYear - 1).toString(),
    currentYear.toString(),
    (currentYear + 1).toString(),
    (currentYear + 2).toString(),
  ]..sort(); // Sort years in ascending order
});

// Provider that exposes the notifier's academicPeriod
final currentAcademicPeriodProvider = Provider<String>((ref) {
  return ref.watch(teacherClassesProvider.notifier).academicPeriod;
});

// Provider that depends on teacherClassesProvider and filters based on academic period
final filteredClassesProvider = Provider<AsyncValue<List<TeacherClass>>>((ref) {
  final classesAsync = ref.watch(teacherClassesProvider);
  final currentPeriod = ref.watch(academicPeriodProvider);

  // Trigger period change in the notifier
  ref.listen(academicPeriodProvider, (previous, next) {
    if (previous != next) {
      ref.read(teacherClassesProvider.notifier).setAcademicPeriod(next);
    }
  });

  return classesAsync;
});
