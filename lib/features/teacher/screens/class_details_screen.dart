import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/teacher_class.dart';
import '../widgets/enrolled_students_list.dart';

class ClassDetailsScreen extends ConsumerStatefulWidget {
  final TeacherClass teacherClass;

  const ClassDetailsScreen({
    super.key,
    required this.teacherClass,
  });

  @override
  ConsumerState<ClassDetailsScreen> createState() => _ClassDetailsScreenState();
}

class _ClassDetailsScreenState extends ConsumerState<ClassDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('${widget.teacherClass.code} - ${widget.teacherClass.title}'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Details'),
            Tab(text: 'Students'),
            Tab(text: 'Attendance'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDetailsTab(),
          EnrolledStudentsList(
            courseId: widget.teacherClass.id,
            academicPeriod: widget.teacherClass.academicPeriod,
          ),
          _buildAttendanceTab(),
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Course Information',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Code', widget.teacherClass.code),
                  _buildInfoRow('Title', widget.teacherClass.title),
                  _buildInfoRow('Description', widget.teacherClass.description),
                  _buildInfoRow('Credit Hours',
                      widget.teacherClass.creditHours.toString()),
                  _buildInfoRow('Year of Study',
                      widget.teacherClass.yearOfStudy.toString()),
                  _buildInfoRow('Semester', widget.teacherClass.semester),
                  _buildInfoRow('Schedule', widget.teacherClass.schedule),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Groups',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  ...widget.teacherClass.groups.map((group) => ListTile(
                        title: Text(group.name),
                        subtitle: Text(
                            'Section ${group.section} • ${group.studentCount} students'),
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceTab() {
    // TODO: Implement attendance history view
    return const Center(
      child: Text('Attendance History Coming Soon'),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
