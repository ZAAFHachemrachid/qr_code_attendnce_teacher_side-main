import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/timeline_entry.dart';
import '../services/teacher_service.dart';

final teacherServiceProvider = Provider<TeacherService>((ref) {
  return TeacherService();
});

// Dummy data generator for development and testing
List<TeacherTimelineEntry> _generateDummyTimelineEntries(String teacherId) {
  if (teacherId != 'eafc923b-e4ab-4588-99a5-820138727af0') {
    return [];
  }

  return [
    const TeacherTimelineEntry(
      id: '1',
      courseName: 'Advanced Software Engineering',
      courseCode: 'CSE401',
      type: 'Lecture',
      groupName: 'Group A',
      dayOfWeek: 'Saturday',
      startTime: '09:00',
      endTime: '10:30',
      slotNumber: 1,
      room: 'Room 301',
    ),
    const TeacherTimelineEntry(
      id: '2',
      courseName: 'Advanced Software Engineering',
      courseCode: 'CSE401',
      type: 'Lab',
      groupName: 'Group A',
      dayOfWeek: 'Saturday',
      startTime: '10:45',
      endTime: '12:15',
      slotNumber: 2,
      room: 'Lab 102',
    ),
    const TeacherTimelineEntry(
      id: '3',
      courseName: 'Data Science Fundamentals',
      courseCode: 'DS201',
      type: 'Lecture',
      groupName: 'Group B',
      dayOfWeek: 'Sunday',
      startTime: '13:00',
      endTime: '14:30',
      slotNumber: 4,
      room: 'Room 205',
    ),
    const TeacherTimelineEntry(
      id: '4',
      courseName: 'Machine Learning',
      courseCode: 'CSE405',
      type: 'Tutorial',
      groupName: 'Group C',
      dayOfWeek: 'Monday',
      startTime: '11:00',
      endTime: '12:30',
      slotNumber: 3,
      room: 'Room 401',
    ),
    const TeacherTimelineEntry(
      id: '5',
      courseName: 'Data Science Fundamentals',
      courseCode: 'DS201',
      type: 'Lab',
      groupName: 'Group B',
      dayOfWeek: 'Tuesday',
      startTime: '14:45',
      endTime: '16:15',
      slotNumber: 5,
      room: 'Lab 103',
    ),
    const TeacherTimelineEntry(
      id: '6',
      courseName: 'Machine Learning',
      courseCode: 'CSE405',
      type: 'Lecture',
      groupName: 'Group C',
      dayOfWeek: 'Tuesday',
      startTime: '09:00',
      endTime: '10:30',
      slotNumber: 1,
      room: 'Room 302',
    ),
    const TeacherTimelineEntry(
      id: '7',
      courseName: 'Advanced Software Engineering',
      courseCode: 'CSE401',
      type: 'Tutorial',
      groupName: 'Group A',
      dayOfWeek: 'Wednesday',
      startTime: '13:00',
      endTime: '14:30',
      slotNumber: 4,
      room: 'Room 203',
    ),
  ];
}

final teacherTimelineProvider =
    FutureProvider<List<TeacherTimelineEntry>>((ref) async {
  // For development, return dummy data for specific teacher ID
  const teacherId = 'eafc923b-e4ab-4588-99a5-820138727af0';
  return _generateDummyTimelineEntries(teacherId);
});

final allDaysProvider = Provider<List<String>>((ref) {
  return [
    'Saturday',
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday'
  ];
});

// Helper functions for the timeline view
List<String> getSortedDays(
    Map<String, List<TeacherTimelineEntry>> groupedEntries) {
  final days = groupedEntries.keys.isEmpty
      ? [
          'Saturday',
          'Sunday',
          'Monday',
          'Tuesday',
          'Wednesday',
          'Thursday',
          'Friday'
        ]
      : groupedEntries.keys.toList();

  days.sort((a, b) {
    const orderMap = {
      'Saturday': 0,
      'Sunday': 1,
      'Monday': 2,
      'Tuesday': 3,
      'Wednesday': 4,
      'Thursday': 5,
      'Friday': 6,
    };
    return (orderMap[a] ?? 0).compareTo(orderMap[b] ?? 0);
  });
  return days;
}

Map<String, List<TeacherTimelineEntry>> groupTimelineByDay(
    List<TeacherTimelineEntry> entries) {
  if (entries.isEmpty) {
    return {};
  }

  return entries.fold<Map<String, List<TeacherTimelineEntry>>>(
    {},
    (map, entry) {
      if (!map.containsKey(entry.dayOfWeek)) {
        map[entry.dayOfWeek] = [];
      }
      map[entry.dayOfWeek]!.add(entry);
      return map;
    },
  );
}
