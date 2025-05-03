import 'package:flutter/foundation.dart';
import 'department.dart';

@immutable
class StudentGroup {
  final String id;
  final String departmentId;
  final int academicYear;
  final int currentYear;
  final String section;
  final String? name;
  final Department? department;

  const StudentGroup({
    required this.id,
    required this.departmentId,
    required this.academicYear,
    required this.currentYear,
    required this.section,
    this.name,
    this.department,
  });

  factory StudentGroup.fromJson(Map<String, dynamic> json) {
    print('Parsing StudentGroup JSON: $json'); // Input JSON

    final departmentData = json['departments'] as Map<String, dynamic>?;
    print('Department data: $departmentData'); // Department nested data

    final department =
        departmentData != null ? Department.fromJson(departmentData) : null;
    print('Parsed department: ${department?.toJson()}'); // Parsed department

    return StudentGroup(
      id: json['id'] as String,
      departmentId: json['department_id'] as String,
      academicYear: json['academic_year'] as int,
      currentYear: json['current_year'] as int,
      section: json['section'] as String,
      name: json['name'] as String?,
      department: department,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'department_id': departmentId,
      'academic_year': academicYear,
      'current_year': currentYear,
      'section': section,
      'name': name,
    };
  }

  String get displayName {
    final deptCode = department?.code ?? '';
    return '$deptCode - Year $currentYear - Section $section';
  }
}
