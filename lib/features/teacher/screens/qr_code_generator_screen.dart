import 'dart:convert';
import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/teacher_class.dart';
import '../models/session_type.dart';
import '../models/course.dart';
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
  ClassType _selectedClassType = ClassType.course;
  final List<String> _selectedGroupIds = [];

  bool _qrGenerated = false;
  List<Map<String, dynamic>> _attendance = [];
  Timer? _attendanceTimer;

  @override
  void initState() {
    super.initState();
    // Default to first group selected
    if (widget.teacherClass.groups.isNotEmpty) {
      _selectedGroupIds.add(widget.teacherClass.groups.first.id);
    }
  }

  @override
  void dispose() {
    _attendanceTimer?.cancel();
    super.dispose();
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
          child: _qrGenerated
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // QR code at the top
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // You can replace this with a real QR code widget if available
                          const Icon(Icons.qr_code, size: 120, color: Colors.black87),
                          const SizedBox(height: 12),
                          SelectableText(
                            _generateQRData(),
                            style: const TextStyle(fontSize: 12, color: Colors.black54),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Current Attendance',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    _attendanceTable(),
                  ],
                )
              : Column(
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
                    DropdownButton<ClassType>(
                      value: _selectedClassType,
                      onChanged: (ClassType? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedClassType = newValue;
                            // Reset group selection on type change
                            _selectedGroupIds.clear();
                            if (_selectedClassType == ClassType.course && widget.teacherClass.groups.isNotEmpty) {
                              // For CM, select all groups by default
                              _selectedGroupIds.addAll(widget.teacherClass.groups.map((g) => g.id));
                            } else if (widget.teacherClass.groups.isNotEmpty) {
                              // For TD/TP, select first group by default
                              _selectedGroupIds.add(widget.teacherClass.groups.first.id);
                            }
                          });
                        }
                      },
                      items: const [
                        DropdownMenuItem(
                          value: ClassType.course,
                          child: Text('CM'),
                        ),
                        DropdownMenuItem(
                          value: ClassType.td,
                          child: Text('TD'),
                        ),
                        DropdownMenuItem(
                          value: ClassType.tp,
                          child: Text('TP'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Group Selection (hidden for CM)
                    if (_selectedClassType == ClassType.td || _selectedClassType == ClassType.tp)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Select Groups:'),
                              const SizedBox(height: 8),
                              ...widget.teacherClass.groups.map((group) {
                                return RadioListTile<String>(
                                  title: Text(group.name),
                                  value: group.id,
                                  groupValue: _selectedGroupIds.isNotEmpty
                                      ? _selectedGroupIds.first
                                      : null,
                                  onChanged: (String? value) {
                                    setState(() {
                                      _selectedGroupIds
                                        ..clear()
                                        ..add(value!);
                                    });
                                  },
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 32),
                    // Button logic: Only show "Generate QR" for CM, "Start Live Session" for TD/TP
                    if (_selectedClassType == ClassType.course)
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _selectedGroupIds
                              ..clear()
                              ..addAll(widget.teacherClass.groups.map((g) => g.id));
                            _qrGenerated = true;
                          });
                          _startAttendancePolling();
                        },
                        icon: const Icon(Icons.qr_code),
                        label: const Text('Generate QR'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
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
      'sessionType': _selectedClassType.name.toUpperCase(),
      'timestamp': timestamp,
      'nonce': random,
    };

    // For TP and TD sessions, include course info in the QR payload
    if (_selectedClassType == ClassType.tp ||
        _selectedClassType == ClassType.td) {
      qrData['course'] = {
        'code': widget.teacherClass.code,
        'title': widget.teacherClass.title,
        'description': widget.teacherClass.description,
        'creditHours': widget.teacherClass.creditHours,
      };
    }

    // Convert to JSON and encode to base64 to make it compact
    return base64Url.encode(utf8.encode(json.encode(qrData)));
  }

  void _startAttendancePolling() {
    _attendanceTimer?.cancel();
    _fetchAttendance();
    _attendanceTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _fetchAttendance();
    });
  }

  void _fetchAttendance() async {
    // TODO: Replace with real API/service call
    // Mock data for demonstration
    setState(() {
      _attendance = List.generate(
        5,
        (i) => {
          'name': 'Student ${i + 1}',
          'id': 'ID${1000 + i}',
          'status': i % 2 == 0 ? 'Present' : 'Absent',
        },
      );
    });
  }

  Widget _attendanceTable() {
    if (_attendance.isEmpty) {
      return const Text('No attendance data yet.');
    }
    return DataTable(
      columns: const [
        DataColumn(label: Text('Student Name')),
        DataColumn(label: Text('ID')),
        DataColumn(label: Text('Status')),
      ],
      rows: _attendance
          .map(
            (record) => DataRow(
              cells: [
                DataCell(Text(record['name'] ?? '')),
                DataCell(Text(record['id'] ?? '')),
                DataCell(Text(record['status'] ?? '')),
              ],
            ),
          )
          .toList(),
    );
  }
}
