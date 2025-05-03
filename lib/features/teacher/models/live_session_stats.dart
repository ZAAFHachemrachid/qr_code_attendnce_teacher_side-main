import 'package:flutter/foundation.dart';
import 'live_attendance_update.dart';

@immutable
class LiveSessionStats {
  final String sessionId;
  final int totalStudents;
  final int presentStudents;
  final Map<String, int> totalStudentsByGroup;
  final Map<String, int> presentStudentsByGroup;
  final List<LiveAttendanceUpdate> recentCheckins;
  final DateTime lastUpdated;

  const LiveSessionStats({
    required this.sessionId,
    required this.totalStudents,
    required this.presentStudents,
    required this.totalStudentsByGroup,
    required this.presentStudentsByGroup,
    required this.recentCheckins,
    required this.lastUpdated,
  });

  double get attendancePercentage {
    if (totalStudents == 0) return 0.0;
    return (presentStudents / totalStudents) * 100;
  }

  factory LiveSessionStats.fromJson(Map<String, dynamic> json) {
    return LiveSessionStats(
      sessionId: json['session_id'] as String,
      totalStudents: json['total_students'] as int,
      presentStudents: json['present_students'] as int,
      totalStudentsByGroup: Map<String, int>.from(
        json['total_students_by_group'] as Map<String, dynamic>,
      ),
      presentStudentsByGroup: Map<String, int>.from(
        json['present_students_by_group'] as Map<String, dynamic>,
      ),
      recentCheckins: (json['recent_checkins'] as List)
          .map((e) => LiveAttendanceUpdate.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastUpdated: DateTime.parse(json['last_updated'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'total_students': totalStudents,
      'present_students': presentStudents,
      'total_students_by_group': totalStudentsByGroup,
      'present_students_by_group': presentStudentsByGroup,
      'recent_checkins': recentCheckins.map((e) => e.toJson()).toList(),
      'last_updated': lastUpdated.toIso8601String(),
    };
  }

  LiveSessionStats copyWith({
    String? sessionId,
    int? totalStudents,
    int? presentStudents,
    Map<String, int>? totalStudentsByGroup,
    Map<String, int>? presentStudentsByGroup,
    List<LiveAttendanceUpdate>? recentCheckins,
    DateTime? lastUpdated,
  }) {
    return LiveSessionStats(
      sessionId: sessionId ?? this.sessionId,
      totalStudents: totalStudents ?? this.totalStudents,
      presentStudents: presentStudents ?? this.presentStudents,
      totalStudentsByGroup: totalStudentsByGroup ?? this.totalStudentsByGroup,
      presentStudentsByGroup:
          presentStudentsByGroup ?? this.presentStudentsByGroup,
      recentCheckins: recentCheckins ?? this.recentCheckins,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LiveSessionStats &&
        other.sessionId == sessionId &&
        other.totalStudents == totalStudents &&
        other.presentStudents == presentStudents &&
        mapEquals(other.totalStudentsByGroup, totalStudentsByGroup) &&
        mapEquals(other.presentStudentsByGroup, presentStudentsByGroup) &&
        listEquals(other.recentCheckins, recentCheckins) &&
        other.lastUpdated == lastUpdated;
  }

  @override
  int get hashCode {
    return Object.hash(
      sessionId,
      totalStudents,
      presentStudents,
      Object.hashAll(totalStudentsByGroup.entries),
      Object.hashAll(presentStudentsByGroup.entries),
      Object.hashAll(recentCheckins),
      lastUpdated,
    );
  }
}
