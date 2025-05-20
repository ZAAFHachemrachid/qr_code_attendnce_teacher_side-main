import 'session_type.dart';

enum ClassType {
  course,
  td,
  tp;

  String toLabel() {
    switch (this) {
      case ClassType.course:
        return 'CM';
      case ClassType.td:
        return 'TD';
      case ClassType.tp:
        return 'TP';
    }
  }

  String toJson() => toLabel();

  static ClassType fromSessionType(SessionType sessionType) {
    switch (sessionType) {
      case SessionType.course:
        return ClassType.course;
      case SessionType.td:
        return ClassType.td;
      case SessionType.tp:
        return ClassType.tp;
    }
  }

  static ClassType fromString(String value) {
    return switch (value.toUpperCase()) {
      'CM' => ClassType.course,
      'TD' => ClassType.td,
      'TP' => ClassType.tp,
      _ => ClassType.course,
    };
  }
}
