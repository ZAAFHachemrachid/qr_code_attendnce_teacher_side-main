import 'package:flutter/foundation.dart';
import 'session_type.dart';

@immutable
class LiveSession {
  final String id;
  final String courseId;
  final SessionType sessionType;
  final List<String> groupIds;
  final DateTime startTime;
  final DateTime? endTime;
  final String status;
  final String qrCodeData;
  final Map<String, Map<String, bool>> attendanceByGroup;

  const LiveSession({
    required this.id,
    required this.courseId,
    required this.sessionType,
    required this.groupIds,
    required this.startTime,
    this.endTime,
    required this.status,
    required this.qrCodeData,
    this.attendanceByGroup = const {},
  });

  factory LiveSession.fromJson(Map<String, dynamic> json) {
    return LiveSession(
      id: json['id'] as String,
      courseId: json['course_id'] as String,
      sessionType: SessionType.fromString(json['session_type'] as String),
      groupIds: List<String>.from(json['group_ids'] as List),
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: json['end_time'] != null
          ? DateTime.parse(json['end_time'] as String)
          : null,
      status: json['status'] as String,
      qrCodeData: json['qr_code_data'] as String,
      attendanceByGroup: (json['attendance_by_group'] as Map<String, dynamic>?)
              ?.map((groupId, attendance) => MapEntry(
                  groupId,
                  (attendance as Map<String, dynamic>)
                      .map((k, v) => MapEntry(k, v as bool)))) ??
          {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_id': courseId,
      'session_type': sessionType.toJson(),
      'group_ids': groupIds,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'status': status,
      'qr_code_data': qrCodeData,
      'attendance_by_group': attendanceByGroup,
    };
  }

  LiveSession copyWith({
    String? id,
    String? courseId,
    SessionType? sessionType,
    List<String>? groupIds,
    DateTime? startTime,
    DateTime? endTime,
    String? status,
    String? qrCodeData,
    Map<String, Map<String, bool>>? attendanceByGroup,
  }) {
    return LiveSession(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      sessionType: sessionType ?? this.sessionType,
      groupIds: groupIds ?? this.groupIds,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      qrCodeData: qrCodeData ?? this.qrCodeData,
      attendanceByGroup: attendanceByGroup ?? this.attendanceByGroup,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LiveSession &&
        other.id == id &&
        other.courseId == courseId &&
        other.sessionType == sessionType &&
        listEquals(other.groupIds, groupIds) &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.status == status &&
        other.qrCodeData == qrCodeData &&
        mapEquals(other.attendanceByGroup, attendanceByGroup);
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      courseId,
      sessionType,
      Object.hashAll(groupIds),
      startTime,
      endTime,
      status,
      qrCodeData,
      Object.hashAll(attendanceByGroup.entries),
    );
  }
}
