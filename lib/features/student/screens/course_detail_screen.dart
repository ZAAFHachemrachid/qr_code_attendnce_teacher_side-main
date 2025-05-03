import 'package:flutter/material.dart';
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
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Attendance'),
              Tab(text: 'Sessions'),
            ],
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Introduction',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    course.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    course.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Course Details',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    context,
                    Icons.person,
                    'Professor',
                    (course.groups.first as DummyGroup).professor,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    context,
                    Icons.schedule,
                    'Schedule',
                    course.schedule,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    context,
                    Icons.meeting_room,
                    'Room',
                    _roomNumber,
                  ),
                  const SizedBox(height: 12),
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Attendance Summary',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 24),
                  AttendanceSection(
                    title: 'Course Sessions',
                    sessions: course.courseAttendance,
                    attendedCount:
                        course.getAttendanceCount(SessionType.course),
                    totalSessions: course.getTotalSessions(SessionType.course),
                    attendancePercentage:
                        course.getAttendancePercentage(SessionType.course),
                  ),
                  const SizedBox(height: 24),
                  AttendanceSection(
                    title: 'TD Sessions',
                    sessions: course.tdAttendance,
                    attendedCount: course.getAttendanceCount(SessionType.td),
                    totalSessions: course.getTotalSessions(SessionType.td),
                    attendancePercentage:
                        course.getAttendancePercentage(SessionType.td),
                  ),
                  const SizedBox(height: 24),
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
            ),
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
          const TabBar(
            tabs: [
              Tab(text: 'Course'),
              Tab(text: 'TD'),
              Tab(text: 'TP'),
            ],
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
      padding: const EdgeInsets.all(16),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  session.isPresent ? Colors.green[100] : Colors.red[100],
              child: Icon(
                session.isPresent ? Icons.check : Icons.close,
                color: session.isPresent ? Colors.green : Colors.red,
              ),
            ),
            title: Text(session.topic),
            subtitle: Text(
              '${session.date.toString().split(' ')[0]} • Room ${session.roomNumber}',
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: session.isPresent ? Colors.green[50] : Colors.red[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                session.isPresent ? 'Present' : 'Absent',
                style: TextStyle(
                  color:
                      session.isPresent ? Colors.green[700] : Colors.red[700],
                  fontWeight: FontWeight.bold,
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
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
