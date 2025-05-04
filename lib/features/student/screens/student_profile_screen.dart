import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/student_providers.dart';
import '../services/attendance_service.dart';
import '../../auth/providers/auth_provider.dart';
import 'student_settings_screen.dart';
import '../../../core/widgets/skeletons/profile_skeleton.dart';
import '../../shared/widgets/attendance_history_view.dart';
import '../../teacher/widgets/enhanced_student_card.dart';
import '../models/student_profile.dart';

class StudentProfileScreen extends ConsumerStatefulWidget {
  final StudentData? studentData;

  const StudentProfileScreen({
    super.key,
    this.studentData,
  });

  @override
  ConsumerState<StudentProfileScreen> createState() =>
      _StudentProfileScreenState();
}

class _StudentProfileScreenState extends ConsumerState<StudentProfileScreen> {
  DateTime? _startDate;
  DateTime? _endDate;

  void _handleDateRangeChanged(DateTime? start, DateTime? end) {
    setState(() {
      _startDate = start;
      _endDate = end;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // If studentData is provided (teacher view), convert it to StudentProfile
    // Otherwise, fetch from provider (student view)
    final profileAsync = widget.studentData != null
        ? AsyncValue.data(StudentProfile(
            id: widget.studentData!.id,
            studentNumber: widget.studentData!.id,
            groupId: widget.studentData!.groupName,
            firstName: widget.studentData!.name.split(' ').first,
            lastName: widget.studentData!.name.split(' ').last,
          ))
        : ref.watch(studentProfileProvider);

    final studentId =
        widget.studentData?.id ?? ref.read(authServiceProvider).currentUser?.id;
    final attendanceAsync = studentId != null
        ? ref
            .watch(attendanceHistoryProvider((studentId, _startDate, _endDate)))
        : const AsyncValue.loading();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authServiceProvider).signOut().then((_) {
                // Auth state changes will automatically navigate to login
              }).catchError((e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to sign out'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              });
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(studentProfileProvider);
        },
        child: profileAsync.when(
          data: (profile) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                _buildProfileHeader(context, profile),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoCard(
                        context,
                        title: 'Personal Information',
                        icon: Icons.person_outline,
                        color: colorScheme.primary,
                        items: [
                          _buildInfoRow('First Name', profile.firstName),
                          _buildInfoRow('Last Name', profile.lastName),
                          _buildInfoRow(
                              'Student Number', profile.studentNumber),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInfoCard(
                        context,
                        title: 'Current Semester',
                        icon: Icons.school_outlined,
                        color: colorScheme.secondary,
                        items: [
                          _buildInfoRow('Department', 'Computer Science'),
                          _buildInfoRow('Year', '3rd Year'),
                          _buildInfoRow('Section', 'A'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInfoCard(
                        context,
                        title: 'Contact Information',
                        icon: Icons.contact_mail_outlined,
                        color: colorScheme.tertiary,
                        items: [
                          _buildInfoRow(
                            'Email',
                            ref.read(authServiceProvider).currentUser?.email ??
                                '',
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Attendance History',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      attendanceAsync.when(
                        data: (attendance) => AttendanceHistoryView(
                          history: attendance,
                          startDate: _startDate,
                          endDate: _endDate,
                          onDateRangeChanged: _handleDateRangeChanged,
                        ),
                        loading: () => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        error: (error, stack) => Center(
                          child: Text(
                            'Error loading attendance history',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      FilledButton.tonal(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const StudentSettingsScreen(),
                            ),
                          );
                        },
                        child: const Text('Settings'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          loading: () => const ProfileSkeleton(),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading profile',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.red,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton.tonal(
                  onPressed: () {
                    ref.invalidate(studentProfileProvider);
                  },
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, Object profileData) {
    final profile = profileData as StudentProfile;
    final theme = Theme.of(context);
    return Stack(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primaryContainer,
              ],
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 32),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 0.8 + (0.2 * value),
                    child: Opacity(
                      opacity: value,
                      child: Hero(
                        tag: 'profile-avatar',
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color:
                                    theme.colorScheme.primary.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: theme.colorScheme.surface,
                            child: Text(
                              '${profile.firstName[0]}${profile.lastName[0]}',
                              style: TextStyle(
                                fontSize: 32,
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Text(
                '${profile.firstName} ${profile.lastName}',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onPrimary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  profile.studentNumber,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimary.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: IconButton.filledTonal(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StudentSettingsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.settings),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> items,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.95 + (0.05 * value),
          child: Opacity(
            opacity: value,
            child: Card(
              elevation: 3,
              shadowColor: color.withOpacity(0.3),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.cardColor,
                      Color.lerp(theme.cardColor, color, isDark ? 0.1 : 0.05) ??
                          theme.cardColor,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: color.withOpacity(isDark ? 0.2 : 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(icon, color: color),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(),
                      ),
                      ...items,
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
