import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/course.dart';

class TeacherClassesService {
  final SupabaseClient _supabaseClient;

  TeacherClassesService(this._supabaseClient);

  Future<List<ClassInfo>> getTeacherCourses(
    String teacherId,
    String academicPeriod,
  ) async {
    try {
      print(
          '[TeacherClassesService] Fetching courses for teacher: $teacherId, period: $academicPeriod');

      // First get the courses
      final coursesResponse = await _supabaseClient
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
            )
          ''')
          .eq('teacher_id', teacherId)
          .eq('academic_period', academicPeriod);

      print(
          '[TeacherClassesService] Courses response received: ${coursesResponse.length} items');

      final courseData = coursesResponse as List;
      final courses = <String, Map<String, dynamic>>{};

      // Process course data
      print('[TeacherClassesService] Processing course data');
      for (final item in courseData) {
        print(
            '[TeacherClassesService] Processing course item: ${item['course_id']}');
        final course = item['courses'] as Map<String, dynamic>;
        if (!courses.containsKey(course['id'])) {
          courses[course['id']] = {
            ...course,
            'groups': <Map<String, dynamic>>[],
          };
        }
      }

      print('[TeacherClassesService] Found ${courses.length} courses');

      // Now get the groups for these courses
      if (courses.isNotEmpty) {
        print(
            '[TeacherClassesService] Fetching groups for courses: ${courses.keys.toList()}');
        final groupsResponse = await _supabaseClient
            .from('teacher_course_groups')
            .select('''
              course_id,
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
            .eq('academic_period', academicPeriod)
            .inFilter('course_id', courses.keys.toList());

        final groupData = groupsResponse as List;

        // Add groups to their respective courses
        for (final item in groupData) {
          final courseId = item['course_id'] as String;
          final group = item['student_groups'] as Map<String, dynamic>;
          courses[courseId]!['groups'].add(group);
        }
      }

      // Convert to ClassInfo objects
      try {
        print(
            '[TeacherClassesService] Converting ${courses.length} courses to ClassInfo objects');
        final result = courses.values.map((courseData) {
          print(
              '[TeacherClassesService] Converting course: ${courseData['id']}');
          return ClassInfo.fromJson({
            ...courseData,
            'schedule': _generateSchedule(courseData['id']),
          });
        }).toList();
        print('[TeacherClassesService] Successfully converted all courses');
        return result;
      } catch (error, stackTrace) {
        print('[TeacherClassesService] Error converting courses: $error');
        print('[TeacherClassesService] Stack trace: $stackTrace');
        throw Exception('Failed to convert course data: $error');
      }
    } catch (error) {
      print('[TeacherClassesService] Error fetching teacher courses: $error');
      throw Exception('Failed to fetch teacher courses: $error');
    }
  }

  Future<List<CourseGroup>> getCourseGroups(
    String courseId,
    String academicPeriod,
  ) async {
    try {
      final response = await _supabaseClient.from('student_groups').select('''
            id,
            name,
            academic_year,
            current_year,
            section,
            student_count:student_profiles(count)
          ''').eq('course_id', courseId);

      final data = response as List;
      return data.map((json) => CourseGroup.fromJson(json)).toList();
    } catch (error) {
      throw Exception('Failed to fetch course groups: $error');
    }
  }

  // Temporary helper method to generate schedule string
  // TODO: Replace with actual schedule data from the database
  String _generateSchedule(String courseId) {
    final daysOfWeek = ['Mon', 'Tue', 'Wed', 'Thu'];
    final startTimes = ['08:00', '10:00', '13:00', '15:00'];

    final hash = courseId.hashCode;
    final day1 = daysOfWeek[hash % daysOfWeek.length];
    final day2 = daysOfWeek[(hash + 2) % daysOfWeek.length];
    final time = startTimes[(hash + 1) % startTimes.length];

    return '$day1, $day2 $time';
  }
}
