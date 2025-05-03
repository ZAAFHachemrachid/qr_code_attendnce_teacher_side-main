import 'package:flutter/material.dart';
import '../models/session_attendance.dart';

class AttendanceSection extends StatelessWidget {
  final String title;
  final List<SessionAttendance> sessions;
  final int attendedCount;
  final int totalSessions;
  final double attendancePercentage;

  const AttendanceSection({
    super.key,
    required this.title,
    required this.sessions,
    required this.attendedCount,
    required this.totalSessions,
    required this.attendancePercentage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getStatusColor(attendancePercentage).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getStatusColor(attendancePercentage),
                  width: 1,
                ),
              ),
              child: Text(
                '$attendedCount/$totalSessions sessions',
                style: TextStyle(
                  color: _getStatusColor(attendancePercentage),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: attendancePercentage / 100,
            backgroundColor: Colors.grey[200],
            color: _getStatusColor(attendancePercentage),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (var session in sessions) _buildSessionIndicator(session),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSessionIndicator(SessionAttendance session) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Tooltip(
        message: '${session.topic}\n${session.date.toString().split(' ')[0]}\n'
            'Room: ${session.roomNumber}\n'
            '${session.isPresent ? 'Present' : 'Absent'}',
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: session.isPresent ? Colors.green[100] : Colors.red[100],
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: session.isPresent ? Colors.green : Colors.red,
              width: 1,
            ),
          ),
          child: Icon(
            session.isPresent ? Icons.check : Icons.close,
            size: 16,
            color: session.isPresent ? Colors.green : Colors.red,
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(double percentage) {
    if (percentage >= 80) {
      return Colors.green;
    } else if (percentage >= 60) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
