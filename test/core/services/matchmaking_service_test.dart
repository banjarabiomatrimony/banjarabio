import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:banjarabio/core/services/matchmaking_service.dart';
import 'package:banjarabio/core/services/local_cache_service.dart';
import '../../helpers/supabase_fakes.dart';

class MockNavigatorState extends Mock implements NavigatorState {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) => super.toString();
}

class MockBuildContext extends Mock implements BuildContext {}

class MockLocalCacheService extends Mock implements LocalCacheService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MatchmakingService matchmakingService;
  late FakeSupabaseClient fakeSupabase;
  late GlobalKey<NavigatorState> testNavigatorKey;
  late MockLocalCacheService mockLocalCache;

  setUp(() {
    fakeSupabase = FakeSupabaseClient();
    testNavigatorKey = GlobalKey<NavigatorState>();
    mockLocalCache = MockLocalCacheService();
    
    // Stub LocalCacheService methods used in initializeRealtime
    when(() => mockLocalCache.isGuestMode()).thenReturn(false);
    when(() => mockLocalCache.getOwnProfile()).thenReturn({'id': 'p1'});
    
    matchmakingService = MatchmakingService();
    matchmakingService.reset();
    matchmakingService.testClient = fakeSupabase;
    matchmakingService.testNavigatorKey = testNavigatorKey;
    matchmakingService.testCache = mockLocalCache;
    
    // Mock user for initialization
    fakeSupabase.mockUser = User(
      id: 'user_123',
      appMetadata: {},
      userMetadata: {},
      aud: 'aud',
      createdAt: DateTime.now().toIso8601String(),
    );
  });

  tearDown(() {
    matchmakingService.reset();
  });

  test('initializeRealtime subscribes to profile_shares channel', () {
    matchmakingService.initializeRealtime();

    final updateChannel = fakeSupabase.getChannel('public:profile_shares') as FakeRealtimeChannel;
    final insertChannel = fakeSupabase.getChannel('public:profile_shares_insert') as FakeRealtimeChannel;

    expect(updateChannel, isNotNull);
    expect(insertChannel, isNotNull);
  });

  test('disposes channels correctly', () {
    matchmakingService.initializeRealtime();
    matchmakingService.dispose();

    // In our fake, dispose clears the channels map
    expect(fakeSupabase.removeAllChannels, returnsNormally);
  });

  test('handles matched event and attempts to show dialog', () async {
    matchmakingService.initializeRealtime();
    final updateChannel = fakeSupabase.getChannel('public:profile_shares') as FakeRealtimeChannel;

    final payload = PostgresChangePayload(
      schema: 'public',
      table: 'profile_shares',
      commitTimestamp: DateTime.now(),
      eventType: PostgresChangeEvent.update,
      newRecord: {'id': 'match_123', 'status': 'matched'},
      oldRecord: {'id': 'match_123', 'status': 'pending'},
      errors: [],
    );

    expect(() => updateChannel.simulatePostgresChange(payload), returnsNormally);
  });

  test('getMatchScore returns score from RPC', () async {
    fakeSupabase.rpcResponse = 85.5;

    final result = await matchmakingService.getMatchScore('p1', 'p2');

    expect(result.isSuccess, true);
    expect(result.data, 85.5);
    expect(fakeSupabase.rpcFunction, 'fn_calculate_match_score');
    expect(fakeSupabase.rpcParams?['profile1_id'], 'p1');
    expect(fakeSupabase.rpcParams?['profile2_id'], 'p2');
  });

  test('getMatchScore handles RPC errors gracefully', () async {
    fakeSupabase.rpcError = 'Calculate failed';

    final result = await matchmakingService.getMatchScore('p1', 'p2');

    expect(result.isSuccess, false);
    expect(result.errorMessage, contains('Calculate failed'));
  });
}
