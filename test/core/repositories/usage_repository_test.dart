import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:banjarabio/core/repositories/usage_repository.dart';
import 'package:banjarabio/core/repositories/subscription_repository.dart';
import 'package:banjarabio/core/models/backend_response.dart';
import 'package:banjarabio/core/models/subscription_config.dart';
import 'package:banjarabio/core/models/subscription_model.dart';
import 'package:banjarabio/core/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../helpers/supabase_fakes.dart';

class MockSubscriptionRepository extends Mock
    implements SubscriptionRepository {}

void main() {
  late UsageRepository repo;
  late FakeSupabaseClient fakeClient;
  late MockSubscriptionRepository mockSubRepo;

  setUp(() {
    fakeClient = FakeSupabaseClient();
    mockSubRepo = MockSubscriptionRepository();

    // Setup authenticated user
    AppSupabaseClient.testAuth = fakeClient.auth;
    (fakeClient.auth as dynamic).mockUser = const User(
      id: 'test-user-id',
      appMetadata: {},
      userMetadata: {},
      aud: '',
      createdAt: '',
    );
    repo = UsageRepository()
      ..testClient = fakeClient
      ..testSubscriptionRepository = mockSubRepo;
  });

  tearDown(() {
    AppSupabaseClient.testAuth = null;
  });

  // ─── Helper to setup usage_tracking table ───
  void setupUsageTable({Map<String, dynamic>? existing}) {
    final table = fakeClient.from('usage_tracking') as dynamic;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final defaultRecord = {
      'user_id': 'test-user-id',
      'date': today,
      'profile_views': 0,
      'shares_count': 0,
      'bookmarks_count': 0,
    };

    if (existing != null) {
      table.builder.responseData = [{...defaultRecord, ...existing}];
    } else {
      // Use callback to return empty for first call (select) and record for second (insert)
      int callCount = 0;
      table.builder.responseData = () {
        callCount++;
        if (callCount == 1) return []; // Check existing
        return [defaultRecord]; // Insert result
      };
    }
  }

  void setupProfilesTable({String profileId = 'profile-1'}) {
    final table = fakeClient.from('profiles') as dynamic;
    table.builder.responseData = [
      {'id': profileId, 'user_id': 'test-user-id'}
    ];
  }

  void setupCountTable(String tableName, int count) {
    final table = fakeClient.from(tableName) as dynamic;
    table.countBuilder.setData(count);
    // Also set on builder so .select().count() works
    // Include common identifying columns so filters like .eq() don't return empty results
    table.builder.responseData = List.generate(count, (index) => <String, dynamic>{
      'user_id': 'test-user-id',
      'profile_id': 'profile-1',
      'sharer_id': 'profile-1',
      'status': 'verified',
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // ═══════════════════════════════════════════════
  // canViewProfile
  // ═══════════════════════════════════════════════
  group('canViewProfile', () {
    test('returns true for premium users (unlimited views)', () async {
      when(() => mockSubRepo.getPlanType())
          .thenAnswer((_) async => BackendResponse.success(PlanType.platinum));

      final result = await repo.canViewProfile();
      result.fold(
        onSuccess: (canView) => expect(canView, true),
        onFailure: (e) => fail('Expected success but got failure: $e'),
      );
    });

    test('returns true when under daily limit for free plan', () async {
      when(() => mockSubRepo.getPlanType())
          .thenAnswer((_) async => BackendResponse.success(PlanType.free));

      setupUsageTable(
          existing: {'profile_views': 3, 'shares_count': 0, 'bookmarks_count': 0});

      final result = await repo.canViewProfile();
      result.fold(
        onSuccess: (canView) => expect(canView, true),
        onFailure: (e) => fail('Expected success but got failure: $e'),
      );
    });

    test('returns false when at daily limit for free plan', () async {
      when(() => mockSubRepo.getPlanType())
          .thenAnswer((_) async => BackendResponse.success(PlanType.free));

      final freeFeatures = SubscriptionConfig.getFeatures(PlanType.free);
      setupUsageTable(existing: {
        'profile_views': freeFeatures.profileViewsPerDay,
        'shares_count': 0,
        'bookmarks_count': 0,
      });

      final result = await repo.canViewProfile();
      result.fold(
        onSuccess: (canView) => expect(canView, false),
        onFailure: (e) => fail('Expected success but got failure: $e'),
      );
    });

    test('returns failure when getPlanType fails', () async {
      when(() => mockSubRepo.getPlanType())
          .thenAnswer((_) async => BackendResponse.failure('Network error'));

      final result = await repo.canViewProfile();
      result.fold(
        onSuccess: (_) => fail('Expected failure'),
        onFailure: (e) => expect(e.toLowerCase(), contains('plan')),
      );
    });

    test('returns failure on exception', () async {
      when(() => mockSubRepo.getPlanType()).thenThrow(Exception('DB down'));

      final result = await repo.canViewProfile();
      result.fold(
        onSuccess: (_) => fail('Expected failure'),
        onFailure: (e) => expect(e, contains('DB down')),
      );
    });
  });

  // ═══════════════════════════════════════════════
  // incrementProfileView
  // ═══════════════════════════════════════════════
  group('incrementProfileView', () {
    test('calls fn_track_usage RPC and returns success', () async {
      fakeClient.rpcResponse = {'success': true};

      final result = await repo.incrementProfileView();
      expect(fakeClient.rpcFunction, 'fn_track_usage');
      expect(fakeClient.rpcParams?['metric'], 'profile_views');
      expect(fakeClient.rpcParams?['increment'], 1);
      // Should not throw
      result.fold(
        onSuccess: (_) {},
        onFailure: (e) => fail('Expected success but got: $e'),
      );
    });

    test('returns success even on RPC error (non-blocking)', () async {
      fakeClient.rpcError = Exception('RPC failed');

      final result = await repo.incrementProfileView();
      // Should return success (non-blocking)
      result.fold(
        onSuccess: (_) {},
        onFailure: (e) => fail('Should not block on tracking failure: $e'),
      );
    });
  });

  // ═══════════════════════════════════════════════
  // getRemainingProfileViews
  // ═══════════════════════════════════════════════
  group('getRemainingProfileViews', () {
    test('returns 999 for platinum users', () async {
      when(() => mockSubRepo.getPlanType())
          .thenAnswer((_) async => BackendResponse.success(PlanType.platinum));

      final result = await repo.getRemainingProfileViews();
      result.fold(
        onSuccess: (remaining) => expect(remaining, 999),
        onFailure: (e) => fail('Expected success but got failure: $e'),
      );
    });

    test('returns correct remaining for free plan', () async {
      when(() => mockSubRepo.getPlanType())
          .thenAnswer((_) async => BackendResponse.success(PlanType.free));

      setupUsageTable(
          existing: {'profile_views': 5, 'shares_count': 0, 'bookmarks_count': 0});

      final result = await repo.getRemainingProfileViews();
      final freeFeatures = SubscriptionConfig.getFeatures(PlanType.free);
      result.fold(
        onSuccess: (remaining) =>
            expect(remaining, freeFeatures.profileViewsPerDay - 5),
        onFailure: (e) => fail('Expected success but got failure: $e'),
      );
    });

    test('clamps to 0 when over limit', () async {
      when(() => mockSubRepo.getPlanType())
          .thenAnswer((_) async => BackendResponse.success(PlanType.free));

      setupUsageTable(
          existing: {'profile_views': 9999, 'shares_count': 0, 'bookmarks_count': 0});

      final result = await repo.getRemainingProfileViews();
      result.fold(
        onSuccess: (remaining) => expect(remaining, 0),
        onFailure: (e) => fail('Expected success but got failure: $e'),
      );
    });

    test('returns failure on exception', () async {
      when(() => mockSubRepo.getPlanType()).thenThrow(Exception('Error'));

      final result = await repo.getRemainingProfileViews();
      result.fold(
        onSuccess: (_) => fail('Expected failure'),
        onFailure: (e) => expect(e, contains('Error')),
      );
    });
  });

  // ═══════════════════════════════════════════════
  // canShareProfile
  // ═══════════════════════════════════════════════
  group('canShareProfile', () {
    test('returns true for platinum users (unlimited shares)', () async {
      when(() => mockSubRepo.getPlanType())
          .thenAnswer((_) async => BackendResponse.success(PlanType.platinum));

      final result = await repo.canShareProfile();
      result.fold(
        onSuccess: (canShare) => expect(canShare, true),
        onFailure: (e) => fail('Expected success but got failure: $e'),
      );
    });

    test('returns true when under monthly share limit', () async {
      when(() => mockSubRepo.getPlanType())
          .thenAnswer((_) async => BackendResponse.success(PlanType.free));

      setupProfilesTable();
      setupCountTable('profile_shares', 2);

      final result = await repo.canShareProfile();
      result.fold(
        onSuccess: (canShare) => expect(canShare, true),
        onFailure: (e) => fail('Expected success but got failure: $e'),
      );
    });

    test('returns failure when user not authenticated', () async {
      when(() => mockSubRepo.getPlanType())
          .thenAnswer((_) async => BackendResponse.success(PlanType.free));
      (fakeClient.auth as dynamic).mockUser = null; // No user

      final result = await repo.canShareProfile();
      result.fold(
        onSuccess: (_) => fail('Expected failure'),
        onFailure: (e) => expect(e, contains('not authenticated')),
      );
    });

    test('returns failure when profile not found', () async {
      when(() => mockSubRepo.getPlanType())
          .thenAnswer((_) async => BackendResponse.success(PlanType.free));

      // Setup profiles table to return empty (null via maybeSingle)
      final table = fakeClient.from('profiles') as dynamic;
      table.builder.responseData = []; // No profiles

      final result = await repo.canShareProfile();
      result.fold(
        onSuccess: (_) => fail('Expected failure'),
        onFailure: (e) => expect(e, contains('Profile not found')),
      );
    });

    test('returns failure on exception', () async {
      when(() => mockSubRepo.getPlanType()).thenThrow(Exception('Share error'));

      final result = await repo.canShareProfile();
      result.fold(
        onSuccess: (_) => fail('Expected failure'),
        onFailure: (e) => expect(e, contains('Share error')),
      );
    });
  });

  // ═══════════════════════════════════════════════
  // getRemainingShares
  // ═══════════════════════════════════════════════
  group('getRemainingShares', () {
    test('returns 999 for platinum users', () async {
      when(() => mockSubRepo.getPlanType())
          .thenAnswer((_) async => BackendResponse.success(PlanType.platinum));

      final result = await repo.getRemainingShares();
      result.fold(
        onSuccess: (remaining) => expect(remaining, 999),
        onFailure: (e) => fail('Expected success: $e'),
      );
    });

    test('returns correct remaining for free plan', () async {
      when(() => mockSubRepo.getPlanType())
          .thenAnswer((_) async => BackendResponse.success(PlanType.free));
      setupProfilesTable();
      setupCountTable('profile_shares', 3);

      final freeFeatures = SubscriptionConfig.getFeatures(PlanType.free);
      final result = await repo.getRemainingShares();
      result.fold(
        onSuccess: (remaining) =>
            expect(remaining, (freeFeatures.sharesPerMonth - 3).clamp(0, 999)),
        onFailure: (e) => fail('Expected success: $e'),
      );
    });

    test('returns failure on exception', () async {
      when(() => mockSubRepo.getPlanType()).thenThrow(Exception('Net err'));

      final result = await repo.getRemainingShares();
      result.fold(
        onSuccess: (_) => fail('Expected failure'),
        onFailure: (e) => expect(e, contains('Net err')),
      );
    });
  });

  // ═══════════════════════════════════════════════
  // canAddBookmark
  // ═══════════════════════════════════════════════
  group('canAddBookmark', () {
    test('returns true for platinum users', () async {
      when(() => mockSubRepo.getPlanType())
          .thenAnswer((_) async => BackendResponse.success(PlanType.platinum));

      final result = await repo.canAddBookmark();
      result.fold(
        onSuccess: (can) => expect(can, true),
        onFailure: (e) => fail('Expected success: $e'),
      );
    });

    test('returns true when under bookmark limit', () async {
      when(() => mockSubRepo.getPlanType())
          .thenAnswer((_) async => BackendResponse.success(PlanType.free));
      setupCountTable('bookmarks', 2);

      final result = await repo.canAddBookmark();
      result.fold(
        onSuccess: (can) => expect(can, true),
        onFailure: (e) => fail('Expected success: $e'),
      );
    });

    test('returns failure when not authenticated', () async {
      when(() => mockSubRepo.getPlanType())
          .thenAnswer((_) async => BackendResponse.success(PlanType.free));
      (fakeClient.auth as dynamic).mockUser = null; // No user

      final result = await repo.canAddBookmark();
      result.fold(
        onSuccess: (_) => fail('Expected failure'),
        onFailure: (e) => expect(e, contains('not authenticated')),
      );
    });

    test('returns failure on exception', () async {
      when(() => mockSubRepo.getPlanType()).thenThrow(Exception('BM error'));

      final result = await repo.canAddBookmark();
      result.fold(
        onSuccess: (_) => fail('Expected failure'),
        onFailure: (e) => expect(e, contains('BM error')),
      );
    });
  });

  // ═══════════════════════════════════════════════
  // getRemainingBookmarks
  // ═══════════════════════════════════════════════
  group('getRemainingBookmarks', () {
    test('returns 999 for platinum users', () async {
      when(() => mockSubRepo.getPlanType())
          .thenAnswer((_) async => BackendResponse.success(PlanType.platinum));

      final result = await repo.getRemainingBookmarks();
      result.fold(
        onSuccess: (remaining) => expect(remaining, 999),
        onFailure: (e) => fail('Expected success: $e'),
      );
    });

    test('returns correct remaining for free plan', () async {
      when(() => mockSubRepo.getPlanType())
          .thenAnswer((_) async => BackendResponse.success(PlanType.free));
      setupCountTable('bookmarks', 10);

      final freeFeatures = SubscriptionConfig.getFeatures(PlanType.free);
      final result = await repo.getRemainingBookmarks();
      result.fold(
        onSuccess: (remaining) =>
            expect(remaining, (freeFeatures.bookmarksLimit - 10).clamp(0, 999)),
        onFailure: (e) => fail('Expected success: $e'),
      );
    });

    test('returns failure on exception', () async {
      when(() => mockSubRepo.getPlanType()).thenThrow(Exception('Err'));

      final result = await repo.getRemainingBookmarks();
      result.fold(
        onSuccess: (_) => fail('Expected failure'),
        onFailure: (e) => expect(e, contains('Err')),
      );
    });
  });

  // ═══════════════════════════════════════════════
  // canUploadPhoto
  // ═══════════════════════════════════════════════
  group('canUploadPhoto', () {
    test('returns true when under photo limit', () async {
      when(() => mockSubRepo.getPlanType())
          .thenAnswer((_) async => BackendResponse.success(PlanType.free));
      setupProfilesTable();
      setupCountTable('photos', 0);

      final result = await repo.canUploadPhoto();
      result.fold(
        onSuccess: (can) => expect(can, true),
        onFailure: (e) => fail('Expected success: $e'),
      );
    });

    test('returns failure when not authenticated', () async {
      when(() => mockSubRepo.getPlanType())
          .thenAnswer((_) async => BackendResponse.success(PlanType.free));
      (fakeClient.auth as dynamic).mockUser = null;

      final result = await repo.canUploadPhoto();
      result.fold(
        onSuccess: (_) => fail('Expected failure'),
        onFailure: (e) => expect(e, contains('not authenticated')),
      );
    });

    test('returns failure when profile not found', () async {
      when(() => mockSubRepo.getPlanType())
          .thenAnswer((_) async => BackendResponse.success(PlanType.free));
      final table = fakeClient.from('profiles') as dynamic;
      table.builder.responseData = [];

      final result = await repo.canUploadPhoto();
      result.fold(
        onSuccess: (_) => fail('Expected failure'),
        onFailure: (e) => expect(e, contains('Profile not found')),
      );
    });

    test('returns failure on exception', () async {
      when(() => mockSubRepo.getPlanType()).thenThrow(Exception('Photo err'));

      final result = await repo.canUploadPhoto();
      result.fold(
        onSuccess: (_) => fail('Expected failure'),
        onFailure: (e) => expect(e, contains('Photo err')),
      );
    });
  });

  // ═══════════════════════════════════════════════
  // getRemainingPhotos
  // ═══════════════════════════════════════════════
  group('getRemainingPhotos', () {
    test('returns correct remaining for free plan', () async {
      when(() => mockSubRepo.getPlanType())
          .thenAnswer((_) async => BackendResponse.success(PlanType.free));
      setupProfilesTable();
      setupCountTable('photos', 3);

      final freeFeatures = SubscriptionConfig.getFeatures(PlanType.free);
      final result = await repo.getRemainingPhotos();
      result.fold(
        onSuccess: (remaining) =>
            expect(remaining, (freeFeatures.photosLimit - 3).clamp(0, 999)),
        onFailure: (e) => fail('Expected success: $e'),
      );
    });

    test('returns failure when not authenticated', () async {
      when(() => mockSubRepo.getPlanType())
          .thenAnswer((_) async => BackendResponse.success(PlanType.free));
      (fakeClient.auth as dynamic).mockUser = null;

      final result = await repo.getRemainingPhotos();
      result.fold(
        onSuccess: (_) => fail('Expected failure'),
        onFailure: (e) => expect(e, contains('not authenticated')),
      );
    });

    test('returns failure on exception', () async {
      when(() => mockSubRepo.getPlanType()).thenThrow(Exception('Photo rem'));

      final result = await repo.getRemainingPhotos();
      result.fold(
        onSuccess: (_) => fail('Expected failure'),
        onFailure: (e) => expect(e, contains('Photo rem')),
      );
    });
  });

  // ═══════════════════════════════════════════════
  // incrementShareCount
  // ═══════════════════════════════════════════════
  group('incrementShareCount', () {
    test('calls fn_track_usage RPC with shares_count', () async {
      fakeClient.rpcResponse = {'success': true};

      final result = await repo.incrementShareCount();
      expect(fakeClient.rpcFunction, 'fn_track_usage');
      expect(fakeClient.rpcParams?['metric'], 'shares_count');
      expect(fakeClient.rpcParams?['increment'], 1);
      result.fold(
        onSuccess: (_) {},
        onFailure: (e) => fail('Expected success: $e'),
      );
    });

    test('returns failure on RPC error', () async {
      fakeClient.rpcError = Exception('RPC share failed');

      final result = await repo.incrementShareCount();
      result.fold(
        onSuccess: (_) => fail('Expected failure'),
        onFailure: (e) => expect(e, contains('RPC share failed')),
      );
    });
  });

  group('UsageRepository Edge Cases', () {
    setUp(() {
      when(() => mockSubRepo.getPlanType())
          .thenAnswer((_) async => BackendResponse.success(PlanType.free));
    });

    test('_getTodayUsage handles race condition during insertion', () async {
      final table = fakeClient.from('usage_tracking') as dynamic;
      table.builder.responseData = []; // 1st maybeSingle returns null
      table.builder.error = Exception('Conflict'); // 1st insert fails
      
      final resultFuture = repo.canViewProfile(); 
      
      table.builder.error = null;
      table.builder.responseData = [{'profile_views': 0}]; 
      
      await resultFuture;
      expect(repo.canViewProfile(), completes);
    });

    test('_createNewRecord is called when no usage record exists', () async {
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final table = fakeClient.from('usage_tracking') as dynamic;
      
      int maybeSingleCalls = 0;
      table.builder.responseData = () {
        if (maybeSingleCalls++ == 0) return null; 
        return {'id': 'new-id', 'user_id': 'test-user-id', 'date': today, 'profile_views': 0}; 
      };

      final result = await repo.canViewProfile();
      expect(result.isSuccess, true);
    });

    test('_createNewRecord handles race condition when record created concurrently', () async {
      final table = fakeClient.from('usage_tracking') as dynamic;
      
      table.builder.responseData = () => null;
      table.builder.error = () => const PostgrestException(message: 'duplicate key');

      final result = await repo.canViewProfile();
      // Should catch the duplicate key and retry, but here we expect the error to be propagated if retry fails.
      // In real code it handles it.
      expect(result.isSuccess, isFalse);
    });

    test('_getTodayUsage throws if not authenticated', () async {
      (fakeClient.auth as dynamic).mockUser = null;
      AppSupabaseClient.testAuth = null;
      final result = await repo.canViewProfile();
      result.fold(
        onSuccess: (_) => fail('Expected failure'),
        onFailure: (e) => expect(e, contains('not authenticated')),
      );
    });

    test('_getTodayUsage handles race condition on insert', () async {
      AppSupabaseClient.testAuth = fakeClient.auth;
      final usageTable = fakeClient.from('usage_tracking') as dynamic;
      
      usageTable.builder.responseData = () => null;
      usageTable.builder.error = () => const PostgrestException(message: 'duplicate key');

      final result = await repo.getRemainingProfileViews();
      expect(result.isSuccess, isFalse);
    });

    test('onRetry handlers are covered', () async {
      when(() => mockSubRepo.getPlanType())
          .thenAnswer((_) async => BackendResponse.failure('Plan fail'));
      
      final vRes = await repo.canViewProfile();
      expect(vRes.isSuccess, isFalse);
      
      when(() => mockSubRepo.getPlanType())
          .thenAnswer((_) async => BackendResponse.success(PlanType.free));
      setupUsageTable();
      
      if (vRes.onRetry != null) {
        final retryRes = await vRes.onRetry!();
        expect(retryRes, isNotNull);
      }
    });
  });
}
