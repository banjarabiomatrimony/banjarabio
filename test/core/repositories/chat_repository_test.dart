import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:banjarabio/core/repositories/chat_repository.dart';
import 'package:banjarabio/core/session_manager.dart';
import '../../helpers/supabase_fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FakeSupabaseClient fakeSupabase;
  late ChatRepository repository;

  setUp(() {
    fakeSupabase = FakeSupabaseClient();
    repository = ChatRepository()..testClient = fakeSupabase;

    // Initialize SessionManager with fake prefs containing profile_id
    SessionManager.instance.testPrefs = FakeSharedPreferences({
      'profile_id': 'test-profile-id',
    });

    // Setup authenticated user on fakeSupabase
    (fakeSupabase.auth as dynamic).mockUser = const User(
      id: 'test-user-id',
      appMetadata: {},
      userMetadata: {},
      aud: '',
      createdAt: '',
    );
  });

  tearDown(() {
    SessionManager.instance.testPrefs = null;
  });

  group('ChatRepository', () {
    // ═══════════════════════════════════════════════
    // getConversationsStream
    // ═══════════════════════════════════════════════
    test('getConversationsStream returns mapped ConversationModel stream', () async {
      fakeSupabase.setTableData('conversations_view', [
        {
          'id': 'c1',
          'participant_one_id': 'test-user-id',
          'participant_two_id': 'u2',
          'last_message_text': 'hello',
          'last_message_at': DateTime.now().toIso8601String(),
          'unread_count_one': 0,
          'unread_count_two': 1,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        }
      ]);

      final stream = repository.getConversationsStream();
      final result = await stream.first;

      expect(result.length, 1);
      expect(result.first.id, 'c1');
      expect(result.first.lastMessageText, 'hello');
    });

    test('getConversationsStream returns empty when no user', () async {
      (fakeSupabase.auth as dynamic).mockUser = null;
      final stream = repository.getConversationsStream();
      final result = await stream.first;
      expect(result, isEmpty);
    });

    // ═══════════════════════════════════════════════
    // getMessagesStream
    // ═══════════════════════════════════════════════
    test('getMessagesStream returns mapped MessageModel stream', () async {
      fakeSupabase.setTableData('messages', [
        {
          'id': 'm1',
          'conversation_id': 'c1',
          'sender_id': 'test-user-id',
          'message_text': 'hi there',
          'is_read': true,
          'created_at': DateTime.now().toIso8601String(),
        }
      ]);

      final stream = repository.getMessagesStream('c1');
      final result = await stream.first;

      expect(result.length, 1);
      expect(result.first.id, 'm1');
      expect(result.first.messageText, 'hi there');
    });

    // ═══════════════════════════════════════════════
    // sendMessage
    // ═══════════════════════════════════════════════
    test('sendMessage calls RPC and returns success', () async {
      fakeSupabase.rpcResponse = {
        'id': 'm1',
        'created_at': DateTime.now().toIso8601String(),
      };

      final result = await repository.sendMessage('c1', 'hello');

      expect(result.isSuccess, true);
      expect(result.data.id, 'm1');
      expect(result.data.messageText, 'hello');
      expect(result.data.conversationId, 'c1');
      expect(result.data.senderId, 'test-profile-id');
      expect(fakeSupabase.rpcFunction, 'fn_manage_chat');
      expect(fakeSupabase.rpcParams?['action'], 'send_message');
    });

    test('sendMessage returns failure on RPC error', () async {
      fakeSupabase.rpcError = Exception('Failed to send');

      final result = await repository.sendMessage('c1', 'hello');

      expect(result.isSuccess, false);
      expect(result.errorMessage, contains('Failed to send'));
    });

    // ═══════════════════════════════════════════════
    // markAsRead
    // ═══════════════════════════════════════════════
    test('markAsRead calls RPC with correct action', () async {
      fakeSupabase.rpcResponse = {'status': 'success'};

      await repository.markAsRead('c1');

      expect(fakeSupabase.rpcFunction, 'fn_manage_chat');
      expect(fakeSupabase.rpcParams?['action'], 'mark_as_read');
    });

    test('markAsRead catches errors silently', () async {
      fakeSupabase.rpcError = Exception('Network error');

      // Should not throw
      await repository.markAsRead('c1');
    });

    // ═══════════════════════════════════════════════
    // getOrCreateConversation
    // ═══════════════════════════════════════════════
    test('getOrCreateConversation returns success', () async {
      fakeSupabase.rpcResponse = {
        'id': 'conv-1',
        'participant_one_id': 'test-user-id',
        'participant_two_id': 'other-user',
        'last_message_text': null,
        'last_message_at': DateTime.now().toIso8601String(),
        'unread_count_one': 0,
        'unread_count_two': 0,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final result = await repository.getOrCreateConversation('other-user');

      expect(result.isSuccess, true);
      expect(result.data.id, 'conv-1');
      expect(fakeSupabase.rpcParams?['action'], 'get_or_create_conversation');
    });

    test('getOrCreateConversation returns failure on invalid response', () async {
      fakeSupabase.rpcResponse = 'not a map';

      final result = await repository.getOrCreateConversation('other-user');

      expect(result.isSuccess, false);
      expect(result.errorMessage, contains('Invalid'));
    });

    test('getOrCreateConversation returns failure on RPC error', () async {
      fakeSupabase.rpcError = Exception('RPC error');

      final result = await repository.getOrCreateConversation('other-user');

      expect(result.isSuccess, false);
    });

    // ═══════════════════════════════════════════════
    // getWhoViewedMe
    // ═══════════════════════════════════════════════
    test('getWhoViewedMe returns mapped ProfileViewModel list', () async {
      fakeSupabase.setTableData('profile_views', [
        {
          'id': 'v1',
          'viewer_id': 'u2',
          'viewed_id': 'test-profile-id',
          'view_count': 3,
          'last_viewed_at': DateTime.now().toIso8601String(),
          'viewer': {
            'full_name': 'Test User',
            'photos': [
              {'public_url': 'http://example.com/img.jpg'}
            ]
          }
        }
      ]);

      final result = await repository.getWhoViewedMe();

      expect(result.isSuccess, true);
      expect(result.data.length, 1);
      expect(result.data.first.viewerName, 'Test User');
      expect(result.data.first.viewCount, 3);
    });

    test('getWhoViewedMe returns failure when no profileId', () async {
      SessionManager.instance.testPrefs = FakeSharedPreferences();

      final result = await repository.getWhoViewedMe();

      expect(result.isSuccess, false);
      expect(result.errorMessage, contains('Not authenticated'));
    });

    // ═══════════════════════════════════════════════
    // trackView
    // ═══════════════════════════════════════════════
    test('trackView calls RPC with correct params', () async {
      fakeSupabase.rpcResponse = {'ok': true};

      await repository.trackView('u2');

      expect(fakeSupabase.rpcFunction, 'fn_manage_chat');
      expect(fakeSupabase.rpcParams?['action'], 'track_view');
    });

    test('trackView catches errors silently', () async {
      fakeSupabase.rpcError = Exception('Track error');

      // Should not throw
      await repository.trackView('u2');
    });
  });
}
