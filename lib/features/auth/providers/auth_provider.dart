import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;
import '../services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final userProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  if (!authService.isAuthenticated) return null;
  return authService.getUserProfile();
});

final userRoleProvider = FutureProvider<String?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  if (!authService.isAuthenticated) return null;
  return authService.getUserRole();
});

enum AuthStatus {
  authenticated,
  unauthenticated,
  loading,
  error,
}

final authStatusProvider = Provider<AuthStatus>((ref) {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (state) => state.session != null
        ? AuthStatus.authenticated
        : AuthStatus.unauthenticated,
    loading: () => AuthStatus.loading,
    error: (_, __) => AuthStatus.error,
  );
});
