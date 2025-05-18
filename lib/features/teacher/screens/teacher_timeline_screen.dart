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

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 1600,
                  minHeight: 0,
                  minWidth: 0,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Table(
                          defaultColumnWidth: const FixedColumnWidth(240),
                          columnWidths: const {
                            0: FixedColumnWidth(180),
                          },
                          border: TableBorder.symmetric(
                            inside: BorderSide(color: theme.dividerColor.withOpacity(0.18), width: 0.7),
                            outside: BorderSide(color: theme.dividerColor, width: 1.2),
                          ),
                          children: [
                            TableRow(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    theme.colorScheme.primary.withOpacity(0.09),
                                    theme.colorScheme.surfaceContainerHighest.withOpacity(0.18),
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(18),
                                  topRight: Radius.circular(18),
                                ),
                              ),
                              children: [
                                TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.all(
                                      MediaQuery.of(context).size.width < 768 ? 10 : 20
                                    ),
                                    child: Text(
                                      'Time',
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.w900,
                                        fontSize: MediaQuery.of(context).size.width < 768 ? 15 : 18,
                                        letterSpacing: 0.5,
                                        color: theme.colorScheme.primary,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                ...days.map((day) => TableCell(
                                      child: Container(
                                        padding: EdgeInsets.all(
                                          MediaQuery.of(context).size.width < 768 ? 10 : 20
                                        ),
                                        decoration: BoxDecoration(
                                          color: day == today
                                              ? theme.colorScheme.primary.withOpacity(0.08)
                                              : Colors.transparent,
                                          border: day == today
                                              ? Border(
                                                  bottom: BorderSide(
                                                    color: theme.colorScheme.primary,
                                                    width: 3,
                                                  ),
                                                )
                                              : null,
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            if (day == today)
                                              Icon(Icons.today, color: theme.colorScheme.primary, size: 18),
                                            if (day == today) const SizedBox(width: 4),
                                            Text(
                                              day,
                                              style: theme.textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                fontSize: MediaQuery.of(context).size.width < 768 ? 14 : 16,
                                                color: day == today
                                                    ? theme.colorScheme.primary
                                                    : theme.textTheme.titleMedium?.color,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                    )),
                              ],
                            ),
                            ...List.generate(6, (slotIndex) {
                              return TableRow(
                                decoration: BoxDecoration(
                                  color: slotIndex.isEven
                                      ? theme.colorScheme.surface.withOpacity(0.97)
                                      : theme.colorScheme.surfaceContainerHighest.withOpacity(0.93),
                                ),
                                children: [
                                  TableCell(
                                    child: Container(
                                      padding: EdgeInsets.all(
                                        MediaQuery.of(context).size.width < 768 ? 8 : 16
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        _timeSlots[slotIndex],
                                        style: theme.textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          fontSize: MediaQuery.of(context).size.width < 768 ? 12 : 14,
                                          color: theme.colorScheme.primary.withOpacity(0.85),
                                        ),
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
                      );
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScheduleCell(TeacherTimelineEntry? entry, BuildContext context) {
    final theme = Theme.of(context);
    const double cellHeight = 220.0; // Increased cell height
    const double cellPadding = 12.0; // Increased padding

    if (entry == null) {
      return TableCell(
        verticalAlignment: TableCellVerticalAlignment.fill,
        child: Container(
          height: cellHeight,
          padding: const EdgeInsets.all(cellPadding),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
          ),
          child: const Text('-'),
        ),
      );
    }

    final baseColor = _getTypeColor(entry.type, theme.colorScheme);
    final icon = _getTypeIcon(entry.type);

    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.fill,
      child: Card(
        margin: const EdgeInsets.all(4),
        color: baseColor.withOpacity(0.1),
        child: InkWell(
          onTap: () => _showSessionDetails(context, entry, baseColor),
          child: Container(
            height: cellHeight,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 215),
                    child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 16, color: baseColor),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          entry.courseName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: baseColor,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 215),
                  child: Text(
                    entry.groupName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: 215,
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 120),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: baseColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: baseColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'Room ${entry.room}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: baseColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                ],
              ),
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
    // Always return all days to ensure complete week display
    return List.from(allDays);
  }
}