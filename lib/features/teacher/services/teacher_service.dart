import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/timeline_entry.dart';

class TeacherService {
  final _supabase = Supabase.instance.client;

  Future<List<TeacherTimelineEntry>> getWeeklySchedule() async {
    try {
      final response = await _supabase
          .from('teacher_timeline')
          .select()
          .eq('teacher_id', _supabase.auth.currentUser!.id);

      return (response as List)
          .map((json) => TeacherTimelineEntry.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch weekly schedule: $e');
    }
  }
}
