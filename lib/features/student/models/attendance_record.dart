import 'package:flutter/foundation.dart';

@immutable
class AttendanceRecord {
  final String id;
  final String sessionId;
  final String studentId;
  final String status;
  final DateTime checkInTime;
  final String? notes;
  final DateTime createdAt;
  final String sessionTitle;
  final DateTime sessionDate;
  final String startTime;
  final String endTime;
  final String room;

  const AttendanceRecord({
    required this.id,
    required this.sessionId,
    required this.studentId,
    required this.status,
    required this.checkInTime,
    this.notes,
    required this.createdAt,
    required this.sessionTitle,
    required this.sessionDate,
    required this.startTime,
    required this.endTime,
    required this.room,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'] as String,
      sessionId: json['session_id'] as String,
      studentId: json['student_id'] as String,
      status: json['status'] as String,
      checkInTime: DateTime.parse(json['check_in_time'] as String),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      sessionTitle: json['session_title'] as String,
      sessionDate: DateTime.parse(json['session_date'] as String),
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      room: json['room'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'session_id': sessionId,
      'student_id': studentId,
      'status': status,
      'check_in_time': checkInTime.toIso8601String(),
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'session_title': sessionTitle,
      'session_date': sessionDate.toIso8601String(),
      'start_time': startTime,
      'end_time': endTime,
      'room': room,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AttendanceRecord &&
        other.id == id &&
        other.sessionId == sessionId &&
        other.studentId == studentId &&
        other.status == status &&
        other.checkInTime == checkInTime &&
        other.notes == notes &&
        other.createdAt == createdAt &&
        other.sessionTitle == sessionTitle &&
        other.sessionDate == sessionDate &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.room == room;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      sessionId,
      studentId,
      status,
      checkInTime,
      notes,
      createdAt,
      sessionTitle,
      sessionDate,
      startTime,
      endTime,
      room,
    );
  }

  AttendanceRecord copyWith({
    String? id,
    String? sessionId,
    String? studentId,
    String? status,
    DateTime? checkInTime,
    String? notes,
    DateTime? createdAt,
    String? sessionTitle,
    DateTime? sessionDate,
    String? startTime,
    String? endTime,
    String? room,
  }) {
    return AttendanceRecord(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      studentId: studentId ?? this.studentId,
      status: status ?? this.status,
      checkInTime: checkInTime ?? this.checkInTime,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      sessionTitle: sessionTitle ?? this.sessionTitle,
      sessionDate: sessionDate ?? this.sessionDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      room: room ?? this.room,
    );
  }
}
