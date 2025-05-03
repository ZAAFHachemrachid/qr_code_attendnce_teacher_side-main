import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/live_attendance_update.dart';
import '../models/live_session_stats.dart';
import '../models/session_type.dart';
import '../providers/live_session_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class LiveSessionScreen extends ConsumerWidget {
  const LiveSessionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionValue = ref.watch(liveSessionProvider);
    final stats = ref.watch(liveSessionStatsProvider);
    final updates = ref.watch(liveAttendanceUpdatesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Session'),
        actions: [
          sessionValue
                  .whenData(
                    (session) => session != null
                        ? IconButton(
                            icon: const Icon(Icons.stop),
                            onPressed: () => _endSession(ref, context),
                            tooltip: 'End Session',
                          )
                        : const SizedBox.shrink(),
                  )
                  .value ??
              const SizedBox.shrink(),
        ],
      ),
      body: sessionValue.when(
        data: (session) {
          if (session == null) {
            return const SessionSetupView();
          }

          return Row(
            children: [
              // QR Code Section
              Expanded(
                flex: 2,
                child: Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Scan to Mark Attendance',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        QrImageView(
                          data: session.qrCodeData,
                          version: QrVersions.auto,
                          size: 300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Session ID: ${session.id}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Statistics and Updates Section
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    // Stats Card
                    stats.when(
                      data: (statsData) =>
                          _buildStatsCard(context, ref, statsData),
                      loading: () => const CircularProgressIndicator(),
                      error: (err, stack) => Text('Error: $err'),
                    ),
                    // Recent Updates
                    Expanded(
                      child: updates.when(
                        data: (updatesList) =>
                            _buildUpdatesListView(updatesList),
                        loading: () => const CircularProgressIndicator(),
                        error: (err, stack) => Text('Error: $err'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _buildStatsCard(
      BuildContext context, WidgetRef ref, LiveSessionStats stats) {
    final sessionData = ref.watch(liveSessionProvider).value;
    if (sessionData == null) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Attendance Statistics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text(
              'Session Type: ${sessionData.sessionType.label}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            for (String groupId in sessionData.groupIds) ...[
              Text(
                'Group $groupId',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    'Total',
                    stats.totalStudentsByGroup[groupId]?.toString() ?? '0',
                    Icons.people,
                  ),
                  _buildStatItem(
                    'Present',
                    stats.presentStudentsByGroup[groupId]?.toString() ?? '0',
                    Icons.check_circle,
                  ),
                  _buildStatItem(
                    'Attendance',
                    '${((stats.presentStudentsByGroup[groupId] ?? 0) / (stats.totalStudentsByGroup[groupId] ?? 1) * 100).toStringAsFixed(1)}%',
                    Icons.analytics,
                  ),
                ],
              ),
              const Divider(),
            ],
            const SizedBox(height: 16),
            Text(
              'Overall Statistics',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Total',
                  stats.totalStudents.toString(),
                  Icons.people,
                ),
                _buildStatItem(
                  'Present',
                  stats.presentStudents.toString(),
                  Icons.check_circle,
                ),
                _buildStatItem(
                  'Attendance',
                  '${stats.attendancePercentage.toStringAsFixed(1)}%',
                  Icons.analytics,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label),
      ],
    );
  }

  Widget _buildUpdatesListView(List<LiveAttendanceUpdate> updates) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Recent Updates',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: updates.length,
              itemBuilder: (context, index) {
                final update = updates[index];
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(update.studentName),
                  subtitle: Text(
                    'Checked in at ${update.timestamp.toString()}',
                  ),
                  trailing: Icon(
                    update.status == 'present'
                        ? Icons.check_circle
                        : Icons.warning,
                    color: update.status == 'present'
                        ? Colors.green
                        : Colors.orange,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _endSession(WidgetRef ref, BuildContext context) async {
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false, // Prevent accidental dismissal
        builder: (context) => AlertDialog(
          title: const Text('End Session'),
          content: const Text(
            'Are you sure you want to end this session?\n\n'
            'This will:\n'
            '• Stop attendance tracking\n'
            '• Save current attendance records\n'
            '• Close the QR code scanner\n\n'
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('End Session'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        // Show loading indicator
        if (context.mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        try {
          await ref.read(liveSessionProvider.notifier).endSession();

          // Close loading dialog and navigate back
          if (context.mounted) {
            Navigator.of(context).pop(); // Close loading dialog
            Navigator.of(context).pop(); // Navigate back
          }
        } catch (e) {
          // Close loading dialog and show error
          if (context.mounted) {
            Navigator.of(context).pop(); // Close loading dialog
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to end session: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
          rethrow;
        }
      }
    } catch (e) {
      print('Error ending session: $e');
      // Show error to user if context is still valid
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An unexpected error occurred: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class SessionSetupView extends ConsumerStatefulWidget {
  const SessionSetupView({super.key});

  @override
  ConsumerState<SessionSetupView> createState() => _SessionSetupViewState();
}

class _SessionSetupViewState extends ConsumerState<SessionSetupView> {
  final courseIdController = TextEditingController();
  final groupIdsController = TextEditingController();
  SessionType selectedSessionType = SessionType.td;
  List<String> selectedGroupIds = [];

  @override
  void dispose() {
    courseIdController.dispose();
    groupIdsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Start New Session',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: courseIdController,
                decoration: const InputDecoration(
                  labelText: 'Course ID',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // Session Type Dropdown
              DropdownButtonFormField<SessionType>(
                value: selectedSessionType,
                decoration: const InputDecoration(
                  labelText: 'Session Type',
                  border: OutlineInputBorder(),
                ),
                items: SessionType.values.map((SessionType type) {
                  return DropdownMenuItem<SessionType>(
                    value: type,
                    child: Text(type.label),
                  );
                }).toList(),
                onChanged: (SessionType? value) {
                  if (value != null) {
                    setState(() {
                      selectedSessionType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              // Group IDs input
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Selected Groups:'),
                  Wrap(
                    spacing: 8,
                    children: selectedGroupIds.map((groupId) {
                      return Chip(
                        label: Text(groupId),
                        onDeleted: () {
                          setState(() {
                            selectedGroupIds.remove(groupId);
                          });
                        },
                      );
                    }).toList(),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: groupIdsController,
                          decoration: const InputDecoration(
                            labelText: 'Add Group ID',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          if (groupIdsController.text.isNotEmpty) {
                            setState(() {
                              selectedGroupIds.add(groupIdsController.text);
                              groupIdsController.clear();
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: selectedGroupIds.isEmpty
                    ? null
                    : () async {
                        await ref
                            .read(liveSessionProvider.notifier)
                            .startSession(
                              courseId: courseIdController.text,
                              sessionType: selectedSessionType,
                              groupIds: selectedGroupIds,
                              qrCodeData: DateTime.now().toIso8601String(),
                            );
                      },
                child: const Text('Start Session'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
