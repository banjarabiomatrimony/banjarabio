import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../helpers/widget_test_helpers.dart';
import 'package:banjarabio/presentation/onboarding_selection_screen/onboarding_selection_screen.dart';

void main() {
  setUp(() => setupWidgetTestMocks());
  tearDown(() => tearDownWidgetTestMocks());

  testWidgets('renders Scaffold', (tester) async {
    setTestScreenSize(tester);
    await tester.pumpWidget(createTestableWidget(const OnboardingSelectionScreen()));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(Scaffold), findsWidgets);
    // Dispose safely — the staggered animations may still be running
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });

  testWidgets('does not crash on settle', (tester) async {
    setTestScreenSize(tester);
    await tester.pumpWidget(createTestableWidget(const OnboardingSelectionScreen()));
    // Pump for 3s to let staggered entrance animations complete
    await tester.pump(const Duration(seconds: 3));
    expect(find.byType(Scaffold), findsWidgets);
    // Dispose safely
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });
}
