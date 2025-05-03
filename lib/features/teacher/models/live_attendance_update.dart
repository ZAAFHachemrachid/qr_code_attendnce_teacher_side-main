import 'package:flutter/foundation.dart';

@immutable
class GeoLocation {
  final double latitude;
  final double longitude;

  const GeoLocation({
    required this.latitude,
    required this.longitude,
  });

  factory GeoLocation.fromJson(Map<String, dynamic> json) {
    return GeoLocation(
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GeoLocation &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode => Object.hash(latitude, longitude);
}

@immutable
class LiveAttendanceUpdate {
  final String sessionId;
  final String studentId;
  final DateTime timestamp;
  final String status;
  final GeoLocation? checkInLocation;
  final String studentName; // Added for display purposes

  const LiveAttendanceUpdate({
    required this.sessionId,
    required this.studentId,
    required this.timestamp,
    required this.status,
    this.checkInLocation,
    required this.studentName,
  });

  factory LiveAttendanceUpdate.fromJson(Map<String, dynamic> json) {
    return LiveAttendanceUpdate(
      sessionId: json['session_id'] as String,
      studentId: json['student_id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: json['status'] as String,
      checkInLocation: json['check_in_location'] != null
          ? GeoLocation.fromJson(
              json['check_in_location'] as Map<String, dynamic>)
          : null,
      studentName: json['student_name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'student_id': studentId,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
      'check_in_location': checkInLocation?.toJson(),
      'student_name': studentName,
    };
  }

  LiveAttendanceUpdate copyWith({
    String? sessionId,
    String? studentId,
    DateTime? timestamp,
    String? status,
    GeoLocation? checkInLocation,
    String? studentName,
  }) {
    return LiveAttendanceUpdate(
      sessionId: sessionId ?? this.sessionId,
      studentId: studentId ?? this.studentId,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      checkInLocation: checkInLocation ?? this.checkInLocation,
      studentName: studentName ?? this.studentName,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LiveAttendanceUpdate &&
        other.sessionId == sessionId &&
        other.studentId == studentId &&
        other.timestamp == timestamp &&
        other.status == status &&
        other.checkInLocation == checkInLocation &&
        other.studentName == studentName;
  }

  @override
  int get hashCode {
    return Object.hash(
      sessionId,
      studentId,
      timestamp,
      status,
      checkInLocation,
      studentName,
    );
  }
}
