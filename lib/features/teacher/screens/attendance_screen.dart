import 'package:flutter/material.dart';
import '../models.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<AttendanceRecord> records = [
      const AttendanceRecord(
        studentId: '1',
        studentName: 'John Doe',
        status: 'present',
        checkInTime: '09:00 AM',
      ),
      const AttendanceRecord(
        studentId: '2',
        studentName: 'Jane Smith',
        status: 'absent',
        checkInTime: '-',
      ),
      const AttendanceRecord(
        studentId: '3',
        studentName: 'Bob Johnson',
        status: 'present',
        checkInTime: '09:05 AM',
      ),
      const AttendanceRecord(
        studentId: '4',
        studentName: 'Alice Brown',
        status: 'late',
        checkInTime: '09:15 AM',
      ),
    ];

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Attendance'),
          backgroundColor: const Color(0xFF6AB19B),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Today'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAttendanceList(records),
            _buildAttendanceHistory(),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            // TODO: Implement QR code scanning
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('QR code scanning coming soon'),
              ),
            );
          },
          icon: const Icon(Icons.qr_code_scanner),
          label: const Text('Scan QR'),
          backgroundColor: const Color(0xFF6AB19B),
        ),
      ),
    );
  }

  Widget _buildAttendanceList(List<AttendanceRecord> records) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(record.status),
              child: Icon(
                _getStatusIcon(record.status),
                color: Colors.white,
              ),
            ),
            title: Text(record.studentName),
            subtitle: Text('Check-in: ${record.checkInTime}'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: _getStatusColor(record.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getStatusColor(record.status),
                ),
              ),
              child: Text(
                record.status.toUpperCase(),
                style: TextStyle(
                  color: _getStatusColor(record.status),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAttendanceHistory() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Attendance History',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coming Soon',
            style: TextStyle(
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
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

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return Icons.check;
      case 'absent':
        return Icons.close;
      case 'late':
        return Icons.access_time;
      default:
        return Icons.help_outline;
    }
  }
}
