import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/teacher_class.dart';
import '../services/teacher_classes_service.dart';
import '../providers/academic_period_provider.dart';

// Provider for teacher classes service
final teacherClassesServiceProvider = Provider<TeacherClassesService>((ref) {
  return TeacherClassesService(Supabase.instance.client);
});

// Provider for teacher classes state
final teacherClassesProvider = StateNotifierProvider<TeacherClassesNotifier,
    AsyncValue<List<TeacherClass>>>((ref) {
  final service = ref.watch(teacherClassesServiceProvider);
  return TeacherClassesNotifier(service);
});

class TeacherClassesNotifier
    extends StateNotifier<AsyncValue<List<TeacherClass>>> {
  final TeacherClassesService _service;
  String? _currentTeacherId;
  String? _currentAcademicPeriod;

  TeacherClassesNotifier(this._service) : super(const AsyncValue.data([]));

  Future<void> loadClasses(String teacherId, String academicPeriod) async {
    if (teacherId.isEmpty) {
      state = AsyncValue.error('Teacher ID is required', StackTrace.current);
      return;
    }
    if (academicPeriod.isEmpty) {
      state =
          AsyncValue.error('Academic period is required', StackTrace.current);
      return;
    }

    state = const AsyncValue.loading();

    try {
      _currentTeacherId = teacherId;
      _currentAcademicPeriod = academicPeriod;

      final classes =
          await _service.getTeacherCourses(teacherId, academicPeriod);

      if (!mounted) return;

      state = AsyncValue.data(
          classes.map((c) => TeacherClass.fromClassInfo(c)).toList());
    } catch (error, stackTrace) {
      if (!mounted) return;

      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refreshClasses() async {
    if (_currentTeacherId == null || _currentAcademicPeriod == null) {
      return;
    }
    await loadClasses(_currentTeacherId!, _currentAcademicPeriod!);
  }

  void clearClasses() {
    state = const AsyncValue.data([]);
    _currentTeacherId = null;
    _currentAcademicPeriod = null;
  }
}

// Initialization provider that handles auto-loading
final classesInitializerProvider = Provider<void>((ref) {
  ref.listen<AuthStatus>(authStatusProvider, (previous, next) {
    if (next == AuthStatus.authenticated) {
      final authState = ref.read(authStateProvider).value;
      final currentPeriod = ref.read(currentAcademicPeriodProvider);
      final userId = authState?.session?.user.id;

      if (userId != null && currentPeriod != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref
              .read(teacherClassesProvider.notifier)
              .loadClasses(userId, currentPeriod);
        });
      }
    }
  });
  return;
});
