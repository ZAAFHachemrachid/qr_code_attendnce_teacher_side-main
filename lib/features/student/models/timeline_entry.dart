import 'package:flutter/foundation.dart';

@immutable
class TimelineEntry {
  final String id;
  final String groupName;
  final String courseName;
  final String courseCode;
  final String type;
  final String teacherName;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final int slotNumber;
  final String room;

  const TimelineEntry({
    required this.id,
    required this.groupName,
    required this.courseName,
    required this.courseCode,
    required this.type,
    required this.teacherName,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.slotNumber,
    required this.room,
  });

  factory TimelineEntry.fromJson(Map<String, dynamic> json) {
    return TimelineEntry(
      id: json['id'] as String,
      groupName: json['group_name'] as String,
      courseName: json['course_name'] as String,
      courseCode: json['course_code'] as String,
      type: json['type_c'] as String,
      teacherName: json['teacher_name'] as String,
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
      'group_name': groupName,
      'course_name': courseName,
      'course_code': courseCode,
      'type_c': type,
      'teacher_name': teacherName,
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

    return other is TimelineEntry &&
        other.id == id &&
        other.groupName == groupName &&
        other.courseName == courseName &&
        other.courseCode == courseCode &&
        other.type == type &&
        other.teacherName == teacherName &&
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
      groupName,
      courseName,
      courseCode,
      type,
      teacherName,
      dayOfWeek,
      startTime,
      endTime,
      slotNumber,
      room,
    );
  }
}
