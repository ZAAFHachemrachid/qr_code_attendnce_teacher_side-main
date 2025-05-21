import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/student_profile.dart';
import '../services/teacher_students_service.dart';

final enrolledStudentsProvider = FutureProvider.family<List<StudentProfile>,
    ({String courseId, String period})>((ref, params) async {
  final service = ref.read(teacherStudentsServiceProvider);
  return service.fetchEnrolledStudents(params.courseId, params.period);
});

class EnrolledStudentsList extends ConsumerWidget {
  final String courseId;
  final String academicPeriod;

  const EnrolledStudentsList({
    super.key,
    required this.courseId,
    required this.academicPeriod,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(
        enrolledStudentsProvider((courseId: courseId, period: academicPeriod)));

    return studentsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error loading students: ${error.toString()}'),
      ),
      data: (students) {
        if (students.isEmpty) {
          return const Center(child: Text('No students enrolled'));
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Text(
                    'Total Students: ${students.length}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  // Add filter/sort options here
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final student = students[index];
                  return StudentCard(student: student);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class StudentCard extends StatelessWidget {
  final StudentProfile student;

  const StudentCard({
    super.key,
    required this.student,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            student.firstName[0] + student.lastName[0],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(student.fullName),
        subtitle: Text(
          '${student.studentNumber} • ${student.groupName}',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (student.attendancePercentage != null)
              Text(
                '${student.attendancePercentage!.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: _getAttendanceColor(student.attendancePercentage!),
                  fontWeight: FontWeight.bold,
                ),
              ),
            Text(
              'Year ${student.currentYear}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        onTap: () {
          // TODO: Navigate to student details/attendance
        },
      ),
    );
  }

  Color _getAttendanceColor(double percentage) {
    if (percentage >= 75) return Colors.green;
    if (percentage >= 50) return Colors.orange;
    return Colors.red;
  }
}
