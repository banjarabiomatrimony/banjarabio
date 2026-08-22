import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../helpers/widget_test_helpers.dart';
import 'package:banjarabio/presentation/home_screen/location_selection_screen.dart';

void main() {
  setUp(() => setupWidgetTestMocks());
  tearDown(() => tearDownWidgetTestMocks());

  testWidgets('renders Scaffold', (tester) async {
    setTestScreenSize(tester);
    await tester.pumpWidget(createTestableWidget(const LocationSelectionScreen()));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(Scaffold), findsWidgets);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });

  testWidgets('does not crash on settle', (tester) async {
    setTestScreenSize(tester);
    await tester.pumpWidget(createTestableWidget(const LocationSelectionScreen()));
    await tester.pump(const Duration(seconds: 3));
    expect(find.byType(Scaffold), findsWidgets);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });
}
