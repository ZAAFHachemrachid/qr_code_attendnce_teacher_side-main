import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/course.dart' show ClassInfo, CourseGroup;
import '../models/class_type.dart';

final teacherStudentServiceProvider = Provider<TeacherStudentService>((ref) {
  final supabase = Supabase.instance.client;
  return TeacherStudentService(supabase);
});

class TeacherStudentService {
  final SupabaseClient _supabase;

  TeacherStudentService(this._supabase);

  Future<List<ClassInfo>> fetchStudentCourses(String groupId) async {
    try {
      final response = await _supabase.from('courses').select('''
            *,
            group_courses!inner(
              academic_period,
              group_id
            ),
            student_groups!inner(
              id,
              name,
              academic_year,
              current_year,
              section,
              student_count
            )
          ''').eq('group_courses.group_id', groupId).order('code');

      return response.map<ClassInfo>((course) {
        final group = CourseGroup(
          id: course['student_groups']['id'],
          name: course['student_groups']['name'],
          academicYear: course['student_groups']['academic_year'],
          currentYear: course['student_groups']['current_year'],
          section: course['student_groups']['section'],
          studentCount: course['student_groups']['student_count'] ?? 0,
        );

        return ClassInfo(
          id: course['id'],
          code: course['code'],
          title: course['title'],
          description: course['description'],
          creditHours: course['credit_hours'],
          yearOfStudy: course['year_of_study'],
          semester: course['semester'],
          groups: [group],
          schedule: course['group_courses']['academic_period'],
          type: ClassType.fromString(course['type'] ?? 'course'),
        );
      }).toList();
    } catch (e, stack) {
      throw Exception('Failed to fetch student courses: $e\n$stack');
    }
  }

  Future<CourseGroup?> fetchStudentGroup(String groupId) async {
    try {
      final response = await _supabase
          .from('student_groups')
          .select()
          .eq('id', groupId)
          .single();

      if (response == null) return null;

      return CourseGroup(
        id: response['id'],
        name: response['name'],
        academicYear: response['academic_year'],
        currentYear: response['current_year'],
        section: response['section'],
        studentCount: response['student_count'] ?? 0,
      );
    } catch (e) {
      throw Exception('Failed to fetch student group: $e');
    }
  }
}
