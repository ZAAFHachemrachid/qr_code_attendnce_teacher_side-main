import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/timeline_entry.dart';
import '../providers/teacher_timeline_provider.dart';

class TeachingScheduleScreen extends ConsumerWidget {
  const TeachingScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timelineAsync = ref.watch(teacherTimelineProvider);
    final allDays = ref.watch(allDaysProvider);

    return timelineAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _buildScheduleLayout(context, ref, [], allDays),
      data: (entries) => _buildScheduleLayout(context, ref, entries, allDays),
    );
  }

  Widget _buildScheduleLayout(
    BuildContext context,
    WidgetRef ref,
    List<TeacherTimelineEntry> entries,
    List<String> allDays,
  ) {
    final groupedEntries = groupTimelineByDay(entries);
    final days = entries.isEmpty ? allDays : getSortedDays(groupedEntries);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Teaching Schedule',
                style: theme.textTheme.headlineMedium,
              ),
              IconButton(
                icon: Icon(Icons.refresh, color: theme.colorScheme.primary),
                onPressed: () => ref.refresh(teacherTimelineProvider),
              ),
            ],
          ),
          if (entries.isEmpty) ...[
            const SizedBox(height: 8),
            Center(
              child: Text(
                'No schedule available',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      constraints: const BoxConstraints(
                        minWidth: 800,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: theme.colorScheme.outlineVariant,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Table(
                        defaultColumnWidth: const FixedColumnWidth(130),
                        border: TableBorder.all(
                          color: theme.colorScheme.outlineVariant,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        children: [
                          _buildHeaderRow(context, days),
                          ...List.generate(6, (slotIndex) {
                            return _buildTimeSlotRow(
                              slotIndex + 1,
                              days,
                              groupedEntries,
                              context,
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildLegend(context),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  TableRow _buildHeaderRow(BuildContext context, List<String> days) {
    final theme = Theme.of(context);
    return TableRow(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
      ),
      children: [
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              'Time',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        ...days.map(
          (day) => TableCell(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                day,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }

  TableRow _buildTimeSlotRow(
    int slotNumber,
    List<String> days,
    Map<String, List<TeacherTimelineEntry>> groupedEntries,
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    final timeSlots = {
      1: '8:00 - 9:30',
      2: '9:30 - 11:00',
      3: '11:00 - 12:30',
      4: '12:30 - 14:00',
      5: '14:00 - 15:30',
      6: '15:30 - 17:00',
    };

    return TableRow(
      children: [
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              timeSlots[slotNumber] ?? '',
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        ...days.map((day) {
          final entries = groupedEntries[day] ?? [];
          final entry = entries.firstWhere(
            (e) => e.slotNumber == slotNumber,
            orElse: () => TeacherTimelineEntry(
              id: '',
              courseName: '',
              courseCode: '',
              type: '',
              groupName: '',
              dayOfWeek: day,
              startTime: '',
              endTime: '',
              slotNumber: slotNumber,
              room: '',
            ),
          );
          return _buildScheduleCell(entry, context);
        }),
      ],
    );
  }

  Widget _buildScheduleCell(TeacherTimelineEntry entry, BuildContext context) {
    final theme = Theme.of(context);
    if (entry.courseName.isEmpty) {
      return TableCell(
        child: Container(
          padding: const EdgeInsets.all(12.0),
          height: 90,
          child: Center(
            child: Text(
              '-',
              style: TextStyle(color: theme.colorScheme.outline),
            ),
          ),
        ),
      );
    }

    final baseColor = _getTypeColor(entry.type, theme);

    return TableCell(
      child: Card(
        margin: const EdgeInsets.all(6),
        color: baseColor.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8.0,
            vertical: 6.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                entry.courseName,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: baseColor,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                entry.groupName,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                'Room ${entry.room}',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(String type, ThemeData theme) {
    switch (type.toUpperCase()) {
      case 'COURSE':
        return theme.colorScheme.primary;
      case 'TD':
        return theme.colorScheme.tertiary;
      case 'TP':
        return theme.colorScheme.secondary;
      default:
        return theme.colorScheme.outline;
    }
  }

  Widget _buildLegend(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLegendItem('Course', Theme.of(context).colorScheme.primary),
          const SizedBox(width: 24),
          _buildLegendItem('TD', Theme.of(context).colorScheme.tertiary),
          const SizedBox(width: 24),
          _buildLegendItem('TP', Theme.of(context).colorScheme.secondary),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 13),
        ),
      ],
    );
  }
}
