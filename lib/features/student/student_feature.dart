import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/student_home_screen.dart';
import 'screens/student_profile_screen.dart';
import 'screens/student_timeline_screen.dart';
import 'screens/student_courses_screen.dart';

enum StudentNavigationItems {
  dashboard,
  timeline,
  courses,
  profile,
}

final studentCurrentIndexProvider = StateProvider<StudentNavigationItems>(
    (ref) => StudentNavigationItems.dashboard);

class StudentFeature extends ConsumerWidget {
  const StudentFeature({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(studentCurrentIndexProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: _buildScreen(currentIndex),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex.index,
        onDestinationSelected: (index) {
          ref.read(studentCurrentIndexProvider.notifier).state =
              StudentNavigationItems.values[index];
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'Schedule',
          ),
          NavigationDestination(
            icon: Icon(Icons.book_outlined),
            selectedIcon: Icon(Icons.book),
            label: 'Courses',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildScreen(StudentNavigationItems currentIndex) {
    switch (currentIndex) {
      case StudentNavigationItems.dashboard:
        return const StudentHomeScreen();
      case StudentNavigationItems.timeline:
        return const StudentTimelineScreen();
      case StudentNavigationItems.profile:
        return const StudentProfileScreen();
      case StudentNavigationItems.courses:
        return const StudentCoursesScreen();
    }
  }
}
