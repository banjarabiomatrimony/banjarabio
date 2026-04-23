// Phase 12: FamilyDetailsSection widget tests
// Verifies family fields, dynamic sibling management, and AI bio trigger.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/presentation/biodata_creation_screen/widgets/family_details_section.dart';
import '../../helpers/widget_test_helpers.dart';

void main() {
  group('FamilyDetailsSection Widget Tests', () {
    late Map<String, dynamic> formData;
    late Map<String, dynamic> updatedData;
    late bool isValid;

    setUp(() {
      setupWidgetTestMocks();
      formData = {};
      updatedData = {};
      isValid = false;
    });

    tearDown(() {
      tearDownWidgetTestMocks();
    });

    Widget createTestWidget() {
      return createTestableWidget(
        Scaffold(
          body: FamilyDetailsSection(
            formData: formData,
            onUpdate: (key, value) {
              updatedData[key] = value;
            },
            onBatchUpdate: (data) {
              updatedData.addAll(data);
            },
            onValidationChange: (valid) {
              isValid = valid;
            },
            scrollController: ScrollController(),
          ),
        ),
      );
    }

    testWidgets('renders father and mother fields', (WidgetTester tester) async {
      setTestScreenSize(tester);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // These strings may appear as both label and hint
      expect(find.textContaining("Father's Name"), findsWidgets);
      expect(find.textContaining("Mother's Name"), findsWidgets);
      expect(find.textContaining('Siblings'), findsOneWidget);
    });

    testWidgets('adds and removes siblings', (WidgetTester tester) async {
      setTestScreenSize(tester);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('No siblings added yet'), findsOneWidget);

      // Add sibling
      await tester.tap(find.text('Add Sibling'));
      await tester.pumpAndSettle();

      expect(find.text('No siblings added yet'), findsNothing);
      expect(find.textContaining('Total: 1'), findsOneWidget);
      expect(updatedData['siblingsCount'], equals(1));

      // Remove sibling
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      expect(find.text('No siblings added yet'), findsOneWidget);
      expect(updatedData['siblingsCount'], equals(0));
    });

    testWidgets('validation callback triggers when required fields filled', (WidgetTester tester) async {
      setTestScreenSize(tester);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(isValid, isFalse);

      // 1. Father's Name (index 0)
      await tester.enterText(find.byType(TextFormField).at(0), 'Dashrath Rathod');
      await tester.pumpAndSettle();

      // 2. Mother's Name (index 2)
      // Index 0: Father Name, 1: Father Occ, 2: Mother Name, 3: Mother Occ, 4: About Self
      await tester.enterText(find.byType(TextFormField).at(2), 'Kausalya Rathod');
      await tester.pumpAndSettle();

      expect(isValid, isTrue);
    });

    testWidgets('triggers AI bio generation', (WidgetTester tester) async {
      setTestScreenSize(tester);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find the "Generate Bio" button
      final bioBtn = find.textContaining('Bio');
      expect(bioBtn, findsWidgets);
      
      await tester.tap(bioBtn.first);
      
      // AI generation has a 1s delay in code
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();

      // Check if aboutSelf was updated
      expect(updatedData.containsKey('aboutSelf'), isTrue);
    });
  });
}
