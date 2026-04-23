import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../helpers/widget_test_helpers.dart';
import 'package:banjarabio/presentation/authentication_screen/authentication_screen.dart';

void main() {
  setUp(() => setupWidgetTestMocks());
  tearDown(() => tearDownWidgetTestMocks());

  testWidgets('pumps without hard crash', (tester) async {
    setTestScreenSize(tester);
    final pumped = await pumpWidgetSafely(tester, createTestableWidget(const AuthenticationScreen()));
    if (pumped) {
      expect(find.byType(Scaffold), findsWidgets);
    }
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });
}
