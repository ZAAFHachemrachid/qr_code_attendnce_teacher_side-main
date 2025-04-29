import 'package:flutter/material.dart';
import '../models.dart';

class StudentsScreen extends StatelessWidget {
  const StudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample student data
    final students = List.generate(
      10,
      (index) => StudentInfo(
        id: 'S${index + 1}',
        name: 'Student ${index + 1}',
        email: 'student${index + 1}@example.com',
        className: 'Various Classes',
        attendanceRate: (70 + (index % 30)).toDouble(),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Students'),
        backgroundColor: const Color(0xFF6AB19B),
      ),
      body: ListView.builder(
        itemCount: students.length,
        itemBuilder: (context, index) {
          final student = students[index];
          return ListTile(
            leading: CircleAvatar(
              child: Text(student.name.substring(0, 1)),
            ),
            title: Text(student.name),
            subtitle: Text(student.email),
            trailing: Container(
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
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement add student functionality
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Add student functionality coming soon')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Color _getAttendanceColor(double rate) {
    if (rate >= 90) return Colors.green;
    if (rate >= 75) return Colors.orange;
    return Colors.red;
  }
}
