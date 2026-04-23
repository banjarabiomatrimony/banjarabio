import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/presentation/biodata_creation_screen/widgets/personal_details_section.dart';
import '../../helpers/widget_test_helpers.dart';

void main() {
  late Map<String, dynamic> formData;
  late ScrollController scrollController;

  setUp(() {
    formData = {'gender': 'Male'}; // Set some initial value
    scrollController = ScrollController();
    setupWidgetTestMocks();
  });

  tearDown(() {
    scrollController.dispose();
    tearDownWidgetTestMocks();
  });

  Widget createTestWidget() {
    return createTestableWidget(
      Scaffold(
        body: PersonalDetailsSection(
          formData: formData,
          onUpdate: (key, value) {
            formData[key] = value;
          },
          onBatchUpdate: (data) {
            formData.addAll(data);
          },
          onValidationChange: (isValid) {},
          scrollController: scrollController,
        ),
      ),
    );
  }

  testWidgets('Selecting Son DOES NOT auto-select Male gender (allows sibling selection)', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    final dropdownFinder = find.byType(DropdownButtonFormField<String>).first;
    expect(dropdownFinder, findsOneWidget);

    await tester.tap(dropdownFinder);
    await tester.pumpAndSettle();

    final sonItemFinder = find.text('Son').last;
    await tester.tap(sonItemFinder);
    await tester.pumpAndSettle();

    expect(formData['profileCreatedBy'], equals('Son'));
    expect(formData['gender'], equals('Male')); // Remains unchanged
  });

  testWidgets('Selecting Sister DOES NOT auto-select Female gender (allows brother to be created by sister)', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    final dropdownFinder = find.byType(DropdownButtonFormField<String>).first;
    
    await tester.tap(dropdownFinder);
    await tester.pumpAndSettle();

    final sisterItemFinder = find.text('Sister').last;
    await tester.tap(sisterItemFinder);
    await tester.pumpAndSettle();

    expect(formData['profileCreatedBy'], equals('Sister'));
    // Should NOT have changed to 'Female'
    expect(formData['gender'], equals('Male')); 
  });
}
