import 'package:flutter/material.dart';
import '../models/dummy_course.dart';
import '../models/session_attendance.dart';
import 'attendance_section.dart';

class DummyCourseCard extends StatelessWidget {
  final DummyCourse course;

  const DummyCourseCard({
    super.key,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.amber,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: const BoxDecoration(
                color: Color(0xFFFFF3E0),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.school_outlined,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Example Course',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.orange[800],
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      course.code,
                      style: TextStyle(
                        color: Colors.orange[900],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    course.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    context,
                    Icons.person_outline,
                    (course.groups.first as DummyGroup).professor,
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    context,
                    Icons.schedule,
                    course.schedule,
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    context,
                    Icons.school,
                    '${course.creditHours} Credit Hours',
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    context,
                    Icons.calendar_today,
                    '${course.semester} ${course.yearOfStudy}',
                  ),
                  const Divider(height: 32),
                  const Text(
                    'Attendance History',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AttendanceSection(
                    title: 'Course Sessions',
                    sessions: course.courseAttendance,
                    attendedCount:
                        course.getAttendanceCount(SessionType.course),
                    totalSessions: course.getTotalSessions(SessionType.course),
                    attendancePercentage:
                        course.getAttendancePercentage(SessionType.course),
                  ),
                  const SizedBox(height: 16),
                  AttendanceSection(
                    title: 'TD Sessions',
                    sessions: course.tdAttendance,
                    attendedCount: course.getAttendanceCount(SessionType.td),
                    totalSessions: course.getTotalSessions(SessionType.td),
                    attendancePercentage:
                        course.getAttendancePercentage(SessionType.td),
                  ),
                  const SizedBox(height: 16),
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
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[800],
                ),
          ),
        ),
      ],
    );
  }
}
