import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/live_session.dart';
import '../models/live_attendance_update.dart';
import '../models/live_session_stats.dart';

class LiveSessionSocketService {
  bool _disposed = false;
  final _supabase = Supabase.instance.client;

  RealtimeChannel? _channel;
  StreamController<LiveSessionStats>? _statsController;
  StreamController<LiveAttendanceUpdate>? _updatesController;
  String? _currentSessionId;

  // Stream getters for UI consumption
  Stream<LiveSessionStats> get statsUpdates =>
      _statsController?.stream ?? Stream.empty();
  Stream<LiveAttendanceUpdate> get attendanceUpdates =>
      _updatesController?.stream ?? Stream.empty();

  Future<void> connect(String sessionId, String authToken) async {
    if (_disposed) return;

    if (_channel != null) {
      await disconnect();
    }

    _currentSessionId = sessionId;
    _statsController = StreamController<LiveSessionStats>.broadcast();
    _updatesController = StreamController<LiveAttendanceUpdate>.broadcast();

    try {
      // Create Supabase Realtime channel
      _channel = _supabase.channel('live_session_$sessionId');

      // Subscribe to live session changes
      _channel = _channel!
        ..onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'live_sessions',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'session_id',
            value: sessionId,
          ),
          callback: (payload) => _handleDatabaseChange(payload),
        )
        // Subscribe to attendance changes
        ..onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'attendance_records',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'session_id',
            value: sessionId,
          ),
          callback: (payload) => _handleAttendanceChange(payload),
        );

      // Subscribe to the channel
      final status = await _channel?.subscribe();
      print('Channel subscription status: $status');

      if (status == 'SUBSCRIBED') {
        print('Successfully connected to session: $sessionId');
      } else {
        throw Exception('Failed to subscribe to channel: $status');
      }
    } catch (e) {
      print('Connection Error: $e');
      rethrow;
    }
  }

  void _handleDatabaseChange(PostgresChangePayload payload) {
    if (_statsController?.isClosed == false) {
      try {
        final data = payload.newRecord;
        if (data != null) {
          _statsController?.add(LiveSessionStats.fromJson(data));
        }
      } catch (e) {
        print('Error handling stats update: $e');
      }
    }
  }

  void _handleAttendanceChange(PostgresChangePayload payload) {
    if (_updatesController?.isClosed == false) {
      try {
        final data = payload.newRecord;
        if (data != null) {
          _updatesController?.add(LiveAttendanceUpdate.fromJson(data));
        }
      } catch (e) {
        print('Error handling attendance update: $e');
      }
    }
  }

  Future<void> disconnect() async {
    await _channel?.unsubscribe();
    await _statsController?.close();
    await _updatesController?.close();

    _channel = null;
    _statsController = null;
    _updatesController = null;
    _currentSessionId = null;
  }

  Future<void> _reconnect() async {
    if (_disposed || _currentSessionId == null) return;

    final sessionId = _currentSessionId!;
    await disconnect();

    // Attempt to reconnect with exponential backoff
    var attempts = 0;
    const maxAttempts = 5;
    const maxDelaySeconds = 32;

    while (attempts < maxAttempts && !_disposed) {
      try {
        await connect(
            sessionId, ''); // Reuse existing auth token from Supabase client
        return;
      } catch (e) {
        attempts++;
        if (attempts == maxAttempts || _disposed) {
          rethrow;
        }
        final delay =
            Duration(seconds: (1 << attempts).clamp(1, maxDelaySeconds));
        await Future.delayed(delay);
      }
    }
  }

  bool get isConnected => _channel?.isJoined ?? false;

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    disconnect();
  }
}
