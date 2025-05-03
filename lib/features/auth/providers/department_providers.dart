import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/department.dart';
import '../models/student_group.dart';
import '../services/department_service.dart';

final departmentServiceProvider = Provider<DepartmentService>((ref) {
  return DepartmentService();
});

final departmentsProvider = FutureProvider<List<Department>>((ref) async {
  final service = ref.read(departmentServiceProvider);
  return service.getDepartments();
});

final selectedDepartmentProvider = StateProvider<Department?>((ref) => null);

final studentGroupsProvider =
    FutureProvider.family<List<StudentGroup>, String?>(
        (ref, departmentId) async {
  final service = ref.read(departmentServiceProvider);
  return service.getStudentGroups(departmentId: departmentId);
});

final selectedGroupProvider = StateProvider<StudentGroup?>((ref) => null);
