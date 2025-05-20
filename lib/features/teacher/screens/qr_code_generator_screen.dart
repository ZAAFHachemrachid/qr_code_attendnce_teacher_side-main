import 'dart:convert';
import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/teacher_class.dart';
import '../models/class_type.dart';
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

class _QRCodeGeneratorScreenState extends ConsumerState<QRCodeGeneratorScreen>
    with SingleTickerProviderStateMixin {
  ClassType _selectedClassType = ClassType.course;
  final List<String> _selectedGroupIds = [];
  String? _sessionId;
  int _sessionDuration = 5; // Default 5 minutes
  int _remainingTime = 0;
  Timer? _countdownTimer;

  bool _qrGenerated = false;
  List<Map<String, dynamic>> _attendance = [];
  Timer? _attendanceTimer;
  Timer? _statusTimer;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final List<int> _availableDurations = [5, 10, 15, 20];

  @override
  void initState() {
    super.initState();
    // Default to first group selected
    if (widget.teacherClass.groups.isNotEmpty) {
      _selectedGroupIds.add(widget.teacherClass.groups.first.id);
    }

    // Setup animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _attendanceTimer?.cancel();
    _statusTimer?.cancel();
    _countdownTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _remainingTime = _sessionDuration * 60; // Convert to seconds
    _countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        setState(() {
          if (_remainingTime > 0) {
            _remainingTime--;
          } else {
            timer.cancel();
            // Session ended
          }
        });
      },
    );
  }

  void _adjustTime(int minutes) {
    setState(() {
      _sessionDuration = (_sessionDuration + minutes).clamp(5, 60);
      _remainingTime = _sessionDuration * 60;
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _generateQRData() {
    // Generate a unique session ID if not already created
    _sessionId ??= DateTime.now().millisecondsSinceEpoch.toString();

    final data = {
      "sid": _sessionId,
      "type": _selectedClassType.toLabel(),
      "class": {"id": widget.teacherClass.id, "code": widget.teacherClass.code},
      "duration": _sessionDuration,
    };

    // Add group info for TD/TP sessions
    if (_selectedClassType != ClassType.course &&
        _selectedGroupIds.isNotEmpty) {
      final group = widget.teacherClass.groups
          .firstWhere((g) => g.id == _selectedGroupIds.first);
      data["group"] = {"id": group.id, "name": group.name};
    }

    return json.encode(data);
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
          child: _qrGenerated ? _buildQRDisplay() : _buildSessionSetup(),
        ),
      ),
    );
  }

  Widget _buildQRDisplay() {
    final qrData = _generateQRData();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Timer Display
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () => _adjustTime(-5),
                ),
                const SizedBox(width: 16),
                Column(
                  children: [
                    Text(
                      _formatTime(_remainingTime),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text(
                      'Remaining Time',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _adjustTime(5),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        // QR Container
        ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 200.0,
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                  errorCorrectionLevel: QrErrorCorrectLevel.H,
                ),
                const SizedBox(height: 12),
                // Session Info
                Text(
                  'Session Type: ${_selectedClassType.toLabel()}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (_selectedClassType != ClassType.course &&
                    _selectedGroupIds.isNotEmpty)
                  Text(
                    'Group: ${widget.teacherClass.groups.firstWhere((g) => g.id == _selectedGroupIds.first).name}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                const SizedBox(height: 8),
                SelectableText(
                  'Session ID: $_sessionId',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        // Attendance Section Title
        Text(
          'Current Attendance',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        // Attendance Table
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _attendanceTable(),
          ),
        ),
      ],
    );
  }

  Widget _buildSessionSetup() {
    return Column(
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
        // Session Duration Selection
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Session Duration',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _availableDurations.map((duration) {
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _sessionDuration == duration
                            ? Theme.of(context).colorScheme.primary
                            : null,
                        foregroundColor: _sessionDuration == duration
                            ? Theme.of(context).colorScheme.onPrimary
                            : null,
                      ),
                      onPressed: () {
                        setState(() => _sessionDuration = duration);
                      },
                      child: Text('$duration min'),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Session Type Selection
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Session Type',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                DropdownButton<ClassType>(
                  value: _selectedClassType,
                  isExpanded: true,
                  onChanged: (ClassType? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedClassType = newValue;
                        _selectedGroupIds.clear();
                        if (_selectedClassType == ClassType.course &&
                            widget.teacherClass.groups.isNotEmpty) {
                          _selectedGroupIds.addAll(
                              widget.teacherClass.groups.map((g) => g.id));
                        } else if (widget.teacherClass.groups.isNotEmpty) {
                          _selectedGroupIds
                              .add(widget.teacherClass.groups.first.id);
                        }
                      });
                    }
                  },
                  items: ClassType.values
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type.toLabel()),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Group Selection (hidden for CM)
        if (_selectedClassType == ClassType.td ||
            _selectedClassType == ClassType.tp)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Group',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
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
        ElevatedButton.icon(
          onPressed: () {
            setState(() {
              if (_selectedClassType == ClassType.course) {
                _selectedGroupIds
                  ..clear()
                  ..addAll(widget.teacherClass.groups.map((g) => g.id));
              }
              _qrGenerated = true;
            });
            _animationController.forward();
            _startCountdown();
            _startAttendancePolling();
          },
          icon: const Icon(Icons.qr_code),
          label: const Text('Generate QR Code'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
        ),
      ],
    );
  }

  void _startAttendancePolling() {
    _attendanceTimer?.cancel();
    _statusTimer?.cancel();
    _fetchAttendance();

    // Setup status update timer
    _statusTimer = Timer(const Duration(seconds: 10), () {
      setState(() {
        if (_attendance.isNotEmpty) {
          _attendance[0]['status'] = 'Present';
        }
      });
    });

    // Regular attendance polling
    _attendanceTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _fetchAttendance(preserveStatus: true);
    });
  }

  void _fetchAttendance({bool preserveStatus = false}) {
    // Mock data for demonstration
    final newAttendance = List.generate(
      10,
      (i) => {
        'name': 'Student ${i + 1}',
        'id': 'ID${1000 + i}',
        'status': preserveStatus && i < _attendance.length
            ? _attendance[i]['status']
            : 'Absent',
      },
    );

    setState(() {
      _attendance = newAttendance;
    });
  }

  Widget _attendanceTable() {
    if (_attendance.isEmpty) {
      return const Text('No attendance data yet.');
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
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
                  DataCell(
                    Text(
                      record['status'] ?? '',
                      style: TextStyle(
                        color: record['status'] == 'Present'
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}
