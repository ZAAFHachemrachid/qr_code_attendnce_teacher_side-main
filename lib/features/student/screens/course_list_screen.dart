import 'package:flutter/material.dart';
import '../widgets/course_card.dart';
import '../models/dummy_course.dart';

class CourseListScreen extends StatelessWidget {
  const CourseListScreen({super.key});

  List<DummyCourse> _generateDummyCourses() {
    const studentId = "12345";
    const academicYear = 2024;
    const semester = "Spring";

    return [
      DummyCourse.create(
        studentId: studentId,
        academicYear: academicYear,
        semester: semester,
        index: 0,
      ),
      DummyCourse.create(
        studentId: studentId,
        academicYear: academicYear,
        semester: semester,
        index: 1,
      ),
      DummyCourse.create(
        studentId: studentId,
        academicYear: academicYear,
        semester: semester,
        index: 2,
      ),
      DummyCourse.create(
        studentId: studentId,
        academicYear: academicYear,
        semester: semester,
        index: 3,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final courses = _generateDummyCourses();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Courses'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.1,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: courses.length,
        itemBuilder: (context, index) {
          return CourseCard(
            course: courses[index],
            onTap: () {
              Navigator.pushNamed(
                context,
                '/course-detail',
                arguments: courses[index],
              );
            },
          );
        },
      ),
    );
  }
}
