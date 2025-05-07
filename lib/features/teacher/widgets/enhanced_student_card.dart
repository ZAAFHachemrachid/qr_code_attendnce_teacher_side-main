import 'package:flutter/material.dart';

class StudentData {
  final String id;
  final String name;
  final String groupName;
  final double attendanceRate;
  final String? photoUrl;
  final String? email;
  final String status;

  const StudentData({
    required this.id,
    required this.name,
    required this.groupName,
    required this.attendanceRate,
    this.photoUrl,
    this.email,
    this.status = 'active',
  });
}

class EnhancedStudentCard extends StatelessWidget {
  final StudentData student;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool isCompact;
  final Function(String)? onActionSelected;

  const EnhancedStudentCard({
    super.key,
    required this.student,
    this.onTap,
    this.isSelected = false,
    this.isCompact = false,
    this.onActionSelected,
  });

  void _showQuickActions(BuildContext context) {
    final items = [
      const PopupMenuItem(
        value: 'view',
        child: Row(
          children: [
            Icon(Icons.visibility),
            SizedBox(width: 8),
            Text('View Details'),
          ],
        ),
      ),
      const PopupMenuItem(
        value: 'message',
        child: Row(
          children: [
            Icon(Icons.message),
            SizedBox(width: 8),
            Text('Send Message'),
          ],
        ),
      ),
      const PopupMenuItem(
        value: 'attendance',
        child: Row(
          children: [
            Icon(Icons.event_note),
            SizedBox(width: 8),
            Text('View Attendance'),
          ],
        ),
      ),
    ];

    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(0, 0, 0, 0),
      items: items,
    ).then((value) {
      if (value != null && onActionSelected != null) {
        onActionSelected!(value);
      }
    });
  }

  Color _getAttendanceColor(double rate) {
    if (rate >= 90) return Colors.green;
    if (rate >= 75) return Colors.orange;
    return Colors.red;
  }

  Widget _buildAttendanceIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getAttendanceColor(student.attendanceRate),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${student.attendanceRate.toInt()}%',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: isCompact ? 20 : 24,
      backgroundImage:
          student.photoUrl != null ? NetworkImage(student.photoUrl!) : null,
      child: student.photoUrl == null
          ? Text(
              student.name.substring(0, 1).toUpperCase(),
              style: TextStyle(fontSize: isCompact ? 16 : 20),
            )
          : null,
    );
  }

  Widget _buildStatusIndicator() {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: student.status == 'active' ? Colors.green : Colors.grey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 4 : 1,
      color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
      child: InkWell(
        onTap: onTap,
        onLongPress: () => _showQuickActions(context),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(isCompact ? 8.0 : 12.0),
          child: Row(
            children: [
              Stack(
                children: [
                  _buildAvatar(),
                  if (!isCompact)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: _buildStatusIndicator(),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: isCompact ? 14 : 16,
                          ),
                    ),
                    if (!isCompact) ...[
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${student.id} • Group: ${student.groupName}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildAttendanceIndicator(),
                  if (!isCompact) ...[
                    const SizedBox(height: 4),
                    Text(
                      student.email ?? '',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
              if (!isCompact) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () => _showQuickActions(context),
                  tooltip: 'Quick Actions',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
