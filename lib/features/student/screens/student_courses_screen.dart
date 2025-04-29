import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/student_providers.dart';

class StudentCoursesScreen extends ConsumerWidget {
  const StudentCoursesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceRecords = ref.watch(filteredAttendanceProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Group attendance records by course
    final courseAttendance = <String, List<dynamic>>{};
    for (var record in attendanceRecords) {
      final courseTitle = record.sessionTitle.split(' - ')[0];
      courseAttendance.putIfAbsent(courseTitle, () => []).add(record);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Courses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(studentAttendanceProvider),
          ),
        ],
      ),
      body: courseAttendance.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 64,
                    color: theme.colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No courses found',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () => ref.refresh(studentAttendanceProvider.future),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: courseAttendance.length,
                itemBuilder: (context, index) {
                  final courseTitle = courseAttendance.keys.elementAt(index);
                  final records = courseAttendance[courseTitle]!;
                  final totalSessions = records.length;
                  final presentSessions =
                      records.where((r) => r.status == 'present').length;
                  final attendanceRate = totalSessions > 0
                      ? (presentSessions / totalSessions * 100)
                      : 0.0;

                  return _AnimatedCard(
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        onTap: () =>
                            _showCourseDetails(context, courseTitle, records),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                theme.colorScheme.primary
                                    .withOpacity(isDark ? 0.2 : 0.1),
                                theme.colorScheme.primary
                                    .withOpacity(isDark ? 0.1 : 0.05),
                              ],
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.book,
                                      color: theme.colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        courseTitle,
                                        style: theme.textTheme.titleLarge
                                            ?.copyWith(
                                          color: theme.colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildStat(
                                      context,
                                      'Total Sessions',
                                      totalSessions.toString(),
                                      theme.colorScheme.primary,
                                    ),
                                    _buildStat(
                                      context,
                                      'Present',
                                      presentSessions.toString(),
                                      theme.colorScheme.secondary,
                                    ),
                                    _buildStat(
                                      context,
                                      'Attendance',
                                      '${attendanceRate.toStringAsFixed(1)}%',
                                      theme.colorScheme.tertiary,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                TweenAnimationBuilder<double>(
                                  tween: Tween(
                                      begin: 0, end: attendanceRate / 100),
                                  duration: const Duration(milliseconds: 1500),
                                  builder: (context, value, _) => ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: LinearProgressIndicator(
                                      value: value,
                                      backgroundColor: theme
                                          .colorScheme.surfaceContainerHighest,
                                      color: theme.colorScheme.primary,
                                      minHeight: 8,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildStat(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  void _showCourseDetails(
    BuildContext context,
    String courseTitle,
    List<dynamic> records,
  ) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.book,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      courseTitle,
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: records.length,
                itemBuilder: (context, index) {
                  final record = records[index];
                  return _AnimatedCard(
                    child: Card(
                      child: ListTile(
                        leading: _buildStatusIcon(context, record.status),
                        title: Text(record.sessionTitle),
                        subtitle: Text(
                          '${record.sessionDate.toString().split(' ')[0]}\n'
                          '${record.startTime} - ${record.endTime}',
                        ),
                        trailing: _buildStatusChip(context, record.status),
                        isThreeLine: true,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(BuildContext context, String status) {
    final theme = Theme.of(context);
    IconData icon;
    Color color;

    switch (status.toLowerCase()) {
      case 'present':
        icon = Icons.check_circle;
        color = theme.colorScheme.secondary;
        break;
      case 'absent':
        icon = Icons.cancel;
        color = theme.colorScheme.error;
        break;
      case 'late':
        icon = Icons.watch_later;
        color = theme.colorScheme.tertiary;
        break;
      default:
        icon = Icons.help;
        color = theme.colorScheme.onSurfaceVariant;
    }

    return Icon(icon, color: color);
  }

  Widget _buildStatusChip(BuildContext context, String status) {
    final theme = Theme.of(context);
    Color color;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'present':
        color = theme.colorScheme.secondary;
        icon = Icons.check_circle;
        break;
      case 'absent':
        color = theme.colorScheme.error;
        icon = Icons.cancel;
        break;
      case 'late':
        color = theme.colorScheme.tertiary;
        icon = Icons.watch_later;
        break;
      default:
        color = theme.colorScheme.onSurfaceVariant;
        icon = Icons.help;
    }

    return Chip(
      avatar: Icon(icon, color: theme.colorScheme.surface, size: 16),
      label: Text(
        status,
        style: TextStyle(color: theme.colorScheme.surface),
      ),
      backgroundColor: color,
    );
  }
}

class _AnimatedCard extends StatefulWidget {
  final Widget child;

  const _AnimatedCard({required this.child});

  @override
  State<_AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<_AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: widget.child,
          ),
        );
      },
    );
  }
}
