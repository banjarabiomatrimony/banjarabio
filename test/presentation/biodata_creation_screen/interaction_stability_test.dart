
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/presentation/biodata_creation_screen/biodata_creation_screen.dart';
import '../../helpers/widget_test_helpers.dart';

void main() {
  group('BiodataCreationScreen Interaction Stability Tests', () {
    setUp(() {
      setupWidgetTestMocks();
    });

    tearDown(() {
      tearDownWidgetTestMocks();
    });

    testWidgets('Focus remains on Name field after typing (parent rebuild stability)', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(const BiodataCreationScreen()));
      await tester.pumpAndSettle();

      // Find Name field in PersonalDetailsSection
      final nameField = find.byType(TextFormField).first;
      expect(nameField, findsOneWidget);

      // 1. Focus the field
      await tester.tap(nameField);
      await tester.pump();
      
      // 2. Type something
      await tester.enterText(nameField, 'John Doe');
      await tester.pump(); // This trigger _updateFormData -> setState in parent

      // 3. Verify focus is STILL on an EditableText (the one inside our TextFormField)
      final focusedNode = FocusManager.instance.primaryFocus;
      expect(focusedNode, isNotNull);
      
      // Check if the focused node belongs to an EditableText inside our TextFormField
      final editableText = find.descendant(of: nameField, matching: find.byType(EditableText));
      expect(editableText, findsOneWidget);
    });
  });
}
