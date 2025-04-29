import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/widgets/role_guard.dart';
import 'features/theme/providers/theme_provider.dart';
import 'screens/role_selection_screen.dart';
import 'features/teacher/teacher_feature.dart';
import 'features/student/student_feature.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  await dotenv.load(fileName: ".env");
  debugPrint('Loaded environment variables');

  final supabaseUrl = dotenv.env['SUPABASE_URL']!;
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY']!;

  debugPrint('Initializing Supabase with URL: $supabaseUrl');

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStatus = ref.watch(authStatusProvider);
    final userRole = ref.watch(userRoleProvider);
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QR Code Attendance',
      themeMode: themeMode,
      theme: ThemeNotifier.lightTheme,
      darkTheme: ThemeNotifier.darkTheme,
      home: authStatus == AuthStatus.loading
          ? const Center(child: CircularProgressIndicator())
          : authStatus == AuthStatus.authenticated
              ? userRole.when(
                  data: (role) {
                    debugPrint('Current user role: $role');
                    if (role == null) return const LoginScreen();

                    // Direct navigation based on role with RoleGuard
                    switch (role) {
                      case 'teacher':
                        return const RoleGuard(
                          requiredRole: 'teacher',
                          child: TeacherFeature(),
                        );
                      case 'student':
                        return const RoleGuard(
                          requiredRole: 'student',
                          child: StudentFeature(),
                        );
                      default:
                        return const RoleSelectionScreen();
                    }
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) {
                    debugPrint('Error loading user role: $error');
                    return const LoginScreen();
                  },
                )
              : const LoginScreen(),
    );
  }
}
