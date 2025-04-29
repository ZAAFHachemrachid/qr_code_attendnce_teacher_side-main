import 'package:flutter/foundation.dart';

@immutable
class TeacherTimelineEntry {
  final String id;
  final String courseName;
  final String courseCode;
  final String type;
  final String groupName;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final int slotNumber;
  final String room;

  const TeacherTimelineEntry({
    required this.id,
    required this.courseName,
    required this.courseCode,
    required this.type,
    required this.groupName,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.slotNumber,
    required this.room,
  });

  factory TeacherTimelineEntry.fromJson(Map<String, dynamic> json) {
    return TeacherTimelineEntry(
      id: json['id'] as String,
      courseName: json['course_name'] as String,
      courseCode: json['course_code'] as String,
      type: json['type_c'] as String,
      groupName: json['group_name'] as String,
      dayOfWeek: json['day_of_week'] as String,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      slotNumber: json['slot_number'] as int,
      room: json['room'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_name': courseName,
      'course_code': courseCode,
      'type_c': type,
      'group_name': groupName,
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
      'slot_number': slotNumber,
      'room': room,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TeacherTimelineEntry &&
        other.id == id &&
        other.courseName == courseName &&
        other.courseCode == courseCode &&
        other.type == type &&
        other.groupName == groupName &&
        other.dayOfWeek == dayOfWeek &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.slotNumber == slotNumber &&
        other.room == room;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      courseName,
      courseCode,
      type,
      groupName,
      dayOfWeek,
      startTime,
      endTime,
      slotNumber,
      room,
    );
  }
}
