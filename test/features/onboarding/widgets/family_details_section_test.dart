import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';
import 'package:mocktail/mocktail.dart';
import 'package:banjarabio/presentation/biodata_creation_screen/widgets/family_details_section.dart';
import 'package:banjarabio/core/repositories/subscription_repository.dart';
import 'package:banjarabio/core/models/backend_response.dart';

class MockSubscriptionRepository extends Mock implements SubscriptionRepository {}

Widget wrapWithSizer(Widget child) {
  return Sizer(
    builder: (context, orientation, screenType) => child,
  );
}

void main() {
  late MockSubscriptionRepository mockRepo;

  setUp(() {
    mockRepo = MockSubscriptionRepository();
    // Default to non-premium for free tier testing
    when(() => mockRepo.isPremium()).thenAnswer(
      (_) async => BackendResponse.success(false),
    );
  });

  group('FamilyDetailsSection Widget Tests', () {
    testWidgets('should display Bio Generator button', (tester) async {
      await tester.pumpWidget(
        wrapWithSizer(
          MaterialApp(
            home: Scaffold(
              body: FamilyDetailsSection(
                formData: const {},
                onUpdate: (key, value) {},
                onBatchUpdate: (_) {},
                onValidationChange: (_) {},
                subscriptionRepository: mockRepo,
                scrollController: ScrollController(),
              ),
            ),
          ),
        ),
      );

      expect(find.text('✨ Generate Bio'), findsOneWidget);
    });

    testWidgets('should call Generate Bio and update text field with name', (tester) async {
      // Set a huge surface size to avoid scrolling entirely
      tester.view.physicalSize = const Size(1200, 5000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      String? updatedKey;
      dynamic updatedValue;

      await tester.pumpWidget(
        wrapWithSizer(
          MaterialApp(
            home: Scaffold(
              body: FamilyDetailsSection(
                formData: const {
                  'name': 'Rahul',
                  'gender': 'Male',
                  'age': 28,
                  'education': 'BE Computer',
                  'profession': 'Software Engineer'
                },
                onUpdate: (key, val) {
                  updatedKey = key;
                  updatedValue = val;
                },
                onBatchUpdate: (_) {},
                onValidationChange: (_) {},
                subscriptionRepository: mockRepo,
                scrollController: ScrollController(),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap the generate button - use text finder as it's the most direct
      final generateButton = find.text('✨ Generate Bio');
      await tester.tap(generateButton);
      
      // The button shows "Generating..." during delay
      await tester.pump();
      expect(find.text('Generating...'), findsOneWidget);

      // Wait for the simulated delay (1 second in code)
      await tester.pump(const Duration(seconds: 2));

      // Find the About Self text field
      // It is the last TextFormField in this section
      final textField = tester.widget<TextFormField>(find.byType(TextFormField).last);
      
      expect(textField.controller?.text, contains('Rahul'));
      expect(updatedKey, 'aboutSelf');
      expect(updatedValue, contains('Rahul'));
    });
  });
}
