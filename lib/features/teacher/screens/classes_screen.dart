import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/teacher_class.dart';
import '../models/class_type.dart';
import '../widgets/enrolled_students_list.dart';
import '../providers/teacher_classes_provider.dart';

class ClassesScreen extends ConsumerWidget {
  const ClassesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classesAsync = ref.watch(teacherClassesProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Classes'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Course (CM)'),
              Tab(text: 'TD'),
              Tab(text: 'TP'),
            ],
          ),
        ),
        body: classesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Error loading classes: ${error.toString()}'),
          ),
          data: (classes) => TabBarView(
            children: [
              _buildClassTypeList(
                  classes.where((c) => c.type == ClassType.course).toList()),
              _buildClassTypeList(
                  classes.where((c) => c.type == ClassType.td).toList()),
              _buildClassTypeList(
                  classes.where((c) => c.type == ClassType.tp).toList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClassTypeList(List<TeacherClass> classes) {
    if (classes.isEmpty) {
      return const Center(child: Text('No classes found'));
    }

    return ListView.builder(
      itemCount: classes.length,
      itemBuilder: (context, index) {
        final teacherClass = classes[index];
        return _ClassCard(teacherClass: teacherClass);
      },
    );
  }
}

class _ClassCard extends StatefulWidget {
  final TeacherClass teacherClass;

  const _ClassCard({required this.teacherClass});

  @override
  State<_ClassCard> createState() => _ClassCardState();
}

class _ClassCardState extends State<_ClassCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          ListTile(
            title: Text(
                '${widget.teacherClass.code} - ${widget.teacherClass.title}'),
            subtitle: Text(
              'Groups: ${widget.teacherClass.groups.length} • Students: ${widget.teacherClass.students}',
            ),
            trailing: IconButton(
              icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
            ),
          ),
          if (_isExpanded) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enrolled Students',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 400, // Fixed height for the list
                    child: EnrolledStudentsList(
                      courseId: widget.teacherClass.id,
                      academicPeriod: widget.teacherClass.academicPeriod,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
