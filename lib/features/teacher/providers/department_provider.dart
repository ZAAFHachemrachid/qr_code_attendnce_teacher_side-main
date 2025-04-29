import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/teacher_profile_provider.dart';

final departmentProvider =
    FutureProvider.autoDispose<Map<String, dynamic>?>((ref) async {
  final profile = await ref.watch(teacherProfileProvider.future);
  if (profile?.departmentId == null) return null;

  try {
    final departmentId = profile!.departmentId;
    if (departmentId == null) return null;

    print('Fetching department with ID: $departmentId');
    final response = await Supabase.instance.client
        .from('departments')
        .select()
        .eq('id', departmentId)
        .maybeSingle();

    print('Department response: $response');
    return response;
  } catch (error) {
    print('Error loading department: $error');
    return null;
  }
});
