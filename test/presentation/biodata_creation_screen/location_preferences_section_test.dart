// Phase 12: LocationPreferencesSection widget tests
// Verifies hierarchical location selection (State -> District -> Taluka),
// custom text fields, and marriage readiness toggle.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/presentation/biodata_creation_screen/widgets/location_preferences_section.dart';
import '../../helpers/widget_test_helpers.dart';

void main() {
  group('LocationPreferencesSection Widget Tests', () {
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
          body: LocationPreferencesSection(
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
          ),
        ),
      );
    }

    // Dropdown indices: 0: State, 1: District, 2: Taluka
    Finder getDropdown(int index) => find.byType(DropdownButtonFormField<String>).at(index);

    testWidgets('renders all major fields and honors hierarchy', (WidgetTester tester) async {
      setTestScreenSize(tester);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.textContaining('Location'), findsAtLeast(1));
      expect(find.textContaining('Residence State'), findsOneWidget);
      expect(find.textContaining('District'), findsAtLeast(1));
      
      // District and Taluka should be disabled initially (or have "Select State first" type hints)
      // Check that entering State enables District
      await tester.tap(getDropdown(0));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Maharashtra').last);
      await tester.pumpAndSettle();

      expect(updatedData['state'], equals('Maharashtra'));
      
      // Select District
      await tester.tap(getDropdown(1));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pune').last);
      await tester.pumpAndSettle();

      expect(updatedData['district'], equals('Pune'));

      // Check Location Preview
      expect(find.textContaining('Maharashtra'), findsWidgets);
      expect(find.textContaining('Pune'), findsWidgets);
    });

    testWidgets('validation requires state selection', (WidgetTester tester) async {
      setTestScreenSize(tester);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(isValid, isFalse);

      await tester.tap(getDropdown(0));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Karnataka').last);
      await tester.pumpAndSettle();

      expect(isValid, isTrue);
    });

    testWidgets('handles village and native place input', (WidgetTester tester) async {
      setTestScreenSize(tester);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Index 0: Village, 1: Native Place
      await tester.enterText(find.byType(TextFormField).at(0), 'Wagholi');
      await tester.pumpAndSettle();
      expect(updatedData['village'], equals('Wagholi'));

      await tester.enterText(find.byType(TextFormField).at(1), 'Beed');
      await tester.pumpAndSettle();
      expect(updatedData['nativePlace'], equals('Beed'));
    });

    testWidgets('toggles marriage readiness', (WidgetTester tester) async {
      setTestScreenSize(tester);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final switchFinder = find.byType(Switch);
      expect(tester.widget<Switch>(switchFinder).value, isTrue);

      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      expect(tester.widget<Switch>(switchFinder).value, isFalse);
      expect(updatedData['marriageReadiness'], isFalse);
    });
  });
}
