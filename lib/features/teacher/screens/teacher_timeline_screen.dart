import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/teacher_timeline_provider.dart';
import '../models/timeline_entry.dart';
import '../../theme/theme_constants.dart';

class TeacherTimelineScreen extends ConsumerWidget {
  const TeacherTimelineScreen({super.key});

  static const List<String> _timeSlots = [
    '08:00 - 09:30',
    '09:30 - 11:00',
    '11:00 - 12:30',
    '12:30 - 14:00',
    '14:00 - 15:30',
    '15:30 - 17:00',
  ];

  static const List<String> _weekDays = [
    'Saturday',
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
  ];

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'lecture':
        return Icons.book;
      case 'lab':
        return Icons.science;
      case 'tutorial':
        return Icons.edit_note;
      default:
        return Icons.event;
    }
  }

  Color _getTypeColor(String type, ColorScheme colorScheme) {
    switch (type.toLowerCase()) {
      case 'lecture':
        return colorScheme.primary;
      case 'lab':
        return colorScheme.tertiary;
      case 'tutorial':
        return colorScheme.secondary;
      default:
        return colorScheme.outline;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timelineAsync = ref.watch(teacherTimelineProvider);
    final theme = Theme.of(context);
    final today = _getCurrentDayName();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teaching Schedule'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: timelineAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) =>
                  _buildScheduleLayout(context, ref, [], _weekDays),
              data: (entries) =>
                  _buildScheduleLayout(context, ref, entries, _weekDays),
            ),
          ),
          _buildLegend(context),
        ],
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildLegendItem(
            context,
            'Lecture',
            theme.colorScheme.primary,
            Icons.book,
          ),
          _buildLegendItem(
            context,
            'Tutorial',
            theme.colorScheme.secondary,
            Icons.edit_note,
          ),
          _buildLegendItem(
            context,
            'Lab',
            theme.colorScheme.tertiary,
            Icons.science,
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(
    BuildContext context,
    String label,
    Color color,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(isDark ? 0.2 : 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withOpacity(isDark ? 0.5 : 0.3),
              width: 1.5,
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleLayout(
    BuildContext context,
    WidgetRef ref,
    List<TeacherTimelineEntry> entries,
    List<String> allDays,
  ) {
    final theme = Theme.of(context);
    final groupedEntries = _groupTimelineByDay(entries);
    final days = entries.isEmpty ? allDays : _getSortedDays(groupedEntries, allDays);
    final today = _getCurrentDayName();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16), // Increased outer margin
                padding: const EdgeInsets.all(8), // Added padding around table
                constraints: const BoxConstraints(
                  minWidth: 1200, // Increased minimum width for better spacing
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.dividerColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Table(
                  defaultColumnWidth: const FixedColumnWidth(180), // Increased column width
                  columnWidths: const {
                    0: FixedColumnWidth(120), // Time column can be slightly narrower
                  },
                  border: TableBorder.all(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  children: [
                    TableRow(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withOpacity(0.3),
                      ),
                      children: [
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              'Time',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        ...days.map((day) => TableCell(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: day == today
                                      ? Border(
                                          bottom: BorderSide(
                                            color: theme.colorScheme.primary,
                                            width: 3,
                                          ),
                                        )
                                      : null,
                                ),
                                child: Text(
                                  day,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: day == today
                                        ? theme.colorScheme.primary
                                        : null,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )),
                      ],
                    ),
                    ...List.generate(6, (slotIndex) {
                      return TableRow(
                        children: [
                          TableCell(
                            child: Container(
                              height: 140, // Increased cell height for better spacing
                              padding: const EdgeInsets.all(16),
                              alignment: Alignment.center,
                              child: Text(
                                _timeSlots[slotIndex],
                                style: theme.textTheme.titleSmall,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          ...days.map((day) {
                            final dayEntries = groupedEntries[day] ?? [];
                            TeacherTimelineEntry? entry;
                            try {
                              entry = dayEntries.firstWhere(
                                (e) =>
                                    e.startTime ==
                                    _timeSlots[slotIndex].split(' - ')[0],
                              );
                            } catch (_) {
                              entry = null;
                            }
                            return _buildScheduleCell(entry, context);
                          }),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleCell(TeacherTimelineEntry? entry, BuildContext context) {
    final theme = Theme.of(context);
    if (entry == null) {
      return const TableCell(
        child: SizedBox(
          height: 140, // Match the time slot height
          child: Center(child: Text('-')),
        ),
      );
    }

    final baseColor = _getTypeColor(entry.type, theme.colorScheme);
    final icon = _getTypeIcon(entry.type);

    return TableCell(
      child: Card(
        margin: const EdgeInsets.all(12), // Increased cell margin
        color: baseColor.withOpacity(0.1),
        child: InkWell(
          onTap: () => _showSessionDetails(context, entry, baseColor),
          child: Container(
            height: 130, // Adjusted card height to match new cell size
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Increased horizontal padding
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 16, color: baseColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        entry.courseName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: baseColor,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  entry.groupName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: baseColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Room ${entry.room}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: baseColor,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSessionDetails(BuildContext context, TeacherTimelineEntry session, Color baseColor) {
    // TODO: Implement session details dialog for teacher
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          session.courseName,
          style: TextStyle(color: baseColor),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${session.type}'),
            Text('Room: ${session.room}'),
            Text('Group: ${session.groupName}'),
            Text('Code: ${session.courseCode}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _getCurrentDayName() {
    final now = DateTime.now();
    // Adjust for week starting on Saturday (where Saturday is 0)
    final dayIndex = (now.weekday + 1) % 7;
    return _weekDays[dayIndex];
  }

  Map<String, List<TeacherTimelineEntry>> _groupTimelineByDay(List<TeacherTimelineEntry> entries) {
    final grouped = <String, List<TeacherTimelineEntry>>{};
    for (var entry in entries) {
      final day = entry.dayOfWeek;
      if (!grouped.containsKey(day)) {
        grouped[day] = [];
      }
      grouped[day]!.add(entry);
    }
    return grouped;
  }

  List<String> _getSortedDays(
      Map<String, List<TeacherTimelineEntry>> groupedEntries, List<String> allDays) {
    final days = groupedEntries.keys.toList();
    days.sort((a, b) {
      final aIndex = allDays.indexOf(a);
      final bIndex = allDays.indexOf(b);
      return aIndex.compareTo(bIndex);
    });
    return days;
  }
}