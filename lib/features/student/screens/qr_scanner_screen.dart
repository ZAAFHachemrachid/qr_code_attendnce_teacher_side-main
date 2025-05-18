import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../services/attendance_service.dart';

class QRScannerScreen extends ConsumerStatefulWidget {
  const QRScannerScreen({super.key});

  @override
  ConsumerState<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends ConsumerState<QRScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  bool _processing = false;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    } else if (Platform.isIOS) {
      controller?.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProfileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: (result != null)
                  ? Text('Data: ${result!.code}')
                  : const Text('Scan a code'),
            ),
          ),
          if (_processing)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (_processing) return;
      setState(() {
        _processing = true;
      });

      final sessionId = scanData.code?.trim() ?? '';
      final userProfileAsync = ref.read(userProfileProvider);

      // Wait for user profile to load if needed
      Map<String, dynamic>? userProfile;
      if (userProfileAsync is AsyncData) {
        userProfile = userProfileAsync.value;
      } else if (userProfileAsync is AsyncLoading) {
        setState(() {
          _processing = false;
        });
        return;
      } else if (userProfileAsync is AsyncError) {
        setState(() {
          _processing = false;
        });
        _showDialog('Error', 'Failed to load user profile.');
        return;
      }

      final studentId = userProfile?['id'] as String?;
      if (studentId == null || sessionId.isEmpty) {
        setState(() {
          _processing = false;
        });
        _showDialog('Error', 'Invalid student or session information.');
        return;
      }

      final attendanceService = ref.read(attendanceServiceProvider);

      final isValid = await attendanceService.validateSession(sessionId);
      if (isValid) {
        await attendanceService.addAttendance(sessionId, studentId);
        setState(() {
          result = scanData;
          _processing = false;
        });
        _showDialog('Success', 'Attendance recorded successfully.');
      } else {
        setState(() {
          _processing = false;
        });
        _showDialog('Invalid Session', 'Session is not valid. Please retry scanning.');
      }
    });
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                result = null;
              });
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
