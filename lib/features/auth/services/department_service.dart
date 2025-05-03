import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/department.dart';
import '../models/student_group.dart';

class DepartmentService {
  final SupabaseClient _client;

  DepartmentService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  Future<List<Department>> getDepartments() async {
    final response = await _client.from('departments').select().order('code');

    return (response as List).map((json) => Department.fromJson(json)).toList();
  }

  Future<List<StudentGroup>> getStudentGroups({String? departmentId}) async {
    var query = _client.from('student_groups').select('''
          *,
          departments:department_id (
            id,
            name,
            code
          )
        ''');

    if (departmentId != null) {
      query = query.filter('department_id', 'eq', departmentId);
    }

    final response = await query.order('current_year').order('section');

    return (response as List)
        .map((json) => StudentGroup.fromJson(json))
        .toList();
  }
}
