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
    print('Parsing StudentGroup JSON: $json'); // Debug log
    return StudentGroup(
      id: json['id'] as String,
      departmentId: json['department_id'] as String,
      academicYear: json['academic_year'] as int,
      currentYear: json['current_year'] as int,
      section: json['section'] as String,
      name: json['name'] as String?,
      department: json['departments'] != null
          ? Department.fromJson({
              'id': json['department_id'], // Use department_id as id
              ...json['departments'] as Map<String, dynamic>
            })
          : null,
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
