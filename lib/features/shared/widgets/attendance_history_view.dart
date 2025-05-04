import 'package:flutter/material.dart';
import '../../student/models/attendance_history.dart';
import 'package:fl_chart/fl_chart.dart';
import 'date_range_filter.dart';

class AttendanceHistoryView extends StatelessWidget {
  final AttendanceHistory history;
  final bool isCompact;
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(DateTime?, DateTime?)? onDateRangeChanged;

  const AttendanceHistoryView({
    super.key,
    required this.history,
    this.isCompact = false,
    this.startDate,
    this.endDate,
    this.onDateRangeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isCompact && onDateRangeChanged != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: DateRangeFilter(
              startDate: startDate,
              endDate: endDate,
              onDateRangeChanged: onDateRangeChanged!,
            ),
          ),
        _buildStatistics(context),
        if (!isCompact) ...[
          const SizedBox(height: 24),
          _buildTimeline(context),
          const SizedBox(height: 24),
          _buildDetailedRecords(context),
        ],
      ],
    );
  }

  Widget _buildStatistics(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attendance Overview',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: history.stats.presentPercentage,
                      color: Colors.green,
                      title:
                          '${history.stats.presentPercentage.toStringAsFixed(1)}%',
                      radius: 60,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    PieChartSectionData(
                      value: history.stats.absentPercentage,
                      color: Colors.red,
                      title:
                          '${history.stats.absentPercentage.toStringAsFixed(1)}%',
                      radius: 60,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    PieChartSectionData(
                      value: history.stats.latePercentage,
                      color: Colors.orange,
                      title:
                          '${history.stats.latePercentage.toStringAsFixed(1)}%',
                      radius: 60,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem(
                  context,
                  label: 'Present',
                  value: history.stats.presentCount,
                  color: Colors.green,
                ),
                _buildLegendItem(
                  context,
                  label: 'Absent',
                  value: history.stats.absentCount,
                  color: Colors.red,
                ),
                _buildLegendItem(
                  context,
                  label: 'Late',
                  value: history.stats.lateCount,
                  color: Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(
    BuildContext context, {
    required String label,
    required int value,
    required Color color,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(label),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }

  Widget _buildTimeline(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: history.records.take(5).length,
              itemBuilder: (context, index) {
                final record = history.records[index];
                return Card(
                  child: ListTile(
                    leading: Icon(
                      record.status == 'present'
                          ? Icons.check_circle
                          : record.status == 'absent'
                              ? Icons.cancel
                              : Icons.warning,
                      color: history.stats.getStatusColor(record.status),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(record.courseName),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            record.courseType,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      '${record.date.day}/${record.date.month}/${record.date.year}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          record.status.toUpperCase(),
                          style: TextStyle(
                            color: history.stats.getStatusColor(record.status),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedRecords(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attendance by Course',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...history.recordsByClass.entries.map((entry) {
              final courseRecords = entry.value;
              final presentCount =
                  courseRecords.where((r) => r.status == 'present').length;
              final totalCount = courseRecords.length;
              final attendanceRate = (presentCount / totalCount) * 100;

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(courseRecords.first.courseName),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          courseRecords.first.courseType,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: attendanceRate / 100,
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          attendanceRate >= 75
                              ? Colors.green
                              : attendanceRate >= 60
                                  ? Colors.orange
                                  : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${attendanceRate.toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
