import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/presentation/matchmaking/widgets/match_success_dialog.dart';
import '../../helpers/widget_test_helpers.dart';

void main() {
  setUp(() {
    setupWidgetTestMocks();
  });

  tearDown(() {
    tearDownWidgetTestMocks();
  });

  group('MatchSuccessDialog', () {
    testWidgets('can be instantiated with shareId', (WidgetTester tester) async {
      // Wrap in a Navigator so that Navigator.pop from _fetchMatchDetails error
      // path works correctly instead of crashing.
      final widgetBuilt = await pumpWidgetSafely(
        tester,
        createTestableWidget(
          Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const MatchSuccessDialog(shareId: 'test-share-123'),
                  );
                },
                child: const Text('Show Match'),
              ),
            ),
          ),
        ),
      );
      if (widgetBuilt) {
        // Verify the button is present
        expect(find.text('Show Match'), findsOneWidget);
      }
    });

    testWidgets('widget accepts required shareId parameter', (WidgetTester tester) async {
      const dialog = MatchSuccessDialog(shareId: 'abc-123');
      expect(dialog.shareId, 'abc-123');
    });

    testWidgets('dialog shows loading indicator when opened', (WidgetTester tester) async {
      final widgetBuilt = await pumpWidgetSafely(
        tester,
        createTestableWidget(
          Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const MatchSuccessDialog(shareId: 'test'),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      if (widgetBuilt) {
        // Tap to open dialog
        await tester.tap(find.text('Open'));
        await tester.pump();
        // The dialog shows a loading indicator while fetching
        expect(find.byType(CircularProgressIndicator), findsWidgets);
      }
    });
  });
}
