import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:banjarabio/presentation/matchmaking/widgets/match_success_dialog.dart';
import 'package:banjarabio/core/init/app_navigator_key.dart';
import 'package:banjarabio/core/services/local_cache_service.dart';
import 'package:banjarabio/core/models/backend_response.dart';
import 'package:banjarabio/core/services/app_logger.dart';

class MatchmakingService with WidgetsBindingObserver {
  SupabaseClient get _supabase => testClient ?? Supabase.instance.client;
  GlobalKey<NavigatorState> get _navigatorKey => testNavigatorKey ?? navigatorKey;

  @visibleForTesting
  SupabaseClient? testClient;

  @visibleForTesting
  GlobalKey<NavigatorState>? testNavigatorKey;

  @visibleForTesting
  LocalCacheService? testCache;

  LocalCacheService get _cache => testCache ?? LocalCacheService();

  StreamSubscription? _subscription;

  // Channel references for proper disposal
  RealtimeChannel? _profileSharesChannel;
  RealtimeChannel? _profileSharesInsertChannel;

  // Singleton pattern
  static final MatchmakingService _instance = MatchmakingService._internal();
  factory MatchmakingService() => _instance;
  
  MatchmakingService._internal() {
    // 🧬 PRO SCALE: Listen to app lifecycle to drop/resume WebSocket connections.
    // 10M concurrent WebSockets is expensive; 10M idle ones is wasteful.
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      AppLogger.debug('MatchmakingService', 'MatchmakingService: App backgrounded, dropping realtime channels');
      dispose();
    } else if (state == AppLifecycleState.resumed) {
      AppLogger.debug('MatchmakingService', 'MatchmakingService: App resumed, reconnecting realtime channels');
      initializeRealtime();
    }
  }

  /// Initialize with Realtime Channel
  void initializeRealtime() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    // 🚨 SIGNAL 3 FIX: Skip realtime matchmaking for Guest Mode users OR users without a profile.
    final isGuest = _cache.isGuestMode();
    final hasNoProfile = _cache.getOwnProfile() == null;
    if (isGuest || hasNoProfile) {
      AppLogger.warn('MatchmakingService', 'MatchmakingService: Skipping initialization (guest=$isGuest, noProfile=$hasNoProfile)');
      return;
    }

    // Prevent duplicate subscriptions if called multiple times (e.g. rapid foreground/background)
    if (_profileSharesChannel != null || _profileSharesInsertChannel != null) {
      return;
    }

    debugPrint(
      'MatchmakingService: Initializing Realtime Channel for user $userId',
    );

    _profileSharesChannel = _supabase
        .channel('public:profile_shares')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'profile_shares',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'status',
            value: 'matched',
          ),
          callback: (payload) {
            _handleRealtimePayload(payload);
          },
        )
        .subscribe();

    // Also listen for INSERTs where status is already matched (triggered immediately)
    _profileSharesInsertChannel = _supabase
        .channel('public:profile_shares_insert')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'profile_shares',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'status',
            value: 'matched',
          ),
          callback: (payload) {
            _handleRealtimePayload(payload);
          },
        )
        .subscribe();
  }

  void _handleRealtimePayload(PostgresChangePayload payload) {
    debugPrint(
      'MatchmakingService: Match Event Received! ${payload.toString()}',
    );

    final newRecord = payload.newRecord;

    // Use global navigator key instead of BuildContext to avoid memory leaks
    final navigator = _navigatorKey.currentState;
    if (navigator != null) {
      _showMatchDialog(navigator.context, newRecord);
    }
  }

  Future<void> _showMatchDialog(
    BuildContext context,
    Map<String, dynamic> matchRecord,
  ) async {
    final shareId = matchRecord['id'];

    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => MatchSuccessDialog(shareId: shareId),
      );
    }
  }

  Future<BackendResponse<double>> getMatchScore(String profileId1, String profileId2) async {
      try {
          final res = await _supabase.rpc('fn_calculate_match_score', params: {
             'profile1_id': profileId1,
             'profile2_id': profileId2,
          });
          return BackendResponse.success(double.tryParse(res.toString()) ?? 0.0);
      } catch (e) {
          return BackendResponse.failure(e.toString());
      }
  }

  void dispose() {
    _subscription?.cancel();
    _profileSharesChannel?.unsubscribe();
    _profileSharesInsertChannel?.unsubscribe();
    _profileSharesChannel = null;
    _profileSharesInsertChannel = null;
  }

  /// 🚨 CRITICAL: Call this only at App Exit or Logout
  void fullReset() {
    WidgetsBinding.instance.removeObserver(this);
    dispose();
    testClient = null;
    testNavigatorKey = null;
  }

  @visibleForTesting
  void reset() {
    dispose();
    testClient = null;
    testNavigatorKey = null;
    testCache = null;
  }
}

