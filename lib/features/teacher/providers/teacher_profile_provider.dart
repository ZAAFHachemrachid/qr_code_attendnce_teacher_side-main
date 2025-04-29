import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/teacher_profile.dart';

final teacherProfileProvider =
    AsyncNotifierProvider<TeacherProfileNotifier, TeacherProfile?>(() {
  return TeacherProfileNotifier();
});

class TeacherProfileNotifier extends AsyncNotifier<TeacherProfile?> {
  Future<TeacherProfile?> _fetchProfile(String userId) async {
    try {
      print('[TeacherProfileNotifier] Fetching profile for user: $userId');

      // First check if base profile exists
      final baseProfiles = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', userId);

      print(
          '[TeacherProfileNotifier] Base profile check: ${baseProfiles.length} records found');

      // Then check teacher profile
      final teacherProfiles = await Supabase.instance.client
          .from('teacher_profiles')
          .select()
          .eq('id', userId);

      print(
          '[TeacherProfileNotifier] Teacher profile check: ${teacherProfiles.length} records found');

      if (baseProfiles.isEmpty) {
        throw Exception('No base profile found for user');
      }

      if (teacherProfiles.isEmpty) {
        throw Exception('No teacher profile found for user');
      }

      final response =
          await Supabase.instance.client.from('teacher_profiles').select('''
            id,
            employee_id,
            department_id,
            created_at,
            updated_at,
            profiles (
              first_name,
              last_name,
              phone
            ),
            departments (
              name,
              code
            )
          ''').eq('id', userId).single();

      print('[TeacherProfileNotifier] Raw response: $response');
      print('[TeacherProfileNotifier] Response type: ${response.runtimeType}');
      return TeacherProfile.fromJson(response);
    } catch (error, stackTrace) {
      print('[TeacherProfileNotifier] Error fetching profile: $error');
      print('[TeacherProfileNotifier] Stack trace: $stackTrace');
      throw Exception('Failed to fetch teacher profile: $error');
    }
  }

  @override
  Future<TeacherProfile?> build() async {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (state) async {
        if (state.session?.user.id == null) {
          print('[TeacherProfileNotifier] No user ID found in session');
          return null;
        }
        return _fetchProfile(state.session!.user.id);
      },
      loading: () {
        print('[TeacherProfileNotifier] Auth state is loading');
        return null;
      },
      error: (error, stack) {
        print('[TeacherProfileNotifier] Auth state error: $error');
        return null;
      },
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }

  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    String? phone,
    String? departmentId,
  }) async {
    final currentState = state.valueOrNull;
    if (currentState == null) {
      throw Exception('Cannot update profile: No current profile found');
    }

    state = const AsyncValue.loading();

    try {
      // Update profiles table
      await Supabase.instance.client.from('profiles').update({
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', currentState.id);

      // Update teacher_profiles table if department changed
      if (departmentId != null && departmentId != currentState.departmentId) {
        await Supabase.instance.client.from('teacher_profiles').update({
          'department_id': departmentId,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', currentState.id);
      }

      // Refresh the profile data
      state = await AsyncValue.guard(() => _fetchProfile(currentState.id));
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      throw Exception('Failed to update profile: $error');
    }
  }

  Future<List<Map<String, dynamic>>> fetchDepartments() async {
    try {
      final response = await Supabase.instance.client
          .from('departments')
          .select('id, name, code')
          .order('name');

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch departments: $error');
    }
  }
}
