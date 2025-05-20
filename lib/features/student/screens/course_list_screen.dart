import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/course_card.dart';
import '../providers/student_courses_provider.dart';
import '../providers/student_providers.dart';

class CourseListScreen extends ConsumerWidget {
  const CourseListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch student profile to get groupId
    final studentProfileAsync = ref.watch(studentProfileProvider);

    return studentProfileAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Error: $error')),
      ),
      data: (profile) {
        // Watch courses using student's groupId
        final coursesAsync = ref.watch(studentCoursesProvider);

        return Scaffold(
          appBar: AppBar(
            title: const Text('My Courses'),
            elevation: 0,
          ),
          body: coursesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: $error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref
                          .read(studentCoursesProvider.notifier)
                          .refreshCourses(profile.groupId);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
            data: (courses) {
              if (courses.isEmpty) {
                return const Center(
                  child: Text('No courses found. Contact your administrator.'),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  await ref
                      .read(studentCoursesProvider.notifier)
                      .refreshCourses(profile.groupId);
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: courses.length,
                  itemBuilder: (context, index) {
                    final course = courses[index];
                    return CourseCard(
                      course: course,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/course-detail',
                          arguments: course,
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}
