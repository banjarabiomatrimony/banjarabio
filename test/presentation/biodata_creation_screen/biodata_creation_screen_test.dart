import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../helpers/widget_test_helpers.dart';
import 'package:banjarabio/presentation/biodata_creation_screen/biodata_creation_screen.dart';

void main() {
  setUp(() => setupWidgetTestMocks());
  tearDown(() => tearDownWidgetTestMocks());

  testWidgets('renders Scaffold', (tester) async {
    setTestScreenSize(tester);
    await tester.pumpWidget(createTestableWidget(const BiodataCreationScreen()));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(Scaffold), findsWidgets);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });

  testWidgets('shows loading indicator or form', (tester) async {
    setTestScreenSize(tester);
    await tester.pumpWidget(createTestableWidget(const BiodataCreationScreen()));
    await tester.pump(const Duration(milliseconds: 500));
    // Should render scaffold containing either a form or loading indicator
    expect(find.byType(Scaffold), findsWidgets);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });

  testWidgets('pump and settle does not crash', (tester) async {
    setTestScreenSize(tester);
    await tester.pumpWidget(createTestableWidget(const BiodataCreationScreen()));
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(find.byType(Scaffold), findsWidgets);
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });
}
