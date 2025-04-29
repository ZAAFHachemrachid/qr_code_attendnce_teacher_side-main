import 'package:flutter/material.dart';
import '../models/teacher_class.dart';
import '../models/course.dart';

class GroupedStudentView extends StatefulWidget {
  final TeacherClass teacherClass;

  const GroupedStudentView({super.key, required this.teacherClass});

  @override
  State<GroupedStudentView> createState() => _GroupedStudentViewState();
}

class _GroupedStudentViewState extends State<GroupedStudentView> {
  final Set<String> _expandedGroups = {};

  void _toggleGroup(String groupId) {
    setState(() {
      if (_expandedGroups.contains(groupId)) {
        _expandedGroups.remove(groupId);
      } else {
        _expandedGroups.add(groupId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.teacherClass.groups.length,
      itemBuilder: (context, index) {
        final CourseGroup group = widget.teacherClass.groups[index];
        final bool isExpanded = _expandedGroups.contains(group.id);
        print(
            '[GroupedStudentView] Rendering group: ${group.name} (ID: ${group.id})');
        print(
            '[GroupedStudentView] Student count in group: ${group.studentCount}');

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              InkWell(
                onTap: () => _toggleGroup(group.id),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              group.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${group.studentCount} students',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: const Icon(Icons.keyboard_arrow_down),
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedCrossFade(
                firstChild: Container(),
                secondChild: _buildStudentList(group),
                crossFadeState: isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 200),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStudentList(CourseGroup group) {
    print(
        '[GroupedStudentView] Building student list for group: ${group.name}');
    print('[GroupedStudentView] Expected student count: ${group.studentCount}');
    return Column(
      children: List.generate(
        group.studentCount,
        (index) => ListTile(
          leading: CircleAvatar(
            child: Text('${index + 1}'),
          ),
          title: Text('Student ${index + 1}'),
          subtitle: Text('ID: ${group.id}-$index'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // Handle student selection
          },
        ),
      ),
    );
  }
}
