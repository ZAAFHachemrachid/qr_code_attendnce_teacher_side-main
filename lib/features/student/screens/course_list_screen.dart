import 'package:flutter/material.dart';
import '../widgets/dummy_course_card.dart';
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
        elevation: 0,
      ),
      body: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: courses.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/course-detail',
                arguments: courses[index],
              );
            },
            child: DummyCourseCard(
              course: courses[index],
            ),
          );
        },
      ),
    );
  }
}
