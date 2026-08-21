import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:banjarabio/presentation/home_screen/widgets/profile_card_widget.dart';
import 'package:banjarabio/core/models/profile_model.dart';

Widget wrapWithSizer(Widget child) => Sizer(
  builder: (context, orientation, deviceType) => MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en')],
    home: Scaffold(body: child),
  ),
);

void main() {
  group('ProfileCardWidget', () {
    testWidgets('renders with profile model', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final profile = ProfileModel(
        id: '1',
        userId: 'u1',
        fullName: 'John Doe',
        surname: 'Doe',
        age: 28,
        height: "5'10\"",
        education: 'B.E.',
        profession: 'Engineer',
        gender: 'Male',
        state: 'Maharashtra',
        district: 'Pune',
        taluka: 'Haveli',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(wrapWithSizer(
        ProfileCardWidget(
          profile: profile,
          onTap: () {},
          onBookmark: () {},
          onShare: (_) {},
          onInterest: (_) {},
        ),
      ));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ProfileCardWidget), findsOneWidget);
    });

    testWidgets('renders minimal profile', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final profile = ProfileModel(
        id: '2',
        userId: 'u2',
        fullName: 'Jane',
        surname: 'Smith',
        age: 25,
        height: "5'5\"",
        education: '',
        profession: '',
        gender: 'Female',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(wrapWithSizer(
        ProfileCardWidget(
          profile: profile,
          onTap: () {},
          onBookmark: () {},
          onShare: (_) {},
          onInterest: (_) {},
        ),
      ));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ProfileCardWidget), findsOneWidget);
    });

    testWidgets('shows gender badge correctly', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final profile = ProfileModel(
        id: '1',
        userId: 'u1',
        fullName: 'John Doe',
        surname: 'Doe',
        age: 28,
        gender: 'Male',
        height: "5'10\"",
        education: 'B.E.',
        profession: 'Engineer',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(wrapWithSizer(
        ProfileCardWidget(
          profile: profile,
          onTap: () {},
          onBookmark: () {},
          onShare: (_) {},
          onInterest: (_) {},
        ),
      ));
      await tester.pump(const Duration(milliseconds: 100));

      // Check that candidate details are rendered
      expect(find.textContaining('John Doe'), findsOneWidget);
      expect(find.textContaining('28'), findsOneWidget);
    });
  });
}
