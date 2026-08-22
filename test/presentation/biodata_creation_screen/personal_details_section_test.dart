// Phase 12: PersonalDetailsSection widget tests
// Verifies all 12+ form fields, dynamic surname/gotra logic, and validation callbacks.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/presentation/biodata_creation_screen/widgets/personal_details_section.dart';
import '../../helpers/widget_test_helpers.dart';

void main() {
  group('PersonalDetailsSection Widget Tests', () {
    late Map<String, dynamic> formData;
    late Map<String, dynamic> updatedData;
    late bool isValid;

    setUp(() {
      setupWidgetTestMocks();
      formData = {
        'maritalStatus': 'Never Married',
        'isDisabled': false,
      };
      updatedData = {};
      isValid = false;
    });

    tearDown(() {
      tearDownWidgetTestMocks();
    });

    Widget createTestWidget() {
      return createTestableWidget(
        Scaffold(
          body: PersonalDetailsSection(
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

    Finder findDropdown(String labelText) {
      return find.descendant(
        of: find.ancestor(
          of: find.text(labelText).first,
          matching: find.byType(Column),
        ).first,
        matching: find.byType(DropdownButtonFormField<String>),
      );
    }

    testWidgets('renders all essential fields', (WidgetTester tester) async {
      setTestScreenSize(tester);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Profile Created By'), findsOneWidget);
      expect(find.text('Surname'), findsOneWidget);
      expect(find.text('Age'), findsOneWidget);
      expect(find.text('Date of Birth'), findsOneWidget);
      expect(find.text('Height'), findsOneWidget);
    });

    testWidgets('updates name and triggers callback', (WidgetTester tester) async {
      setTestScreenSize(tester);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // First TextFormField is always Full Name
      final nameField = find.byType(TextFormField).at(0);
      await tester.enterText(nameField, 'Rahul Rathod');
      await tester.pump();

      expect(updatedData['name'], equals('Rahul Rathod'));
    });

    testWidgets('dynamic gotra visibility based on surname', (WidgetTester tester) async {
      setTestScreenSize(tester);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Gotra'), findsNothing);

      // Select 'Rathod'
      await tester.tap(findDropdown('Surname'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rathod').last);
      await tester.pumpAndSettle();

      expect(updatedData['surname'], equals('Rathod'));
      expect(find.text('Gotra'), findsOneWidget);
    });

    testWidgets('custom surname "Other" shows text input', (WidgetTester tester) async {
      setTestScreenSize(tester);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Select 'Other'
      await tester.tap(findDropdown('Surname'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Other').last);
      await tester.pumpAndSettle();

      // When 'Other' is selected, index 0 is Name, index 1 is Mobile Number, index 2 is Custom Surname
      final customField = find.byType(TextFormField).at(2);
      await tester.enterText(customField, 'Chavhan');
      await tester.pump();
      
      expect(updatedData['surname'], equals('Chavhan'));
    });

    testWidgets('validation callback triggers when required fields filled', (WidgetTester tester) async {
      setTestScreenSize(tester);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(isValid, isFalse);

      // 1. Fill Name (index 0)
      await tester.enterText(find.byType(TextFormField).at(0), 'Rahul Rathod');
      await tester.pumpAndSettle();

      // 2. Select Profile Created By
      await tester.tap(findDropdown('Profile Created By'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Self').last);
      await tester.pumpAndSettle();

      // 3. Select Gender
      await tester.tap(find.text('MALE')); 
      await tester.pumpAndSettle();

      // 4. Select Surname
      await tester.tap(findDropdown('Surname'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rathod').last);
      await tester.pumpAndSettle();

      // 5. Select Gotra
      await tester.ensureVisible(findDropdown('Gotra'));
      await tester.pumpAndSettle();
      await tester.tap(findDropdown('Gotra'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Aaloth').last);
      await tester.pumpAndSettle();

      // 6. Fill Phone Number (index 1)
      final phoneField = find.byType(TextFormField).at(1);
      await tester.ensureVisible(phoneField);
      await tester.pumpAndSettle();
      await tester.enterText(phoneField, '9876543210');
      await tester.pumpAndSettle();

      // 7. Fill Age (index 2)
      final ageField = find.byType(TextFormField).at(2);
      await tester.ensureVisible(ageField);
      await tester.pumpAndSettle();
      await tester.enterText(ageField, '25');
      await tester.pumpAndSettle();

      expect(isValid, isTrue);
    });
  });
}
