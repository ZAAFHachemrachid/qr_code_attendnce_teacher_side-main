import 'package:flutter/foundation.dart';

@immutable
class StudentProfile {
  final String id;
  final String studentNumber;
  final String groupId;
  final String firstName;
  final String lastName;

  const StudentProfile({
    required this.id,
    required this.studentNumber,
    required this.groupId,
    required this.firstName,
    required this.lastName,
  });

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      id: json['id'] as String,
      studentNumber: json['student_number'] as String,
      groupId: json['group_id'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_number': studentNumber,
      'group_id': groupId,
      'first_name': firstName,
      'last_name': lastName,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is StudentProfile &&
        other.id == id &&
        other.studentNumber == studentNumber &&
        other.groupId == groupId &&
        other.firstName == firstName &&
        other.lastName == lastName;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      studentNumber,
      groupId,
      firstName,
      lastName,
    );
  }

  StudentProfile copyWith({
    String? id,
    String? studentNumber,
    String? groupId,
    String? firstName,
    String? lastName,
  }) {
    return StudentProfile(
      id: id ?? this.id,
      studentNumber: studentNumber ?? this.studentNumber,
      groupId: groupId ?? this.groupId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
    );
  }
}
