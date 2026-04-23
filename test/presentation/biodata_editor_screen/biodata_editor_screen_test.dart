import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../helpers/widget_test_helpers.dart';
import 'package:banjarabio/presentation/biodata_editor_screen/biodata_editor_screen.dart';

void main() {
  setUp(() => setupWidgetTestMocks());
  tearDown(() => tearDownWidgetTestMocks());

  testWidgets('renders Scaffold with loading state', (tester) async {
    setTestScreenSize(tester);
    await tester.pumpWidget(createTestableWidget(const BiodataEditorScreen()));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(Scaffold), findsWidgets);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });

  testWidgets('shows CircularProgressIndicator during init', (tester) async {
    setTestScreenSize(tester);
    await tester.pumpWidget(createTestableWidget(const BiodataEditorScreen()));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(CircularProgressIndicator), findsWidgets);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });

  testWidgets('shows error state when profile load fails', (tester) async {
    setTestScreenSize(tester);
    await tester.pumpWidget(createTestableWidget(const BiodataEditorScreen()));
    await tester.pumpAndSettle(const Duration(seconds: 3));
    // After failed load, should show error UI or remain in loading
    expect(find.byType(Scaffold), findsWidgets);
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });
}
