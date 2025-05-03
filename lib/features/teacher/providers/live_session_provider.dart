import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/live_session.dart';
import '../models/live_attendance_update.dart';
import '../models/live_session_stats.dart';
import '../models/session_type.dart';
import '../services/live_session_socket_service.dart';

final liveSessionProvider =
    StateNotifierProvider<LiveSessionNotifier, AsyncValue<LiveSession?>>(
  (ref) => LiveSessionNotifier(LiveSessionSocketService()),
);

final liveSessionStatsProvider = StreamProvider<LiveSessionStats>((ref) {
  final socketService = ref.watch(liveSessionProvider.notifier).socketService;
  return socketService.statsUpdates;
});

final liveAttendanceUpdatesProvider =
    StreamProvider<List<LiveAttendanceUpdate>>((ref) {
  final updates = <LiveAttendanceUpdate>[];
  final socketService = ref.watch(liveSessionProvider.notifier).socketService;

  return socketService.attendanceUpdates.map((update) {
    updates.add(update);
    // Keep only the last 50 updates
    if (updates.length > 50) {
      updates.removeAt(0);
    }
    return List.unmodifiable(updates);
  });
});

class LiveSessionNotifier extends StateNotifier<AsyncValue<LiveSession?>> {
  final LiveSessionSocketService socketService;
  StreamSubscription? _statsSubscription;
  StreamSubscription? _updatesSubscription;
  String? _authToken; // Store auth token for reconnection

  LiveSessionNotifier(this.socketService) : super(const AsyncValue.data(null)) {
    _setupSubscriptions();
  }

  void _setupSubscriptions() {
    _statsSubscription?.cancel();
    _updatesSubscription?.cancel();

    _statsSubscription = socketService.statsUpdates.listen(
      (_) {}, // Stats are handled by the separate stream provider
      onError: _handleError,
    );

    _updatesSubscription = socketService.attendanceUpdates.listen(
      (_) {}, // Updates are handled by the separate stream provider
      onError: _handleError,
    );
  }

  void _handleError(Object error) {
    if (!mounted) return;
    state = AsyncValue.error(error, StackTrace.current);
  }

  @override
  void dispose() {
    _statsSubscription?.cancel();
    _updatesSubscription?.cancel();
    socketService.dispose();
    super.dispose();
  }

  Future<void> startSession({
    required String courseId,
    required SessionType sessionType,
    required List<String> groupIds,
    required String qrCodeData,
  }) async {
    if (state.value != null) {
      throw StateError('A session is already active');
    }

    state = const AsyncValue.loading();

    try {
      // Generate a more robust session ID
      final sessionId = _generateSessionId(courseId, groupIds);
      _authToken =
          await _getAuthToken(); // Implement this method to get actual token

      final session = LiveSession(
        id: sessionId,
        courseId: courseId,
        sessionType: sessionType,
        groupIds: groupIds,
        startTime: DateTime.now(),
        status: 'active',
        qrCodeData: qrCodeData,
        attendanceByGroup: {
          for (var groupId in groupIds) groupId: {},
        },
      );

      await socketService.connect(sessionId, _authToken!);
      if (mounted) state = AsyncValue.data(session);
    } catch (error, stackTrace) {
      if (mounted) {
        state = AsyncValue.error(error, stackTrace);
        await socketService.disconnect();
      }
    }
  }

  Future<void> endSession() async {
    if (!mounted) return;

    final currentState = state;
    if (currentState is! AsyncData || currentState.value == null) {
      return;
    }

    try {
      final session = currentState.value!;
      final endedSession = session.copyWith(
        endTime: DateTime.now(),
        status: 'completed',
      );

      await socketService.disconnect();
      if (mounted) state = AsyncValue.data(endedSession);
    } catch (error, stackTrace) {
      if (mounted) state = AsyncValue.error(error, stackTrace);
    }
  }

  String _generateSessionId(String courseId, List<String> groupIds) {
    final timestamp = DateTime.now().toUtc().microsecondsSinceEpoch;
    final random = Random().nextInt(10000).toString().padLeft(4, '0');
    final groupsHash = groupIds.join('-');
    return '$courseId-$groupsHash-$timestamp-$random';
  }

  Future<String> _getAuthToken() async {
    // Use Supabase session token
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      throw StateError('No active session found');
    }
    return session.accessToken;
  }

  bool get isSessionActive =>
      socketService.isConnected && state.value?.status == 'active';
}
