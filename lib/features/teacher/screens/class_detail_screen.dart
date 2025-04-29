import 'package:flutter/material.dart';
import '../models/teacher_class.dart';
import '../widgets/course_student_view.dart';
import '../widgets/grouped_student_view.dart';

class ClassDetailScreen extends StatelessWidget {
  final TeacherClass teacherClass;

  const ClassDetailScreen({
    super.key,
    required this.teacherClass,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(teacherClass.title),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(72),
          child: Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Code: ${teacherClass.code}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  '${teacherClass.students} Students • ${teacherClass.type.name.toUpperCase()}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    print(
        '[ClassDetailScreen] Building view for class type: ${teacherClass.type}');
    print('[ClassDetailScreen] Total students: ${teacherClass.students}');
    print(
        '[ClassDetailScreen] Number of groups: ${teacherClass.groups.length}');

    if (teacherClass.isCourse) {
      print('[ClassDetailScreen] Using CourseStudentView');
      return CourseStudentView(teacherClass: teacherClass);
    } else {
      // For both TD and TP, we use the grouped view
      print('[ClassDetailScreen] Using GroupedStudentView');
      return GroupedStudentView(teacherClass: teacherClass);
    }
  }
}
