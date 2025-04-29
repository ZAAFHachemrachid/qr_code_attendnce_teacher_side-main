import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/course.dart';

class QRCodeGeneratorScreen extends StatefulWidget {
  final ClassInfo classInfo;

  const QRCodeGeneratorScreen({
    super.key,
    required this.classInfo,
  });

  @override
  State<QRCodeGeneratorScreen> createState() => _QRCodeGeneratorScreenState();
}

class _QRCodeGeneratorScreenState extends State<QRCodeGeneratorScreen> {
  String? _selectedSessionType;
  String? _selectedGroup;

  final List<String> _sessionTypes = ['Course', 'TD', 'TP'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Generate QR Code - ${widget.classInfo.code}'),
        backgroundColor: const Color(0xFF6AB19B),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Session Type',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.class_),
              ),
              value: _selectedSessionType,
              hint: const Text('Select Session Type'),
              items: _sessionTypes.map((String type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedSessionType = newValue;
                  // Reset group when session type changes
                  _selectedGroup = null;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Group',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.group),
              ),
              value: _selectedGroup,
              hint: const Text('Select Group'),
              items: widget.classInfo.groups.map((group) {
                return DropdownMenuItem<String>(
                  value: group.id,
                  child: Text('${group.name} - Section ${group.section}'),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedGroup = newValue;
                });
              },
            ),
            const SizedBox(height: 32),
            if (_selectedSessionType != null && _selectedGroup != null) ...[
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                ),
                child: Center(
                  child: QrImageView(
                    data: _generateQRData(),
                    version: QrVersions.auto,
                    size: 180,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Course: ${widget.classInfo.title}'),
              Text('Session: $_selectedSessionType'),
              Text('Group: ${_getSelectedGroupName()}'),
              Text(
                'Generated: ${DateTime.now().toString().substring(0, 16)}',
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement share functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Share functionality coming soon')),
                  );
                },
                icon: const Icon(Icons.share),
                label: const Text('Share QR Code'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6AB19B),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
            ] else
              const Center(
                child: Text(
                  'Please select session type and group to generate QR code',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _generateQRData() {
    return '''
{
  "course_id": "${widget.classInfo.id}",
  "course_code": "${widget.classInfo.code}",
  "session_type": "$_selectedSessionType",
  "group_id": "$_selectedGroup",
  "timestamp": "${DateTime.now().toIso8601String()}"
}''';
  }

  String _getSelectedGroupName() {
    final group = widget.classInfo.groups.firstWhere(
        (g) => g.id == _selectedGroup,
        orElse: () => throw 'Group not found');
    return '${group.name} - Section ${group.section}';
  }
}
