// Phase 12: EducationProfessionSection widget tests
// Verifies education/profession dropdowns, custom input logic, and validation.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/presentation/biodata_creation_screen/widgets/education_profession_section.dart';
import '../../helpers/widget_test_helpers.dart';

void main() {
  group('EducationProfessionSection Widget Tests', () {
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
          body: EducationProfessionSection(
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

    // Stable indices for DropdownButtonFormField in this section:
    // 0: Educational Qualification
    // 1: Profession
    // 2: Annual Income
    Finder getDropdown(int index) => find.byType(DropdownButtonFormField<String>).at(index);

    testWidgets('renders all major fields', (WidgetTester tester) async {
      setTestScreenSize(tester);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.textContaining('Education'), findsWidgets);
      expect(find.textContaining('Profession'), findsWidgets);
      expect(find.textContaining('Income'), findsWidgets);
      expect(find.byType(DropdownButtonFormField<String>), findsNWidgets(3));
    });

    testWidgets('custom education "Other" shows text input', (WidgetTester tester) async {
      setTestScreenSize(tester);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Select 'Other' in Education (index 0)
      await tester.tap(getDropdown(0));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Other').last);
      await tester.pumpAndSettle();

      expect(find.textContaining('Specify Education'), findsOneWidget);
      
      // When 'Other' education is selected, it becomes the first TextFormField (index 0)
      await tester.enterText(find.byType(TextFormField).at(0), 'M.Tech in Bio');
      await tester.pump();
      
      expect(updatedData['education'], equals('M.Tech in Bio'));
    });

    testWidgets('validation callback triggers when required fields filled', (WidgetTester tester) async {
      setTestScreenSize(tester);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(isValid, isFalse);

      // 1. Select Education
      await tester.tap(getDropdown(0));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Bachelor').last);
      await tester.pumpAndSettle();

      // 2. Select Profession
      await tester.tap(getDropdown(1));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Private Sector').last);
      await tester.pumpAndSettle();

      // 3. Select Income
      await tester.tap(getDropdown(2));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Year').last);
      await tester.pumpAndSettle();

      expect(isValid, isTrue);
    });
  });
}
