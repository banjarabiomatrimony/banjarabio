import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:banjarabio/presentation/profile_detail_screen/widgets/education_profession_card_widget.dart';
import 'package:banjarabio/presentation/profile_detail_screen/widgets/family_background_card_widget.dart';
import 'package:banjarabio/presentation/profile_detail_screen/widgets/location_details_card_widget.dart';
import 'package:banjarabio/presentation/profile_detail_screen/widgets/profile_header_widget.dart';

Widget wrapWithSizer(Widget child) => Sizer(
  builder: (context, orientation, deviceType) => MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en')],
    home: Scaffold(body: SingleChildScrollView(child: child)),
  ),
);

void main() {
  final sampleData = {
    'education': 'B.E. Computer Science',
    'profession': 'Software Engineer',
    'income': '10-15 LPA',
    'fatherName': 'Richard Doe',
    'motherName': 'Jane Doe',
    'siblings': <Map<String, dynamic>>[],
    'fatherProfession': 'Business',
    'motherProfession': 'Teacher',
    'state': 'Maharashtra',
    'district': 'Pune',
    'taluka': 'Haveli',
    'address': '123 Main St',
    'name': 'John Doe',
    'age': 28,
    'photoUrl': null,
    'email': 'john@example.com',
    'mobile': '9876543210',
    'contactPreference': 'Email',
  };

  group('EducationProfessionCardWidget', () {
    testWidgets('renders with profile data', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(wrapWithSizer(
        EducationProfessionCardWidget(profileData: sampleData),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(EducationProfessionCardWidget), findsOneWidget);
    });

    testWidgets('renders with empty data', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(wrapWithSizer(
        const EducationProfessionCardWidget(profileData: {}),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Not Entered'), findsWidgets);
    });
  });

  group('FamilyBackgroundCardWidget', () {
    testWidgets('renders with family data', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(wrapWithSizer(
        FamilyBackgroundCardWidget(profileData: sampleData),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(FamilyBackgroundCardWidget), findsOneWidget);
    });
  });

  group('LocationDetailsCardWidget', () {
    testWidgets('renders with location data', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(wrapWithSizer(
        LocationDetailsCardWidget(profileData: sampleData),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(LocationDetailsCardWidget), findsOneWidget);
    });
  });

  group('ProfileHeaderWidget', () {
    testWidgets('renders with profile data', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(wrapWithSizer(
        ProfileHeaderWidget(
          profileData: sampleData,
          isPremium: false,
        ),
      ));
      // Use pump with duration — header has ongoing animations
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(ProfileHeaderWidget), findsOneWidget);
    });
  });
}
