import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/student_providers.dart';
import 'qr_scanner_screen.dart';

class StudentDashboardScreen extends ConsumerWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(studentProfileProvider);
    final attendanceStats = ref.watch(attendanceStatsProvider);
    final attendanceRecords = ref.watch(filteredAttendanceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
      ),
      body: profileAsync.when(
        data: (profile) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(studentProfileProvider);
            ref.invalidate(studentAttendanceProvider);
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${profile.firstName} ${profile.lastName}',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Student Number: ${profile.studentNumber}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 24),
                      _buildAttendanceStats(context, attendanceStats),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Text(
                            'Attendance History',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const Spacer(),
                          FilledButton.icon(
                            onPressed: () => _scanQRCode(context),
                            icon: const Icon(Icons.qr_code_scanner),
                            label: const Text('Scan QR'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final record = attendanceRecords[index];
                    return _buildAttendanceCard(context, record);
                  },
                  childCount: attendanceRecords.length,
                ),
              ),
            ],
          ),
        ),
        error: (error, stackTrace) => Center(
          child: Text('Error: $error'),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildAttendanceStats(
    BuildContext context,
    ({
      int totalSessions,
      int present,
      int absent,
      int late,
      double attendanceRate
    }) stats,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attendance Overview',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn(
                  context,
                  'Total',
                  stats.totalSessions.toString(),
                  Colors.blue,
                ),
                _buildStatColumn(
                  context,
                  'Present',
                  stats.present.toString(),
                  Colors.green,
                ),
                _buildStatColumn(
                  context,
                  'Absent',
                  stats.absent.toString(),
                  Colors.red,
                ),
                _buildStatColumn(
                  context,
                  'Late',
                  stats.late.toString(),
                  Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: stats.attendanceRate / 100,
              backgroundColor: Colors.grey[200],
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              'Attendance Rate: ${stats.attendanceRate.toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(color: color, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildAttendanceCard(BuildContext context, dynamic record) {
    final date = DateFormat('MMM dd, yyyy').format(record.sessionDate);
    final time = '${record.startTime} - ${record.endTime}';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(record.sessionTitle),
        subtitle: Text('$date\n$time'),
        trailing: _buildStatusChip(record.status),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'present':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'absent':
        color = Colors.red;
        icon = Icons.cancel;
        break;
      case 'late':
        color = Colors.orange;
        icon = Icons.watch_later;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
    }

    return Chip(
      avatar: Icon(icon, color: Colors.white, size: 16),
      label: Text(
        status,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: color,
    );
  }

  void _scanQRCode(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const QRScannerScreen(),
      ),
    );
  }
}
