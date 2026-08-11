import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:banjarabio/presentation/profile_detail_screen/widgets/profile_header_widget.dart';
import 'package:banjarabio/presentation/profile_detail_screen/widgets/personal_details_card_widget.dart';
import 'package:banjarabio/presentation/profile_detail_screen/widgets/profile_detail_chip_widget.dart';

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
  group('ProfileHeaderWidget', () {
    testWidgets('renders with male gender badge', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(wrapWithSizer(
        const ProfileHeaderWidget(
          profileData: {
            'id': '123',
            'gender': 'Male',
            'photos': ['https://example.com/photo.jpg'],
          },
          isPremium: false,
        ),
      ));
      await tester.pump();

      expect(find.text('MALE'), findsOneWidget);

      // Allow background cache manager timers to complete
      await tester.pump(const Duration(seconds: 10));
    });

    testWidgets('renders with female gender badge', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(wrapWithSizer(
        const ProfileHeaderWidget(
          profileData: {
            'id': '456',
            'gender': 'Female',
            'photos': ['https://example.com/photo.jpg'],
          },
          isPremium: false,
        ),
      ));
      await tester.pump();

      expect(find.text('FEMALE'), findsOneWidget);

      // Allow background cache manager timers to complete
      await tester.pump(const Duration(seconds: 10));
    });
  });

  group('PersonalDetailsCardWidget', () {
    testWidgets('renders with profile data', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(wrapWithSizer(
        const PersonalDetailsCardWidget(profileData: {
          'name': 'John Doe',
          'age': 28,
          'height': "5'10\"",
          'gender': 'Male',
          'surname': 'Doe',
          'maritalStatus': 'Never Married',
          'dateOfBirth': '1996-01-15',
        }),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(PersonalDetailsCardWidget), findsOneWidget);
      expect(find.text('Male'), findsOneWidget);
      expect(find.text('GENDER'), findsOneWidget);
    });

    testWidgets('renders with empty data showing Not Entered', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(wrapWithSizer(
        const PersonalDetailsCardWidget(profileData: {}),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Not Entered'), findsWidgets);
    });
  });

  group('ProfileDetailChipWidget', () {
    testWidgets('renders with label and value', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(wrapWithSizer(
        const ProfileDetailChipWidget(
          iconName: 'person',
          label: 'Name',
          value: 'John Doe',
          tintColor: Colors.blue,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('NAME'), findsOneWidget); // label is uppercased
    });

    testWidgets('renders full width variant', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(wrapWithSizer(
        const ProfileDetailChipWidget(
          iconName: 'badge',
          label: 'Full Name',
          value: 'Jane Doe',
          tintColor: Colors.purple,
          fullWidth: true,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Jane Doe'), findsOneWidget);
    });
  });
}
