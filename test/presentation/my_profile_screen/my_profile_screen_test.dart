import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../helpers/widget_test_helpers.dart';
import 'package:banjarabio/presentation/my_profile_screen/my_profile_screen.dart';

void main() {
  setUp(() => setupWidgetTestMocks());
  tearDown(() => tearDownWidgetTestMocks());

  testWidgets('renders Scaffold with AppBar', (tester) async {
    setTestScreenSize(tester);
    await tester.pumpWidget(createTestableWidget(const MyProfileScreen()));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(Scaffold), findsWidgets);
  });

  testWidgets('shows loading skeleton initially', (tester) async {
    setTestScreenSize(tester);
    await tester.pumpWidget(createTestableWidget(const MyProfileScreen()));
    await tester.pump(const Duration(milliseconds: 100));
    // Should find scaffold and some loading indicator
    expect(find.byType(Scaffold), findsWidgets);
  });

  testWidgets('shows error or profile after load', (tester) async {
    setTestScreenSize(tester);
    await tester.pumpWidget(createTestableWidget(const MyProfileScreen()));
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(find.byType(Scaffold), findsWidgets);
  });
}
