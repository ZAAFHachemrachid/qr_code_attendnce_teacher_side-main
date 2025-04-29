import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/timeline_entry.dart';
import '../providers/student_providers.dart';
import '../student_feature.dart';
import 'session_details_dialog.dart';

class TodayOverviewCard extends ConsumerWidget {
  const TodayOverviewCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timelineAsync = ref.watch(studentTimelineProvider);
    final theme = Theme.of(context);
    final today = _getCurrentDayName();

    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.event_note,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  "Today's Schedule",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  today,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          // Content
          timelineAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, _) => Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Error: $error'),
            ),
            data: (sessions) {
              final todaySessions = sessions
                  .where((session) => session.dayOfWeek == today)
                  .toList()
                ..sort((a, b) => a.startTime.compareTo(b.startTime));

              if (todaySessions.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Center(
                    child: Text('No classes scheduled for today'),
                  ),
                );
              }

              final nextSession = _getNextSession(todaySessions);

              return Column(
                children: [
                  if (nextSession != null)
                    _buildNextSession(context, nextSession),
                  const Divider(),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: todaySessions.length.clamp(0, 3),
                    itemBuilder: (context, index) {
                      final session = todaySessions[index];
                      return _buildSessionItem(context, session);
                    },
                  ),
                  if (todaySessions.length > 3)
                    TextButton(
                      onPressed: () {
                        ref.read(studentCurrentIndexProvider.notifier).state =
                            StudentNavigationItems.timeline;
                      },
                      child: const Text('View all sessions'),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNextSession(BuildContext context, TimelineEntry session) {
    final theme = Theme.of(context);
    final now = TimeOfDay.now();
    final sessionStart = _parseTimeOfDay(session.startTime);
    final minutesUntil = _calculateMinutesBetween(now, sessionStart);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Next Session',
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.courseName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Room ${session.room} • ${session.startTime}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'In $minutesUntil min',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSessionItem(BuildContext context, TimelineEntry session) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
        child: Text(
          session.type[0],
          style: TextStyle(color: theme.colorScheme.primary),
        ),
      ),
      title: Text(
        session.courseName,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text('${session.startTime} - ${session.endTime}'),
      trailing: Text(
        'Room ${session.room}',
        style: theme.textTheme.bodySmall,
      ),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => SessionDetailsDialog(
            session: session,
            baseColor: theme.colorScheme.primary,
          ),
        );
      },
    );
  }

  String _getCurrentDayName() {
    final now = DateTime.now();
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return days[now.weekday - 1];
  }

  TimelineEntry? _getNextSession(List<TimelineEntry> sessions) {
    final now = TimeOfDay.now();
    for (var session in sessions) {
      final sessionTime = _parseTimeOfDay(session.startTime);
      if (_isTimeAfter(sessionTime, now)) {
        return session;
      }
    }
    return null;
  }

  TimeOfDay _parseTimeOfDay(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  bool _isTimeAfter(TimeOfDay time1, TimeOfDay time2) {
    return time1.hour > time2.hour ||
        (time1.hour == time2.hour && time1.minute > time2.minute);
  }

  int _calculateMinutesBetween(TimeOfDay time1, TimeOfDay time2) {
    return (time2.hour * 60 + time2.minute) - (time1.hour * 60 + time1.minute);
  }
}
