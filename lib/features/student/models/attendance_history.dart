import 'package:flutter/material.dart';

class AttendanceRecord {
  final String courseId;
  final String courseName;
  final DateTime date;
  final String status; // 'present', 'absent', 'late'
  final String courseType; // 'TD', 'TP'
  final String? notes;

  const AttendanceRecord({
    required this.courseId,
    required this.courseName,
    required this.date,
    required this.status,
    required this.courseType,
    this.notes,
  });
}

class AttendanceStats {
  final int totalClasses;
  final int presentCount;
  final int absentCount;
  final int lateCount;

  const AttendanceStats({
    required this.totalClasses,
    required this.presentCount,
    required this.absentCount,
    required this.lateCount,
  });

  double get presentPercentage =>
      totalClasses > 0 ? (presentCount / totalClasses) * 100 : 0;
  double get absentPercentage =>
      totalClasses > 0 ? (absentCount / totalClasses) * 100 : 0;
  double get latePercentage =>
      totalClasses > 0 ? (lateCount / totalClasses) * 100 : 0;

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return Colors.green;
      case 'absent':
        return Colors.red;
      case 'late':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}

class AttendanceHistory {
  final List<AttendanceRecord> records;
  final AttendanceStats stats;
  final Map<String, List<AttendanceRecord>> recordsByClass;

  const AttendanceHistory({
    required this.records,
    required this.stats,
    required this.recordsByClass,
  });
}
