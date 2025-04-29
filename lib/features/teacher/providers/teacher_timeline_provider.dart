import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/timeline_entry.dart';
import '../services/teacher_service.dart';

final teacherServiceProvider = Provider<TeacherService>((ref) {
  return TeacherService();
});

final teacherTimelineProvider =
    FutureProvider<List<TeacherTimelineEntry>>((ref) async {
  final teacherService = ref.watch(teacherServiceProvider);
  return await teacherService.getWeeklySchedule();
});

final allDaysProvider = Provider<List<String>>((ref) {
  return [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
});

// Helper functions for the timeline view
List<String> getSortedDays(
    Map<String, List<TeacherTimelineEntry>> groupedEntries) {
  final days = groupedEntries.keys.isEmpty
      ? [
          'Monday',
          'Tuesday',
          'Wednesday',
          'Thursday',
          'Friday',
          'Saturday',
          'Sunday'
        ]
      : groupedEntries.keys.toList();

  days.sort((a, b) {
    const orderMap = {
      'Monday': 1,
      'Tuesday': 2,
      'Wednesday': 3,
      'Thursday': 4,
      'Friday': 5,
      'Saturday': 6,
      'Sunday': 7,
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
