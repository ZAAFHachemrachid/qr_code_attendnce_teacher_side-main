import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/custom_tab_bar.dart';
import '../../../features/theme/theme_constants.dart';
import '../models/session_attendance.dart';
import '../providers/course_attendance_provider.dart';
import '../widgets/attendance_section.dart';
import '../../teacher/models/course.dart';

class CourseDetailScreen extends ConsumerWidget {
  final ClassInfo course;

  const CourseDetailScreen({
    super.key,
    required this.course,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(course.code),
          centerTitle: true,
          bottom: CustomTabBar(
            tabs: const ['Overview', 'Attendance', 'Sessions'],
            icons: const [
              Icons.info_outline,
              Icons.bar_chart,
              Icons.calendar_today
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOverviewTab(context),
            _buildAttendanceTab(context, ref),
            _buildSessionsTab(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Container(
              padding: const EdgeInsets.all(AppTheme.spacing),
              decoration: BoxDecoration(
                gradient: AppTheme.gradients.primaryGradient,
                borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    course.description,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacing),
          Text(
            'Course Details',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppTheme.spacing),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacing),
              child: Column(
                children: [
                  _buildInfoRow(
                    context,
                    Icons.groups,
                    'Students',
                    course.students.toString(),
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    context,
                    Icons.schedule,
                    'Schedule',
                    course.schedule,
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    context,
                    Icons.book,
                    'Credit Hours',
                    '${course.creditHours} Credits',
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    context,
                    Icons.calendar_today,
                    'Term',
                    '${course.semester} Year ${course.yearOfStudy}',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceTab(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(courseAttendanceStatsProvider(course.id));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Attendance Summary',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppTheme.spacing),
          AttendanceSection(
            title: 'Course Sessions',
            sessions: [], // Will be updated with real data
            attendedCount: stats[SessionType.course]?.attended ?? 0,
            totalSessions: stats[SessionType.course]?.total ?? 0,
            attendancePercentage: stats[SessionType.course]?.percentage ?? 0,
          ),
          const SizedBox(height: AppTheme.spacing),
          AttendanceSection(
            title: 'TD Sessions',
            sessions: [], // Will be updated with real data
            attendedCount: stats[SessionType.td]?.attended ?? 0,
            totalSessions: stats[SessionType.td]?.total ?? 0,
            attendancePercentage: stats[SessionType.td]?.percentage ?? 0,
          ),
          const SizedBox(height: AppTheme.spacing),
          AttendanceSection(
            title: 'TP Sessions',
            sessions: [], // Will be updated with real data
            attendedCount: stats[SessionType.tp]?.attended ?? 0,
            totalSessions: stats[SessionType.tp]?.total ?? 0,
            attendancePercentage: stats[SessionType.tp]?.percentage ?? 0,
          ),
        ],
      ),
    );
  }

  Widget _buildSessionsTab(BuildContext context, WidgetRef ref) {
    final attendanceAsync = ref.watch(courseAttendanceProvider(course.id));

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            color: Theme.of(context).colorScheme.surface,
            child: CustomTabBar(
              tabs: const ['Course', 'TD', 'TP'],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                attendanceAsync.when(
                  data: (sessions) => _buildSessionList(
                    context,
                    sessions
                        .where((s) => s.type == SessionType.course)
                        .toList(),
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                ),
                attendanceAsync.when(
                  data: (sessions) => _buildSessionList(
                    context,
                    sessions.where((s) => s.type == SessionType.td).toList(),
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                ),
                attendanceAsync.when(
                  data: (sessions) => _buildSessionList(
                    context,
                    sessions.where((s) => s.type == SessionType.tp).toList(),
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionList(
      BuildContext context, List<SessionAttendance> sessions) {
    if (sessions.isEmpty) {
      return const Center(
        child: Text('No sessions found'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacing),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              gradient: LinearGradient(
                colors: [
                  session.isPresent
                      ? AppTheme.colorScheme.secondaryContainer
                      : AppTheme.colorScheme.errorContainer,
                  Colors.white,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: session.isPresent
                    ? AppTheme.colorScheme.secondary
                    : AppTheme.colorScheme.error,
                child: Icon(
                  session.isPresent ? Icons.check : Icons.close,
                  color: Colors.white,
                ),
              ),
              title: Text(
                session.topic,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                '${session.date.toString().split(' ')[0]} • Room ${session.roomNumber}',
              ),
              trailing: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: session.isPresent
                      ? AppTheme.colorScheme.secondaryContainer
                      : AppTheme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  session.isPresent ? 'Present' : 'Absent',
                  style: TextStyle(
                    color: session.isPresent
                        ? AppTheme.colorScheme.secondary
                        : AppTheme.colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: AppTheme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
