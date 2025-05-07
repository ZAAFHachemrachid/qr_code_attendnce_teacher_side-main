import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/course.dart';
import 'models/teacher_class.dart';
import 'providers/teacher_profile_provider.dart';
import 'screens/teacher_settings_screen.dart';
import 'screens/attendance_screen.dart';
import 'screens/classes_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/qr_code_generator_screen.dart';
import 'screens/students_screen.dart';
import 'screens/teaching_schedule_screen.dart';
import '../../screens/role_selection_screen.dart';
import 'widgets/teacher_responsive_layout.dart';

class TeacherFeature extends ConsumerStatefulWidget {
  const TeacherFeature({super.key});

  @override
  ConsumerState<TeacherFeature> createState() => _TeacherFeatureState();
}

class _TeacherFeatureState extends ConsumerState<TeacherFeature> {
  int _selectedIndex = 0;
  bool _showSettings = false;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const TeacherDashboard(),
      const TeachingScheduleScreen(),
      const ClassesScreen(),
      const ProfileScreen(),
    ];
  }

  void _handleNavigationTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String get _screenTitle {
    switch (_selectedIndex) {
      case 0:
        return 'Teacher Dashboard';
      case 1:
        return 'Teaching Schedule';
      case 2:
        return 'My Classes';
      case 3:
        return 'Profile';
      default:
        return 'Teacher Dashboard';
    }
  }

  void _toggleSettings() {
    setState(() {
      _showSettings = false;
      if (_selectedIndex == -1) {
        _selectedIndex = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenTitle = _showSettings ? 'Settings' : _screenTitle;

    return Scaffold(
      appBar: AppBar(
        title: Text(screenTitle),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: TeacherResponsiveLayout(
        currentIndex: _selectedIndex,
        onNavigationTap: (index) {
          _showSettings = false;
          _handleNavigationTap(index);
        },
        onSettingsTap: () {
          setState(() {
            _showSettings = !_showSettings;
            if (_showSettings) {
              _selectedIndex = -1;
            } else {
              _selectedIndex = 0;
            }
          });
        },
        child: _showSettings
            ? const TeacherSettingsScreen()
            : _screens[_selectedIndex],
      ),
    );
  }
}

class TeacherDashboard extends ConsumerWidget {
  const TeacherDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(teacherProfileProvider);

    return SingleChildScrollView(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            profileAsync.when(
              loading: () => const SizedBox(
                height: 200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading profile...'),
                    ],
                  ),
                ),
              ),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading profile: ${error.toString()}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
              data: (profile) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.school, size: 64),
                    const SizedBox(height: 16),
                    if (profile != null) ...[
                      Text(
                        'Welcome, ${profile.firstName} ${profile.lastName}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Employee ID: ${profile.employeeId}'),
                      const SizedBox(height: 32),
                    ],
                  ],
                ),
              ),
            ),
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionCard(
                    context,
                    'View Classes',
                    Icons.class_,
                    Colors.blue,
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const ClassesScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildQuickActionCard(
                    context,
                    'View Students',
                    Icons.people,
                    Colors.orange,
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const StudentsScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionCard(
                    context,
                    'Generate QR Code',
                    Icons.qr_code,
                    Colors.green,
                    () {
                      const demoClass = TeacherClass(
                        id: 'demo',
                        code: 'DEMO101',
                        title: 'Demo Class',
                        description: 'Demo class for quick QR generation',
                        creditHours: 3,
                        yearOfStudy: 1,
                        semester: 'current',
                        groups: [
                          CourseGroup(
                            id: 'demo-group',
                            name: 'Demo Group',
                            academicYear: 2024,
                            currentYear: 1,
                            section: 'A',
                            studentCount: 30,
                          ),
                        ],
                        schedule: 'Demo Schedule',
                        type: ClassType.course,
                        academicPeriod: '2024',
                      );
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) =>
                                const QRCodeGeneratorScreen(teacherClass: demoClass)),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildQuickActionCard(
                    context,
                    'Attendance',
                    Icons.fact_check,
                    Colors.purple,
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const AttendanceScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'Recent Activity',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildRecentActivityList(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivityList() {
    final activities = [
      {
        'title': 'Mathematics 101',
        'description': 'Attendance taken',
        'time': '2 hours ago',
        'icon': Icons.check_circle,
        'color': Colors.green,
      },
      {
        'title': 'Physics 202',
        'description': 'QR code generated',
        'time': '3 hours ago',
        'icon': Icons.qr_code,
        'color': Colors.blue,
      },
      {
        'title': 'Computer Science 303',
        'description': 'New student added',
        'time': '1 day ago',
        'icon': Icons.person_add,
        'color': Colors.orange,
      },
    ];

    return Card(
      elevation: 1,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 300),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: activities.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final activity = activities[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: activity['color'] as Color,
                child: Icon(activity['icon'] as IconData,
                    color: Colors.white, size: 20),
              ),
              title: Text(activity['title'] as String),
              subtitle: Text(activity['description'] as String),
              trailing: Text(
                activity['time'] as String,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            );
          },
        ),
      ),
    );
  }
}
