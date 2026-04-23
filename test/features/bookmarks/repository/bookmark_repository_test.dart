import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:banjarabio/features/bookmarks/repository/bookmark_repository_impl.dart';

// Mock Supabase client
class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockAuth extends Mock implements GoTrueClient {}

class MockUser extends Mock implements User {}

// Fake for RPC calls (similar to share_repository_test pattern)
class FakeRpcResponse extends Fake
    implements PostgrestFilterBuilder<Map<String, dynamic>> {
  final Map<String, dynamic> _result;
  FakeRpcResponse(this._result);

  @override
  Future<R> then<R>(
    FutureOr<R> Function(Map<String, dynamic> value) onValue, {
    Function? onError,
  }) {
    return Future.value(_result).then(onValue, onError: onError);
  }
}

// Fake for query builder chain
class FakeQueryBuilderList extends Fake
    implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {
  final List<Map<String, dynamic>> _result;
  FakeQueryBuilderList(this._result);

  @override
  Future<R> then<R>(
    FutureOr<R> Function(List<Map<String, dynamic>> value) onValue, {
    Function? onError,
  }) {
    return Future.value(_result).then(onValue, onError: onError);
  }
}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class MockPostgrestFilterBuilderList extends Mock
    implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {}

void main() {
  group('BookmarkRepositoryImpl', () {
    late MockSupabaseClient mockSupabase;
    late MockAuth mockAuth;
    late MockUser mockUser;
    late BookmarkRepositoryImpl repository;

    setUp(() {
      mockSupabase = MockSupabaseClient();
      mockAuth = MockAuth();
      mockUser = MockUser();

      when(() => mockSupabase.auth).thenReturn(mockAuth);
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.id).thenReturn('user-123');

      repository = BookmarkRepositoryImpl(supabase: mockSupabase);
    });

    tearDown(() {
      resetMocktailState();
    });

    test('toggleBookmark calls correct RPC with add action', () async {
      final rpcResponse = {
        'status': 'success',
        'is_bookmarked': true,
      };

      when(() => mockSupabase.rpc('fn_manage_bookmarks', params: any(named: 'params')))
          .thenAnswer((_) => FakeRpcResponse(rpcResponse));

      final result = await repository.toggleBookmark('profile-1', true);

      expect(result.isSuccess, true);
      verify(() => mockSupabase.rpc('fn_manage_bookmarks', params: any(named: 'params'))).called(1);
    });

    test('toggleBookmark calls correct RPC with remove action', () async {
      final rpcResponse = {
        'status': 'success',
        'is_bookmarked': false,
      };

      when(() => mockSupabase.rpc('fn_manage_bookmarks', params: any(named: 'params')))
          .thenAnswer((_) => FakeRpcResponse(rpcResponse));

      final result = await repository.toggleBookmark('profile-1', false);

      expect(result.isSuccess, true);
      verify(() => mockSupabase.rpc('fn_manage_bookmarks', params: any(named: 'params'))).called(1);
    });

    test('toggleBookmark handles duplicate error gracefully', () async {
      // Simulate exception with duplicate message
      when(() => mockSupabase.rpc('fn_manage_bookmarks', params: any(named: 'params')))
          .thenThrow(Exception('duplicate key value'));

      final result = await repository.toggleBookmark('profile-1', true);

      expect(result.isSuccess, true);
    });

    test('getBookmarkedProfileIds returns failure when not authenticated', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      final result = await repository.getBookmarkedProfileIds();

      expect(result.isSuccess, false);
      expect(result.errorMessage, 'Not authenticated');
    });

    test('getBookmarkedProfileIds returns list of IDs when authenticated', () async {
      final mockQueryBuilder = MockSupabaseQueryBuilder();
      final mockFilterBuilder = MockPostgrestFilterBuilderList();
      final fakeQuery = FakeQueryBuilderList([
        {'profile_id': 'profile-1'},
        {'profile_id': 'profile-2'},
      ]);

      when(() => mockSupabase.from('bookmarks')).thenAnswer((_) => mockQueryBuilder);
      when(() => mockQueryBuilder.select('profile_id'))
          .thenAnswer((_) => mockFilterBuilder);
      when(() => mockFilterBuilder.eq('user_id', 'user-123'))
          .thenAnswer((_) => fakeQuery);

      final result = await repository.getBookmarkedProfileIds();

      expect(result.isSuccess, true);
      expect(result.data, ['profile-1', 'profile-2']);
    });

    test('clearAllBookmarks calls correct RPC', () async {
      final rpcResponse = {
        'status': 'success',
        'message': 'All bookmarks cleared',
      };

      when(() => mockSupabase.rpc('fn_manage_bookmarks', params: any(named: 'params')))
          .thenAnswer((_) => FakeRpcResponse(rpcResponse));

      final result = await repository.clearAllBookmarks();

      expect(result.isSuccess, true);
      verify(() => mockSupabase.rpc('fn_manage_bookmarks', params: any(named: 'params'))).called(1);
    });
  });
}
