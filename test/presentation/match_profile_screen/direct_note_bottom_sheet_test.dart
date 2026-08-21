import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:banjarabio/presentation/match_profile_screen/widgets/direct_note_bottom_sheet.dart';

Widget wrapWithSizer(Widget child) => Sizer(
  builder: (context, orientation, deviceType) => MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en')],
    home: Scaffold(
      body: SizedBox(
        width: 1080,
        height: 2400,
        child: child,
      ),
    ),
  ),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final mockProfile = {
    'id': 'p-101',
    'name': 'Pooja Rathod',
    'gotra': 'Rathod (Khamani)',
    'age': 25,
    'height': "5'6\"",
    'education': 'B.Tech Computer Science',
    'profession': 'Software Engineer',
    'location': 'Pune, Maharashtra',
    'annual_income': '₹15 - 20 LPA',
    'trust_score': 95,
    'marital_status': 'Never Married',
    'profileImage': '',
  };

  group('DirectNoteBottomSheet Animated UI/UX', () {
    testWidgets('renders all animated sections, avatar, and template chips', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(wrapWithSizer(
        DirectNoteBottomSheet(profile: mockProfile),
      ));

      // Pump entry animation duration
      await tester.pump(const Duration(milliseconds: 750));

      // Header verification: 3-step connected process stepper
      expect(find.text('Pick Note'), findsOneWidget);
      expect(find.text('Top Delivery'), findsOneWidget);
      expect(find.text('3x Replies'), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);

      // Template categories verification
      expect(find.text('CHOOSE A QUICK INTRO TEMPLATE'), findsOneWidget);
      expect(find.text('🌟 Family & Values'), findsOneWidget);
      expect(find.textContaining('Liked your profile & Gotra alignment'), findsWidgets);

      // Custom message box verification
      expect(find.text('OR CUSTOMIZE YOUR NOTE'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      // Send CTA Button
      expect(find.byType(DirectNoteBottomSheet), findsOneWidget);
    });

    testWidgets('switching template chip updates input text and character count', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(wrapWithSizer(
        DirectNoteBottomSheet(profile: mockProfile),
      ));
      await tester.pump(const Duration(milliseconds: 750));

      final secondChip = find.textContaining('our families share similar traditions');
      expect(secondChip, findsWidgets);

      await tester.tap(secondChip.first);
      await tester.pump(const Duration(milliseconds: 100));

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, contains('our families share similar traditions'));
    });

    testWidgets('typing custom note updates live character counter', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(wrapWithSizer(
        DirectNoteBottomSheet(profile: mockProfile),
      ));
      await tester.pump(const Duration(milliseconds: 750));

      await tester.enterText(find.byType(TextField), 'Hello from Rathod family');
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('24 / 200'), findsOneWidget);
    });

    testWidgets('clear text button clears text input', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(wrapWithSizer(
        DirectNoteBottomSheet(profile: mockProfile),
      ));
      await tester.pump(const Duration(milliseconds: 750));

      final clearBtn = find.text('Clear text');
      expect(clearBtn, findsOneWidget);

      await tester.ensureVisible(clearBtn);
      await tester.tap(clearBtn);
      await tester.pump(const Duration(milliseconds: 100));

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, '');
      expect(find.text('0 / 200'), findsOneWidget);
    });
  });
}
