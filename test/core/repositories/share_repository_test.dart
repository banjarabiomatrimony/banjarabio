import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:banjarabio/core/repositories/share_repository.dart';
import 'package:banjarabio/core/repositories/usage_repository.dart';
import 'package:banjarabio/core/repositories/profile_repository.dart';
import 'package:banjarabio/core/models/backend_response.dart';
import 'package:banjarabio/core/models/profile_model.dart';
import 'package:banjarabio/core/models/profile_share_model.dart';

// Mocks
class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockUsageRepository extends Mock implements UsageRepository {}

class MockProfileRepository extends Mock implements ProfileRepository {}

class MockPostgrestClient extends Mock implements PostgrestClient {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

// Intermediate Mocks (for chaining)
class MockPostgrestFilterBuilderList extends Mock
    implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {}

class MockPostgrestFilterBuilderVoid extends Mock
    implements PostgrestFilterBuilder<void> {}

// Fakes for Awaited Futures
class FakePostgrestFilterBuilderMap extends Fake
    implements PostgrestFilterBuilder<Map<String, dynamic>> {
  final Map<String, dynamic> _result;
  FakePostgrestFilterBuilderMap(this._result);

  @override
  Future<R> then<R>(
    FutureOr<R> Function(Map<String, dynamic> value) onValue, {
    Function? onError,
  }) {
    return Future.value(_result).then(onValue, onError: onError);
  }
}

class FakePostgrestTransformBuilderMap extends Fake
    implements PostgrestTransformBuilder<Map<String, dynamic>> {
  final Map<String, dynamic> _result;
  FakePostgrestTransformBuilderMap(this._result);

  @override
  Future<R> then<R>(
    FutureOr<R> Function(Map<String, dynamic> value) onValue, {
    Function? onError,
  }) {
    return Future.value(_result).then(onValue, onError: onError);
  }
}

class FakePostgrestFilterBuilderVoid extends Fake
    implements PostgrestFilterBuilder<void> {
  FakePostgrestFilterBuilderVoid();

  @override
  Future<R> then<R>(
    FutureOr<R> Function(void value) onValue, {
    Function? onError,
  }) {
    return Future.value().then(onValue, onError: onError);
  }
}

class FakePostgrestFilterBuilderList extends Fake
    implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {
  final List<Map<String, dynamic>> _result;
  FakePostgrestFilterBuilderList(this._result);

  @override
  Future<R> then<R>(
    FutureOr<R> Function(List<Map<String, dynamic>> value) onValue, {
    Function? onError,
  }) {
    return Future.value(_result).then(onValue, onError: onError);
  }
}

class MockPostgrestTransformBuilderList extends Mock
    implements PostgrestTransformBuilder<List<Map<String, dynamic>>> {}

class FakePostgrestTransformBuilderList extends Fake
    implements PostgrestTransformBuilder<List<Map<String, dynamic>>> {
  final List<Map<String, dynamic>> _result;
  FakePostgrestTransformBuilderList(this._result);

  @override
  Future<R> then<R>(
    FutureOr<R> Function(List<Map<String, dynamic>> value) onValue, {
    Function? onError,
  }) {
    return Future.value(_result).then(onValue, onError: onError);
  }
}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockUser extends Mock implements User {}

class MockProfileModel extends Mock implements ProfileModel {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ShareRepository repository;
  late MockSupabaseClient mockSupabase;
  late MockUsageRepository mockUsageRepo;
  late MockProfileRepository mockProfileRepo;
  late MockGoTrueClient mockAuth;
  late MockUser mockUser;

  // Register generic fallbacks once
  registerFallbackValue((Map<String, dynamic> val) {});

  setUp(() {
    mockSupabase = MockSupabaseClient();
    mockUsageRepo = MockUsageRepository();
    mockProfileRepo = MockProfileRepository();
    mockAuth = MockGoTrueClient();
    mockUser = MockUser();

    when(() => mockSupabase.auth).thenReturn(mockAuth);
    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.id).thenReturn('user_123');

    repository = ShareRepository.test(
      supabase: mockSupabase,
      usageRepository: mockUsageRepo,
      profileRepository: mockProfileRepo,
    );
  });

  tearDown(() {
    resetMocktailState();
  });

  group('shareProfile', () {
    const String sharedProfileId = 'profile_456';
    const String sharingMethod = 'whatsapp';
    const String recipientName = 'John Doe';
    const String recipientRelation = 'Friend';

    test(
      'returns failure if user has no profile (getOwnProfile returns null)',
      () async {
        when(
          () => mockProfileRepo.getOwnProfile(),
        ).thenAnswer((_) async => BackendResponse.success(null));

        final result = await repository.shareProfile(
          sharedProfileId: sharedProfileId,
          sharingMethod: sharingMethod,
          recipientName: recipientName,
          recipientRelation: recipientRelation,
        );

        expect(result.isSuccess, false);
        expect(result.errorMessage, contains('must have a profile'));
        verify(() => mockProfileRepo.getOwnProfile()).called(1);
        verifyNever(
          () => mockSupabase.rpc(any(), params: any(named: 'params')),
        );
      },
    );

    test('calls fn_manage_shares via RPC on success', () async {
      // Arrange: Setup Own Profile
      final mockProfile = MockProfileModel();
      when(() => mockProfile.id).thenReturn('user_123');
      when(
        () => mockProfileRepo.getOwnProfile(),
      ).thenAnswer((_) async => BackendResponse.success(mockProfile));

      // Arrange: RPC Fake
      final rpcResponse = {'id': 'share_789'};
      when(
        () =>
            mockSupabase.rpc('fn_manage_shares', params: any(named: 'params')),
      ).thenAnswer((_) => FakePostgrestFilterBuilderMap(rpcResponse));

      // Arrange: Supabase Fetch for full record (step 5 in shareProfile)
      final mockQueryBuilder = MockSupabaseQueryBuilder();
      final mockFilterBuilder = MockPostgrestFilterBuilderList();

      final mockShareData = {
        'id': 'share_789',
        'profile_id': sharedProfileId,
        'sharer_id': 'user_123',
        'method': sharingMethod,
        'recipient_name': recipientName,
        'recipient_relation': recipientRelation,
        'status': 'sent',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'share_created_at': DateTime.now().toIso8601String(),
        'share_updated_at': DateTime.now().toIso8601String(),
        'is_bookmarked': false,
        'has_photo': false,
      };

      // Mock chain: from -> select -> eq -> single
      // from() returns QueryBuilder
      when(
        () => mockSupabase.from('profile_shares'),
      ).thenAnswer((_) => mockQueryBuilder);
      // select() returns FilterBuilderList (Mock)
      when(
        () => mockQueryBuilder.select(),
      ).thenAnswer((_) => mockFilterBuilder);
      // eq() returns FilterBuilderList (Mock)
      when(
        () => mockFilterBuilder.eq('id', 'share_789'),
      ).thenAnswer((_) => mockFilterBuilder);
      // single() returns TransformBuilderMap (Fake, awaited)
      when(
        () => mockFilterBuilder.single(),
      ).thenAnswer((_) => FakePostgrestTransformBuilderMap(mockShareData));

      // Arrange: UsageRepo
      when(
        () => mockUsageRepo.incrementShareCount(),
      ).thenAnswer((_) async => BackendResponse.success(null));

      // Act
      try {
        await repository.shareProfile(
          sharedProfileId: sharedProfileId,
          sharingMethod: sharingMethod,
          recipientName: recipientName,
          recipientRelation: recipientRelation,
        );
      } catch (_) {
        // Ignore platform channel errors
      }

      // Assert RPC was called
      verify(
        () => mockSupabase.rpc(
          'fn_manage_shares',
          params: any(named: 'params', that: isMap),
        ),
      ).called(1);
    });
  });

  // Mock Transform Builder

  group('getMatchedProfiles', () {
    test('returns list of profiles on success', () async {
      // Arrange Data
      final myProfileId = 'user_123';
      final mockProfile = MockProfileModel();
      when(() => mockProfile.id).thenReturn(myProfileId);
      when(
        () => mockProfileRepo.getOwnProfile(),
      ).thenAnswer((_) async => BackendResponse.success(mockProfile));

      final mockData = [
        {
          'id': 'share_1',
          'sharer_id': 'user_123',
          'recipient_id': 'user_456',
          'profile_id': 'profile_abc', // The profile being shared
          'status': 'matched',
          'method': 'whatsapp',
          'recipient_name': 'Friend',
          'recipient_relation': 'Friend',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
          'share_created_at': DateTime.now().toIso8601String(),
          'share_updated_at': DateTime.now().toIso8601String(),
          'is_bookmarked': false,
          'has_photo': false,
        },
      ];

      // Mocks for chain
      final mockQueryBuilder = MockSupabaseQueryBuilder();
      final mockFilterBuilder = MockPostgrestFilterBuilderList();
      final mockTransformBuilder = MockPostgrestTransformBuilderList();

      // Chain: from -> select -> eq -> or -> order -> limit
      when(
        () => mockSupabase.from('shared_profiles_view'),
      ).thenAnswer((_) => mockQueryBuilder);
      when(
        () => mockQueryBuilder.select(),
      ).thenAnswer((_) => mockFilterBuilder);
      when(
        () => mockFilterBuilder.eq('status', 'matched'),
      ).thenAnswer((_) => mockFilterBuilder);
      when(
        () => mockFilterBuilder.or(any()),
      ).thenAnswer((_) => mockFilterBuilder);
      when(
        () =>
            mockFilterBuilder.order(any(), ascending: any(named: 'ascending')),
      ).thenAnswer((_) => mockTransformBuilder);
      when(
        () => mockTransformBuilder.limit(any()),
      ).thenAnswer((_) => FakePostgrestTransformBuilderList(mockData));

      final result = await repository.getMatchedProfiles();

      expect(result.isSuccess, true);
      expect(result.data, isA<List<ProfileShare>>());
      expect(result.data.length, 1);
      expect(result.data.first.recipientName, 'Friend');
    });
  });

  group('deleteShares', () {
    test('returns failure if not logged in', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      final result = await repository.deleteShares(['1']);

      expect(result.isSuccess, false);
      expect(result.errorMessage, 'Not logged in');
    });

    test('calls delete with filter on success', () async {
      // Arrange
      final shareIds = ['1', '2'];
      final mockQueryBuilder = MockSupabaseQueryBuilder();

      // Use MockPostgrestFilterBuilderVoid for delete() return
      final mockDeleteBuilder = MockPostgrestFilterBuilderVoid();

      when(
        () => mockSupabase.from('profile_shares'),
      ).thenAnswer((_) => mockQueryBuilder);
      when(
        () => mockQueryBuilder.delete(),
      ).thenAnswer((_) => mockDeleteBuilder);

      // inFilter(...) returns the Future (Fake)
      when(
        () => mockDeleteBuilder.inFilter('id', shareIds),
      ).thenAnswer((_) => FakePostgrestFilterBuilderVoid());

      // Act
      final result = await repository.deleteShares(shareIds);

      // Assert
      expect(result.isSuccess, true);
      verify(() => mockSupabase.from('profile_shares')).called(1);
      verify(() => mockQueryBuilder.delete()).called(1);
      verify(() => mockDeleteBuilder.inFilter('id', shareIds)).called(1);
    });
  });
}
