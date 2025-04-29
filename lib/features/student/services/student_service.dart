import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/student_profile.dart';
import '../models/attendance_record.dart';
import '../models/timeline_entry.dart';

class StudentService {
  final SupabaseClient _supabase;

  StudentService() : _supabase = Supabase.instance.client;

  Future<StudentProfile> getStudentProfile() async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      debugPrint('Fetching profile for user: $userId');

      final response = await _supabase.from('profiles').select('''
            *,
            student_profiles!inner(
              id,
              student_number,
              group_id
            )
          ''').eq('id', userId).single();

      debugPrint('Profile response: $response');

      final profile = StudentProfile(
        id: response['id'],
        studentNumber: response['student_profiles']['student_number'],
        groupId: response['student_profiles']['group_id'],
        firstName: response['first_name'],
        lastName: response['last_name'],
      );

      return profile;
    } catch (e) {
      debugPrint('Error fetching profile: $e');
      throw Exception('Failed to get student profile: $e');
    }
  }

  Future<List<AttendanceRecord>> getAttendanceRecords() async {
    try {
      final userId = _supabase.auth.currentUser!.id;

      final response = await _supabase.from('attendance').select('''
            *,
            sessions!inner(
              id,
              title,
              session_date,
              start_time,
              end_time,
              room
            )
          ''').eq('student_id', userId);

      return (response as List).map((record) {
        final session = record['sessions'];
        return AttendanceRecord(
          id: record['id'],
          sessionId: record['session_id'],
          studentId: record['student_id'],
          status: record['status'],
          checkInTime: DateTime.parse(record['check_in_time']),
          notes: record['notes'],
          createdAt: DateTime.parse(record['created_at']),
          sessionTitle: session['title'],
          sessionDate: DateTime.parse(session['session_date']),
          startTime: session['start_time'],
          endTime: session['end_time'],
          room: session['room'],
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to get attendance records: $e');
    }
  }

  Future<List<TimelineEntry>> getWeeklySchedule() async {
    try {
      final profile = await getStudentProfile();
      debugPrint('Fetching schedule for group: ${profile.groupId}');

      debugPrint('Executing weekly schedule query...');
      final response = await _supabase
          .from('weekly_schedule')
          .select('''
            id,
            type_c,
            day_of_week,
            room,
            courses!inner(
              title,
              code
            ),
            student_groups!inner(
              name
            ),
            teacher_profiles!inner(
              profiles!inner(
                first_name,
                last_name
              )
            ),
            time_slots!inner(
              slot_number,
              start_time,
              end_time
            )
          ''')
          .eq('group_id', profile.groupId)
          .order('day_of_week', ascending: true)
          .order('time_slots(slot_number)', ascending: true);

      debugPrint('Schedule response count: ${(response as List).length}');

      return response.map((record) {
        final teacher = record['teacher_profiles']['profiles'];
        final course = record['courses'];
        final group = record['student_groups'];
        final timeSlot = record['time_slots'];

        debugPrint(
            'Processing record: Day=${record['day_of_week']}, Time=${timeSlot['start_time']}');

        return TimelineEntry(
          id: record['id'],
          groupName: group['name'],
          courseName: course['title'],
          courseCode: course['code'],
          type: record['type_c'],
          teacherName: '${teacher['first_name']} ${teacher['last_name']}',
          dayOfWeek: record['day_of_week'],
          startTime: timeSlot['start_time'],
          endTime: timeSlot['end_time'],
          slotNumber: timeSlot['slot_number'],
          room: record['room'],
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching schedule: $e');
      throw Exception('Failed to get weekly schedule: $e');
    }
  }

  Future<void> markAttendance(String sessionId, String qrCode) async {
    try {
      final userId = _supabase.auth.currentUser!.id;

      // First verify the QR code matches the session
      final sessionResponse = await _supabase
          .from('sessions')
          .select()
          .eq('id', sessionId)
          .eq('qr_code', qrCode)
          .single();

      // Check if attendance was already marked
      final existingAttendance = await _supabase
          .from('attendance')
          .select()
          .eq('session_id', sessionId)
          .eq('student_id', userId)
          .single();

      throw Exception('Attendance already marked for this session');

      // Mark attendance
      await _supabase.from('attendance').insert({
        'session_id': sessionId,
        'student_id': userId,
        'status': 'present',
        'check_in_time': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to mark attendance: $e');
    }
  }
}
