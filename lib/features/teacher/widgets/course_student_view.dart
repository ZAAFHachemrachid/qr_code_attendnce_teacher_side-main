import 'package:flutter/material.dart';
import '../models/teacher_class.dart';

class CourseStudentView extends StatefulWidget {
  final TeacherClass teacherClass;

  const CourseStudentView({super.key, required this.teacherClass});

  @override
  State<CourseStudentView> createState() => _CourseStudentViewState();
}

class _CourseStudentViewState extends State<CourseStudentView> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredStudents = [];

  @override
  void initState() {
    super.initState();
    print(
        '[CourseStudentView] Initializing with class type: ${widget.teacherClass.type}');
    _filteredStudents = widget.teacherClass.getAllStudents();
    print(
        '[CourseStudentView] Initial student count: ${_filteredStudents.length}');
    print(
        '[CourseStudentView] Sample student data: ${_filteredStudents.isNotEmpty ? _filteredStudents.first : 'No students'}');
  }

  void _onSearchChanged(String value) {
    print('[CourseStudentView] Search query: "$value"');
    setState(() {
      if (value.isEmpty) {
        _filteredStudents = widget.teacherClass.getAllStudents();
      } else {
        _filteredStudents = widget.teacherClass
            .getAllStudents()
            .where((student) =>
                student['id'].toLowerCase().contains(value.toLowerCase()) ||
                student['groupName']
                    .toLowerCase()
                    .contains(value.toLowerCase()))
            .toList();
        print(
            '[CourseStudentView] Filtered students count: ${_filteredStudents.length}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search students...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: _onSearchChanged,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _filteredStudents.length,
            itemBuilder: (context, index) {
              final student = _filteredStudents[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(student['id'][0]),
                  ),
                  title: Text('Student ${student['id']}'),
                  subtitle: Text('Group: ${student['groupName']}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Handle student selection
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
