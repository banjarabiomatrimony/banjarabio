import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/widgets/branded_refresh_indicator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BrandedRefreshIndicator Tests', () {
    testWidgets('renders child widget inside RefreshIndicator', (tester) async {
      var refreshed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BrandedRefreshIndicator(
              onRefresh: () async {
                refreshed = true;
              },
              child: ListView(
                children: const [
                  Text('Item 1'),
                  Text('Item 2'),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
      expect(find.byType(RefreshIndicator), findsOneWidget);
      expect(refreshed, isFalse);
    });
  });
}
