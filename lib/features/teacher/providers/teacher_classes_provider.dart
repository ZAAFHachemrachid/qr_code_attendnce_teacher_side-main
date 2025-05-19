import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/teacher_class.dart';
import '../services/teacher_classes_service.dart';

final teacherClassesServiceProvider = Provider<TeacherClassesService>((ref) {
  return TeacherClassesService(Supabase.instance.client);
});

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

  TeacherClassesNotifier(this._service) : super(const AsyncValue.loading());

  Future<void> loadClasses(String teacherId, String academicPeriod) async {
    if (_currentTeacherId == teacherId &&
        _currentAcademicPeriod == academicPeriod) {
      return; // Avoid unnecessary reloads
    }

    state = const AsyncValue.loading();
    try {
      _currentTeacherId = teacherId;
      _currentAcademicPeriod = academicPeriod;

      final classes =
          await _service.getTeacherCourses(teacherId, academicPeriod);
      state = AsyncValue.data(
          classes.map((c) => TeacherClass.fromClassInfo(c)).toList());
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refreshClasses() async {
    if (_currentTeacherId == null || _currentAcademicPeriod == null) {
      return;
    }
    await loadClasses(_currentTeacherId!, _currentAcademicPeriod!);
  }

  Future<void> addClass(TeacherClass newClass) async {
    try {
      final currentClasses = state.value ?? [];
      state = AsyncValue.data([...currentClasses, newClass]);

      final createdClass = await _service.createClass(newClass);
      state = AsyncValue.data(
          [...currentClasses.where((c) => c.id != newClass.id), createdClass]);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      refreshClasses(); // Reload to ensure consistency
    }
  }

  Future<void> updateClass(TeacherClass updatedClass) async {
    try {
      final currentClasses = state.value ?? [];
      state = AsyncValue.data([
        ...currentClasses.map((c) => c.id == updatedClass.id ? updatedClass : c)
      ]);

      await _service.updateClass(updatedClass);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      refreshClasses(); // Reload to ensure consistency
    }
  }

  Future<void> deleteClass(String classId) async {
    try {
      final currentClasses = state.value ?? [];
      state =
          AsyncValue.data([...currentClasses.where((c) => c.id != classId)]);

      await _service.deleteClass(classId);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      refreshClasses(); // Reload to ensure consistency
    }
  }

  Future<TeacherClass?> getClassById(String classId) async {
    try {
      return await _service.getClassById(classId);
    } catch (error) {
      return null;
    }
  }

  void clearClasses() {
    state = const AsyncValue.data([]);
    _currentTeacherId = null;
    _currentAcademicPeriod = null;
  }
}
