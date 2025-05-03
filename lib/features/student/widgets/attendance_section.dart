import 'package:flutter/material.dart';
import '../../../features/theme/theme_constants.dart';
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.colorScheme.surface,
            AppTheme.colorScheme.surface.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  gradient: _getStatusGradient(attendancePercentage),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$attendedCount/$totalSessions',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${attendancePercentage.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                height: 8,
                width: MediaQuery.of(context).size.width *
                    (attendancePercentage / 100),
                decoration: BoxDecoration(
                  gradient: _getStatusGradient(attendancePercentage),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var session in sessions)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _SessionIndicator(session: session),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  LinearGradient _getStatusGradient(double percentage) {
    if (percentage >= 80) {
      return AppTheme.gradients.successGradient;
    } else if (percentage >= 60) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFA726), Color(0xFFF57C00)],
      );
    } else {
      return AppTheme.gradients.errorGradient;
    }
  }
}

class _SessionIndicator extends StatelessWidget {
  final SessionAttendance session;

  const _SessionIndicator({required this.session});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '${session.topic}\n${session.date.toString().split(' ')[0]}\n'
          'Room: ${session.roomNumber}\n'
          '${session.isPresent ? 'Present' : 'Absent'}',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          gradient: session.isPresent
              ? AppTheme.gradients.successGradient
              : AppTheme.gradients.errorGradient,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: (session.isPresent ? Colors.green : Colors.red)
                  .withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          session.isPresent ? Icons.check_rounded : Icons.close_rounded,
          size: 18,
          color: Colors.white,
        ),
      ),
    );
  }
}
