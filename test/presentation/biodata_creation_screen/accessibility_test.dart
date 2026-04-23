// Phase 13: Accessibility Testing
// Verifies semantic nodes, labels, and interaction hints for screen readers.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/presentation/biodata_creation_screen/widgets/personal_details_section.dart';
import 'package:banjarabio/presentation/biodata_creation_screen/widgets/education_profession_section.dart';
import 'package:banjarabio/presentation/biodata_creation_screen/widgets/family_details_section.dart';
import 'package:banjarabio/presentation/biodata_creation_screen/widgets/location_preferences_section.dart';
import 'package:banjarabio/presentation/biodata_creation_screen/widgets/photo_upload_section.dart';
import '../../helpers/widget_test_helpers.dart';

void main() {
  group('Biodata Creation Accessibility Tests', () {
    late ScrollController scrollController;

    setUp(() {
      setupWidgetTestMocks();
      scrollController = ScrollController();
    });

    tearDown(() {
      scrollController.dispose();
      tearDownWidgetTestMocks();
    });

    testWidgets('PersonalDetailsSection has correct semantic labels', (WidgetTester tester) async {
      final Map<String, dynamic> formData = {
        'name': '',
        'surname': '',
        'gender': 'Female',
        'age': '',
        'height': "5'5\"",
      };

      await tester.pumpWidget(createTestableWidget(
        Scaffold(
          body: PersonalDetailsSection(
            formData: formData,
            onUpdate: (_, _) {},
            onBatchUpdate: (_) {},
            onValidationChange: (_) {},
            scrollController: scrollController,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      // Use findsAtLeastNWidgets because label text and hint text might both match
      expect(find.bySemanticsLabel(RegExp(r'full name', caseSensitive: false)), findsAtLeastNWidgets(1));
      expect(find.bySemanticsLabel('FEMALE'), findsAtLeastNWidgets(1));
      expect(find.bySemanticsLabel('MALE'), findsAtLeastNWidgets(1));
    });

    testWidgets('EducationProfessionSection has correct semantic labels', (WidgetTester tester) async {
      final Map<String, dynamic> formData = {
        'education': '',
        'profession': '',
        'annualIncome': '',
      };

      await tester.pumpWidget(createTestableWidget(
        Scaffold(
          body: EducationProfessionSection(
            formData: formData,
            onUpdate: (_, _) {},
            onBatchUpdate: (_) {},
            onValidationChange: (_) {},
            scrollController: scrollController,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel(RegExp(r'education level', caseSensitive: false)), findsAtLeastNWidgets(1));
    });

    testWidgets('FamilyDetailsSection has correct semantic labels', (WidgetTester tester) async {
      final Map<String, dynamic> formData = {
        'fatherName': '',
        'fatherOccupation': '',
        'motherName': '',
        'siblingsCount': '0',
        'siblings': [],
      };

      await tester.pumpWidget(createTestableWidget(
        Scaffold(
          body: FamilyDetailsSection(
            formData: formData,
            onUpdate: (_, _) {},
            onBatchUpdate: (_) {},
            onValidationChange: (_) {},
            scrollController: scrollController,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel(RegExp(r"Father's Name", caseSensitive: false)), findsAtLeastNWidgets(1));
    });

    testWidgets('LocationPreferencesSection has correct semantic labels', (WidgetTester tester) async {
      final Map<String, dynamic> formData = {
        'state': '',
        'district': '',
        'taluka': '',
        'village': '',
        'marriageReadiness': true,
      };

      await tester.pumpWidget(createTestableWidget(
        Scaffold(
          body: LocationPreferencesSection(
            formData: formData,
            onUpdate: (_, _) {},
            onBatchUpdate: (_) {},
            onValidationChange: (_) {},
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel(RegExp(r'State', caseSensitive: false)), findsAtLeastNWidgets(1));
    });

    testWidgets('PhotoUploadSection has correct semantic labels', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(
        Scaffold(
          body: PhotoUploadSection(
            photos: const [],
            gender: 'Male',
            onPhotosUpdate: (_) {},
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('No photos added'), findsOneWidget);
      expect(find.text('Add Photo'), findsAtLeastNWidgets(1));
    });
  });
}
