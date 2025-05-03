import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/teacher_class.dart';
import '../models/session_type.dart';
import '../providers/live_session_provider.dart';
import 'live_session_screen.dart';

class QRCodeGeneratorScreen extends ConsumerStatefulWidget {
  final TeacherClass teacherClass;

  const QRCodeGeneratorScreen({
    super.key,
    required this.teacherClass,
  });

  @override
  ConsumerState<QRCodeGeneratorScreen> createState() =>
      _QRCodeGeneratorScreenState();
}

class _QRCodeGeneratorScreenState extends ConsumerState<QRCodeGeneratorScreen> {
  SessionType _selectedSessionType = SessionType.td;
  final List<String> _selectedGroupIds = [];

  @override
  void initState() {
    super.initState();
    // Default to first group selected
    if (widget.teacherClass.groups.isNotEmpty) {
      _selectedGroupIds.add(widget.teacherClass.groups.first.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Generate QR Code - ${widget.teacherClass.code}'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.qr_code,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 24),
              Text(
                'Start Live Attendance Session',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Track attendance in real-time as students scan the QR code',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Session Type Selection
              DropdownButton<SessionType>(
                value: _selectedSessionType,
                onChanged: (SessionType? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedSessionType = newValue;
                    });
                  }
                },
                items: SessionType.values.map((SessionType type) {
                  return DropdownMenuItem<SessionType>(
                    value: type,
                    child: Text(type.label),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              // Group Selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Select Groups:'),
                      const SizedBox(height: 8),
                      ...widget.teacherClass.groups.map((group) {
                        return CheckboxListTile(
                          title: Text(group.name),
                          value: _selectedGroupIds.contains(group.id),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                _selectedGroupIds.add(group.id);
                              } else {
                                _selectedGroupIds.remove(group.id);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _selectedGroupIds.isEmpty
                    ? null
                    : () async {
                        // Start live session
                        await ref
                            .read(liveSessionProvider.notifier)
                            .startSession(
                              courseId: widget.teacherClass.id,
                              sessionType: _selectedSessionType,
                              groupIds: _selectedGroupIds,
                              qrCodeData: _generateQRData(),
                            );

                        if (context.mounted) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => const LiveSessionScreen(),
                            ),
                          );
                        }
                      },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Live Session'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _generateQRData() {
    final timestamp = DateTime.now().toUtc().microsecondsSinceEpoch;
    final random = Random().nextInt(1000000).toString().padLeft(6, '0');

    // Create a more structured and secure QR code data
    final qrData = {
      'version': 1,
      'type': 'attendance',
      'classId': widget.teacherClass.id,
      'groupIds': _selectedGroupIds,
      'sessionType': _selectedSessionType.label,
      'timestamp': timestamp,
      'nonce': random,
    };

    // Convert to JSON and encode to base64 to make it compact
    return base64Url.encode(utf8.encode(json.encode(qrData)));
  }
}
