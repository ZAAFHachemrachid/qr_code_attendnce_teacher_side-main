import 'package:flutter/foundation.dart';

enum SessionType {
  course,
  td,
  tp,
}

@immutable
class SessionAttendance {
  final String id;
  final DateTime date;
  final String roomNumber;
  final String topic;
  final bool isPresent;
  final SessionType type;

  const SessionAttendance({
    required this.id,
    required this.date,
    required this.roomNumber,
    required this.topic,
    required this.isPresent,
    required this.type,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SessionAttendance && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
