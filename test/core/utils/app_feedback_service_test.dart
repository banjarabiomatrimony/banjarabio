import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/utils/app_feedback_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppFeedback Service Tests', () {
    testWidgets('showError executes without exception', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  AppFeedback.showError(context, Exception('Database error'));
                },
                child: const Text('Trigger'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Trigger'));
      await tester.pump();
    });

    testWidgets('showSuccess, showInfo, showWarning execute without exception', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  AppFeedback.showSuccess(context, 'Success message');
                  AppFeedback.showInfo(context, 'Info message');
                  AppFeedback.showWarning(context, 'Warning message');
                },
                child: const Text('Trigger'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Trigger'));
      await tester.pump();
    });
  });
}
