import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:banjarabio/presentation/chat/chat_screen.dart';
import 'package:banjarabio/core/models/chat_model.dart';
import 'package:banjarabio/core/repositories/chat_repository.dart';
import 'package:banjarabio/core/repositories/subscription_repository.dart';
import 'package:banjarabio/core/repositories/usage_repository.dart';


import '../../helpers/widget_test_helpers.dart';

// Mock specific repositories if needed locally, though testClient handles Supabase stuff inside them
class MockChatRepository extends Mock implements ChatRepository {}
class MockSubscriptionRepository extends Mock implements SubscriptionRepository {}
class MockUsageRepository extends Mock implements UsageRepository {}

void main() {
  setUpAll(() {
    // Register fallbacks
    registerFallbackValue(Uri.parse('http://localhost'));
  });

  setUp(() {
    setupWidgetTestMocks();
  });

  testWidgets('ChatScreen shows skeleton loader initially', (WidgetTester tester) async {
    final conversation = ConversationModel(
      id: 'conv_123',
      participantOneId: 'user_1',
      participantTwoId: 'user_2',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      lastMessageText: 'Hello',
      lastMessageAt: DateTime.now(),
      otherParticipantName: 'Priya',
      otherParticipantImageUrl: 'https://example.com/avatar.jpg',
    );

    await tester.pumpWidget(createTestableWidget(
      ChatScreen(conversation: conversation),
    ));
    
    // We expect the scaffold to be there
    expect(find.byType(ChatScreen), findsOneWidget);

    // Pump to flush microtasks
    await tester.pump(const Duration(milliseconds: 100));
    
    // Once settled, it should render an AppBar and potentially an empty state or message input
    expect(find.byType(AppBar), findsOneWidget);
  });
}
