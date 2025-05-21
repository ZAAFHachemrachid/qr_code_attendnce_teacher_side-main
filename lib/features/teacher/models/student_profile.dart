import 'package:flutter/foundation.dart';

@immutable
class StudentProfile {
  final String id;
  final String firstName;
  final String lastName;
  final String studentNumber;
  final String groupName;
  final String section;
  final int currentYear;
  final double? attendancePercentage;

  const StudentProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.studentNumber,
    required this.groupName,
    required this.section,
    required this.currentYear,
    this.attendancePercentage,
  });

  String get fullName => '$firstName $lastName';

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      id: json['id'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      studentNumber: json['student_number'] as String,
      groupName: json['group_name'] as String,
      section: json['section'] as String,
      currentYear: json['current_year'] as int,
      attendancePercentage: json['attendance_percentage'] as double?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'first_name': firstName,
        'last_name': lastName,
        'student_number': studentNumber,
        'group_name': groupName,
        'section': section,
        'current_year': currentYear,
        'attendance_percentage': attendancePercentage,
      };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StudentProfile && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
