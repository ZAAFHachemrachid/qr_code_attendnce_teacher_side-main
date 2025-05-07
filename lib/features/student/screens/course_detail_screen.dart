import 'package:flutter/material.dart';
import '../../../core/widgets/custom_tab_bar.dart';
import '../../../features/theme/theme_constants.dart';
import '../models/dummy_course.dart';
import '../models/session_attendance.dart';
import '../widgets/attendance_section.dart';

class CourseDetailScreen extends StatelessWidget {
  final DummyCourse course;

  const CourseDetailScreen({
    super.key,
    required this.course,
  });

  String get _roomNumber {
    if (course.courseAttendance.isNotEmpty) {
      return course.courseAttendance.first.roomNumber;
    }
    return 'Not assigned';
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(course.code),
          centerTitle: true,
          bottom: CustomTabBar(
            tabs: const ['Overview', 'Attendance', 'Sessions'],
            icons: const [Icons.info_outline, Icons.bar_chart, Icons.calendar_today],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOverviewTab(context),
            _buildAttendanceTab(context),
            _buildSessionsTab(context),
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
                    Icons.person,
                    'Professor',
                    (course.groups.first as DummyGroup).professor,
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
                    Icons.meeting_room,
                    'Room',
                    _roomNumber,
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    context,
                    Icons.calendar_today,
                    'Term',
                    '${course.semester} ${course.yearOfStudy}',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceTab(BuildContext context) {
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
            sessions: course.courseAttendance,
            attendedCount: course.getAttendanceCount(SessionType.course),
            totalSessions: course.getTotalSessions(SessionType.course),
            attendancePercentage:
                course.getAttendancePercentage(SessionType.course),
          ),
          const SizedBox(height: AppTheme.spacing),
          AttendanceSection(
            title: 'TD Sessions',
            sessions: course.tdAttendance,
            attendedCount: course.getAttendanceCount(SessionType.td),
            totalSessions: course.getTotalSessions(SessionType.td),
            attendancePercentage:
                course.getAttendancePercentage(SessionType.td),
          ),
          const SizedBox(height: AppTheme.spacing),
          AttendanceSection(
            title: 'TP Sessions',
            sessions: course.tpAttendance,
            attendedCount: course.getAttendanceCount(SessionType.tp),
            totalSessions: course.getTotalSessions(SessionType.tp),
            attendancePercentage:
                course.getAttendancePercentage(SessionType.tp),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionsTab(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            color: Theme.of(context).colorScheme.surface,
            child: const CustomTabBar(
              tabs: ['Course', 'TD', 'TP'],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildSessionList(context, course.courseAttendance),
                _buildSessionList(context, course.tdAttendance),
                _buildSessionList(context, course.tpAttendance),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionList(
      BuildContext context, List<SessionAttendance> sessions) {
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
      BuildContext context, IconData icon, String label, String value) {
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
