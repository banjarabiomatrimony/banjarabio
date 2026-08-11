import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../helpers/widget_test_helpers.dart';
import 'package:banjarabio/presentation/user_type_selection_screen/user_type_selection_screen.dart';

void main() {
  setUp(() => setupWidgetTestMocks());
  tearDown(() => tearDownWidgetTestMocks());

  testWidgets('renders UserTypeSelectionScreen Scaffold', (tester) async {
    setTestScreenSize(tester);
    await tester.pumpWidget(createTestableWidget(const UserTypeSelectionScreen()));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(Scaffold), findsWidgets);
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });

  testWidgets('does not crash on animation settle', (tester) async {
    setTestScreenSize(tester);
    await tester.pumpWidget(createTestableWidget(const UserTypeSelectionScreen()));
    await tester.pump(const Duration(seconds: 3));
    expect(find.byType(Scaffold), findsWidgets);
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });
}
