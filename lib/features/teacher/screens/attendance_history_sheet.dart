import 'package:flutter/material.dart';
import '../widgets/enhanced_student_card.dart';

class AttendanceHistorySheet extends StatelessWidget {
  final StudentData student;

  const AttendanceHistorySheet({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    // Sample attendance data
    final attendanceHistory = [
      {'date': '2025-05-04', 'status': 'Present', 'session': 'Morning'},
      {'date': '2025-05-03', 'status': 'Present', 'session': 'Morning'},
      {'date': '2025-05-02', 'status': 'Absent', 'session': 'Morning'},
      {'date': '2025-05-01', 'status': 'Present', 'session': 'Morning'},
      {'date': '2025-04-30', 'status': 'Late', 'session': 'Morning'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                child: Text(
                  student.name.substring(0, 1).toUpperCase(),
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Attendance History',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      student.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Last 30 Days Summary',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildSummaryCard(
                context,
                'Present',
                '85%',
                Colors.green,
              ),
              const SizedBox(width: 8),
              _buildSummaryCard(
                context,
                'Absent',
                '10%',
                Colors.red,
              ),
              const SizedBox(width: 8),
              _buildSummaryCard(
                context,
                'Late',
                '5%',
                Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Recent Activity',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: attendanceHistory.length,
              itemBuilder: (context, index) {
                final record = attendanceHistory[index];
                return Card(
                  child: ListTile(
                    leading: Icon(
                      _getStatusIcon(record['status']!),
                      color: _getStatusColor(record['status']!),
                    ),
                    title: Text(record['date']!),
                    subtitle:
                        Text('${record['session']} - ${record['status']}'),
                    trailing: Text(
                      record['status']!,
                      style: TextStyle(
                        color: _getStatusColor(record['status']!),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return Icons.check_circle;
      case 'absent':
        return Icons.cancel;
      case 'late':
        return Icons.access_time;
      default:
        return Icons.help;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return Colors.green;
      case 'absent':
        return Colors.red;
      case 'late':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
