import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/student_profile.dart';

final teacherStudentsServiceProvider = Provider<TeacherStudentsService>((ref) {
  final supabase = Supabase.instance.client;
  return TeacherStudentsService(supabase);
});

class TeacherStudentsService {
  final SupabaseClient _supabase;

  TeacherStudentsService(this._supabase);

  Future<List<StudentProfile>> fetchEnrolledStudents(
    String courseId,
    String academicPeriod,
  ) async {
    try {
      final response = await _supabase
          .from('student_profiles')
          .select('''
            id,
            student_number,
            profiles!inner (
              first_name,
              last_name
            ),
            student_groups!inner (
              name,
              section,
              current_year,
              group_courses!inner (
                course_id,
                academic_period
              )
            )
          ''')
          .eq('student_groups.group_courses.course_id', courseId)
          .eq('student_groups.group_courses.academic_period', academicPeriod);

      return response.map<StudentProfile>((json) {
        final profile = json['profiles'];
        final group = json['student_groups'];

        return StudentProfile(
          id: json['id'],
          firstName: profile['first_name'],
          lastName: profile['last_name'],
          studentNumber: json['student_number'],
          groupName: group['name'],
          section: group['section'],
          currentYear: group['current_year'],
        );
      }).toList();
    } catch (e, stack) {
      throw Exception('Failed to fetch enrolled students: $e\n$stack');
    }
  }

  Future<double> getStudentAttendancePercentage(
    String courseId,
    String studentId,
  ) async {
    try {
      final response = await _supabase.from('attendance').select('''
            status,
            sessions!inner (
              course_id
            )
          ''').eq('student_id', studentId).eq('sessions.course_id', courseId);

      final totalSessions = response.length;
      if (totalSessions == 0) return 0.0;

      final presentCount =
          response.where((record) => record['status'] == 'present').length;

      return (presentCount / totalSessions) * 100;
    } catch (e) {
      throw Exception('Failed to fetch student attendance: $e');
    }
  }
}
