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
    return Column(
      children: [
        ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          leading: Icon(
            Icons.menu_book,
            color: Theme.of(context).primaryColor,
            size: 28,
          ),
          title: Text(
            course.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          subtitle: Text(
            '${course.code} • ${(course.groups.first as DummyGroup).professor}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          trailing: const Icon(
            Icons.chevron_right,
            color: Colors.grey,
          ),
        ),
        const Divider(height: 1, indent: 20, endIndent: 20),
      ],
    );
  }
}
