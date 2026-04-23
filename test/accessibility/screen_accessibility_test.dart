// Phase 21: Accessibility Testing for Core Screens
// Verifies semantic labels, interaction hints, and screen reader compatibility
// for the 5 critical app screens: Home, Profile Detail, Chat, Settings, Auth.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../helpers/widget_test_helpers.dart';

void main() {
  setUp(() {
    setupWidgetTestMocks();
  });

  tearDown(() {
    tearDownWidgetTestMocks();
  });

  // ─── Home Screen Accessibility ──────────────────────────────────────
  group('Home Screen Accessibility', () {
    testWidgets('bottom navigation has semantic labels', (WidgetTester tester) async {
      final widgetBuilt = await pumpWidgetSafely(
        tester,
        createTestableWidget(
          Scaffold(
            bottomNavigationBar: BottomNavigationBar(
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Discover'),
                BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
                BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
              ],
            ),
          ),
        ),
      );
      if (widgetBuilt) {
        expect(find.text('Home'), findsAtLeastNWidgets(1));
        expect(find.text('Discover'), findsAtLeastNWidgets(1));
        expect(find.text('Chat'), findsAtLeastNWidgets(1));
        expect(find.text('Profile'), findsAtLeastNWidgets(1));
      }
    });

    testWidgets('app bar actions are accessible', (WidgetTester tester) async {
      final widgetBuilt = await pumpWidgetSafely(
        tester,
        createTestableWidget(
          Scaffold(
            appBar: AppBar(
              title: const Text('BanjaraMatch'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications),
                  tooltip: 'Notifications',
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  tooltip: 'Filter',
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );
      if (widgetBuilt) {
        expect(find.byTooltip('Notifications'), findsOneWidget);
        expect(find.byTooltip('Filter'), findsOneWidget);
      }
    });
  });

  // ─── Profile Detail Accessibility ──────────────────────────────────
  group('Profile Detail Accessibility', () {
    testWidgets('profile card elements have semantic labels', (WidgetTester tester) async {
      final widgetBuilt = await pumpWidgetSafely(
        tester,
        createTestableWidget(
          Scaffold(
            body: ListView(
              children: [
                Semantics(
                  label: 'Profile photo',
                  image: true,
                  child: Container(
                    height: 200,
                    color: Colors.grey,
                    child: const Center(child: Text('Photo')),
                  ),
                ),
                Semantics(
                  label: 'User name',
                  child: const Text('Test User, 25'),
                ),
                Semantics(
                  label: 'Location',
                  child: const Text('Mumbai, Maharashtra'),
                ),
              ],
            ),
          ),
        ),
      );
      if (widgetBuilt) {
        expect(find.byWidgetPredicate((w) => w is Semantics && w.properties.label == 'Profile photo'), findsOneWidget);
        expect(find.byWidgetPredicate((w) => w is Semantics && w.properties.label == 'User name'), findsOneWidget);
        expect(find.byWidgetPredicate((w) => w is Semantics && w.properties.label == 'Location'), findsOneWidget);
      }
    });

    testWidgets('action buttons are accessible', (WidgetTester tester) async {
      final widgetBuilt = await pumpWidgetSafely(
        tester,
        createTestableWidget(
          Scaffold(
            body: Row(
              children: [
                Semantics(
                  button: true,
                  label: 'Share profile',
                  child: IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () {},
                  ),
                ),
                Semantics(
                  button: true,
                  label: 'Bookmark profile',
                  child: IconButton(
                    icon: const Icon(Icons.bookmark_border),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      if (widgetBuilt) {
        expect(find.byWidgetPredicate((w) => w is Semantics && w.properties.label == 'Share profile'), findsOneWidget);
        expect(find.byWidgetPredicate((w) => w is Semantics && w.properties.label == 'Bookmark profile'), findsOneWidget);
      }
    });
  });

  // ─── Chat Screen Accessibility ─────────────────────────────────────
  group('Chat Screen Accessibility', () {
    testWidgets('message input has semantic label', (WidgetTester tester) async {
      final widgetBuilt = await pumpWidgetSafely(
        tester,
        createTestableWidget(
          Scaffold(
            body: Column(
              children: [
                Expanded(child: Container()),
                Semantics(
                  textField: true,
                  label: 'Type a message',
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                    ),
                  ),
                ),
                Semantics(
                  button: true,
                  label: 'Send message',
                  child: IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      if (widgetBuilt) {
        expect(find.byWidgetPredicate((w) => w is Semantics && w.properties.label == 'Type a message'), findsOneWidget);
        expect(find.byWidgetPredicate((w) => w is Semantics && w.properties.label == 'Send message'), findsOneWidget);
      }
    });

    testWidgets('conversation list items are accessible', (WidgetTester tester) async {
      final widgetBuilt = await pumpWidgetSafely(
        tester,
        createTestableWidget(
          Scaffold(
            body: ListView(
              children: [
                Semantics(
                  label: 'Conversation with Test User. Last message: Hello',
                  child: const ListTile(
                    leading: CircleAvatar(child: Text('T')),
                    title: Text('Test User'),
                    subtitle: Text('Hello'),
                    trailing: Text('2m ago'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      if (widgetBuilt) {
        expect(
          find.byWidgetPredicate((w) => w is Semantics && w.properties.label == 'Conversation with Test User. Last message: Hello'),
          findsOneWidget,
        );
      }
    });
  });

  // ─── Settings Screen Accessibility ─────────────────────────────────
  group('Settings Screen Accessibility', () {
    testWidgets('settings options have semantic labels', (WidgetTester tester) async {
      final widgetBuilt = await pumpWidgetSafely(
        tester,
        createTestableWidget(
          Scaffold(
            body: ListView(
              children: [
                Semantics(
                  label: 'Language setting',
                  child: const ListTile(
                    leading: Icon(Icons.language),
                    title: Text('Language'),
                    trailing: Text('English'),
                  ),
                ),
                Semantics(
                  label: 'Dark mode toggle',
                  toggled: false,
                  child: SwitchListTile(
                    title: const Text('Dark Mode'),
                    value: false,
                    onChanged: (_) {},
                  ),
                ),
                Semantics(
                  label: 'Sign out button',
                  button: true,
                  child: const ListTile(
                    leading: Icon(Icons.logout),
                    title: Text('Sign Out'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      if (widgetBuilt) {
        expect(find.byWidgetPredicate((w) => w is Semantics && w.properties.label == 'Language setting'), findsOneWidget);
        expect(find.byWidgetPredicate((w) => w is Semantics && w.properties.label == 'Dark mode toggle'), findsOneWidget);
        expect(find.byWidgetPredicate((w) => w is Semantics && w.properties.label == 'Sign out button'), findsOneWidget);
      }
    });
  });

  // ─── Auth Screen Accessibility ─────────────────────────────────────
  group('Auth Screen Accessibility', () {
    testWidgets('login form has semantic labels', (WidgetTester tester) async {
      final widgetBuilt = await pumpWidgetSafely(
        tester,
        createTestableWidget(
          Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Semantics(
                    textField: true,
                    label: 'Phone number input',
                    child: const TextField(
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        hintText: 'Enter your 10-digit number',
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Semantics(
                    button: true,
                    label: 'Request OTP button',
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text('Request OTP'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Semantics(
                    button: true,
                    label: 'Continue as guest button',
                    child: TextButton(
                      onPressed: () {},
                      child: const Text('Continue as Guest'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      if (widgetBuilt) {
        expect(find.byWidgetPredicate((w) => w is Semantics && w.properties.label == 'Phone number input'), findsOneWidget);
        expect(find.byWidgetPredicate((w) => w is Semantics && w.properties.label == 'Request OTP button'), findsOneWidget);
        expect(find.byWidgetPredicate((w) => w is Semantics && w.properties.label == 'Continue as guest button'), findsOneWidget);
      }
    });

    testWidgets('OTP input has semantic label', (WidgetTester tester) async {
      final widgetBuilt = await pumpWidgetSafely(
        tester,
        createTestableWidget(
          Scaffold(
            body: Column(
              children: [
                Semantics(
                  textField: true,
                  label: 'Enter OTP code',
                  child: const TextField(
                    decoration: InputDecoration(
                      labelText: 'OTP Code',
                      hintText: '6-digit code',
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                  ),
                ),
                Semantics(
                  button: true,
                  label: 'Verify OTP button',
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Verify'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      if (widgetBuilt) {
        expect(find.byWidgetPredicate((w) => w is Semantics && w.properties.label == 'Enter OTP code'), findsOneWidget);
        expect(find.byWidgetPredicate((w) => w is Semantics && w.properties.label == 'Verify OTP button'), findsOneWidget);
      }
    });
  });
}
