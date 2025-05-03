import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _roleKey = 'user_role';

  Future<AuthResponse> signUpTeacher({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String employeeId,
  }) async {
    try {
      debugPrint('Attempting to sign up teacher with email: $email');

      // 1. Sign up the user
      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo:
            kDebugMode ? null : null, // Allows auto-confirm in debug mode
        data: {
          'email_confirm_override':
              kDebugMode, // Custom claim to bypass email verification in debug
        },
      );

      if (authResponse.user == null) {
        throw Exception('Signup failed - no user returned');
      }

      // 2. Create the base profile
      await _supabase.from('profiles').insert({
        'id': authResponse.user!.id,
        'first_name': firstName,
        'last_name': lastName,
        'role': 'teacher',
      });

      // 3. Create the teacher profile
      await _supabase.from('teacher_profiles').insert({
        'id': authResponse.user!.id,
        'employee_id': employeeId,
      });

      // Store role in local storage
      await _persistRole('teacher');

      debugPrint('Teacher signup successful:');
      debugPrint('- User ID: ${authResponse.user?.id}');
      debugPrint('- Email: ${authResponse.user?.email}');

      return authResponse;
    } catch (error) {
      debugPrint('Signup error details:');
      debugPrint('- Error type: ${error.runtimeType}');
      debugPrint('- Error message: $error');
      if (error is AuthException) {
        debugPrint('- Status code: ${error.message}');
      }
      rethrow;
    }
  }

  Future<AuthResponse> signUpStudent({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String studentNumber,
    required String groupId,
  }) async {
    try {
      debugPrint('Attempting to sign up student with email: $email');

      // 1. Sign up the user
      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo:
            kDebugMode ? null : null, // Allows auto-confirm in debug mode
        data: {
          'email_confirm_override':
              kDebugMode, // Custom claim to bypass email verification in debug
        },
      );

      if (authResponse.user == null) {
        throw Exception('Signup failed - no user returned');
      }

      // 2. Create the base profile
      await _supabase.from('profiles').insert({
        'id': authResponse.user!.id,
        'first_name': firstName,
        'last_name': lastName,
        'role': 'student',
      });

      // 3. Create the student profile
      await _supabase.from('student_profiles').insert({
        'id': authResponse.user!.id,
        'student_number': studentNumber,
        'group_id': groupId,
      });

      // Store role in local storage
      await _persistRole('student');

      debugPrint('Student signup successful:');
      debugPrint('- User ID: ${authResponse.user?.id}');
      debugPrint('- Email: ${authResponse.user?.email}');

      return authResponse;
    } catch (error) {
      debugPrint('Signup error details:');
      debugPrint('- Error type: ${error.runtimeType}');
      debugPrint('- Error message: $error');
      if (error is AuthException) {
        debugPrint('- Status code: ${error.message}');
      }
      rethrow;
    }
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('Attempting to sign in with email: $email');

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Get and persist role after successful sign in
        final role = await getUserRole();
        if (role != null) {
          await _persistRole(role);
        }

        debugPrint('Sign in successful:');
        debugPrint('- User ID: ${response.user?.id}');
        debugPrint('- Email: ${response.user?.email}');
        debugPrint('- Created at: ${response.user?.createdAt}');
        debugPrint('- Last sign in: ${response.user?.lastSignInAt}');
        if (response.session != null) {
          debugPrint(
              '- Access token: ${response.session?.accessToken.substring(0, 10)}...');
          debugPrint(
              '- Refresh token present: ${response.session?.refreshToken != null}');
        }
      } else {
        debugPrint('Sign in failed - no user returned in response');
      }

      return response;
    } catch (error) {
      debugPrint('Authentication error details:');
      debugPrint('- Error type: ${error.runtimeType}');
      debugPrint('- Error message: $error');
      if (error is AuthException) {
        debugPrint('- Status code: ${error.message}');
      }
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      await _clearPersistedRole();
    } catch (error) {
      debugPrint('Error signing out: $error');
      rethrow;
    }
  }

  Future<String?> getUserRole() async {
    try {
      // First check if we have a cached role
      final cachedRole = await _getPersistedRole();
      if (cachedRole != null) {
        debugPrint('Retrieved cached role: $cachedRole');
        return cachedRole;
      }

      final userId = _supabase.auth.currentUser?.id;
      debugPrint('Getting role for user ID: $userId');
      if (userId == null) return null;

      final response = await _supabase
          .from('profiles')
          .select('role')
          .eq('id', userId)
          .single();

      final role = response['role'] as String?;
      debugPrint('Found role: $role');

      // Cache the role if found
      if (role != null) {
        await _persistRole(role);
      }

      return role;
    } catch (error) {
      debugPrint('Error getting user role: $error');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      debugPrint('Getting profile for user ID: $userId');
      if (userId == null) return null;

      // First get the base profile
      final baseProfile =
          await _supabase.from('profiles').select().eq('id', userId).single();

      debugPrint('Found base profile: $baseProfile');

      final role = baseProfile['role'] as String;

      // Get role-specific profile
      if (role == 'teacher') {
        final teacherProfile =
            await _supabase.from('teacher_profiles').select('''
              *,
              departments:department_id (
                id,
                name,
                code
              )
            ''').eq('id', userId).single();

        return {
          ...baseProfile,
          ...teacherProfile,
        };
      } else if (role == 'student') {
        final studentProfile =
            await _supabase.from('student_profiles').select('''
              *,
              student_groups:group_id (
                id,
                name,
                academic_year,
                current_year,
                section,
                departments:department_id (
                  id,
                  name,
                  code
                )
              )
            ''').eq('id', userId).single();

        return {
          ...baseProfile,
          ...studentProfile,
        };
      }

      return baseProfile;
    } catch (error) {
      debugPrint('Error getting user profile:');
      debugPrint('- Error type: ${error.runtimeType}');
      debugPrint('- Error message: $error');
      if (error is PostgrestException) {
        debugPrint('- Error code: ${error.code}');
        debugPrint('- Error details: ${error.details}');
      }
      return null;
    }
  }

  Future<void> _persistRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_roleKey, role);
    debugPrint('Persisted role: $role');
  }

  Future<String?> _getPersistedRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }

  Future<void> _clearPersistedRole() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_roleKey);
    debugPrint('Cleared persisted role');
  }

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  User? get currentUser => _supabase.auth.currentUser;

  bool get isAuthenticated => currentUser != null;
}
