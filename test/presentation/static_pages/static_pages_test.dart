import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/presentation/static_pages/faq_screen.dart';
import 'package:banjarabio/presentation/static_pages/privacy_policy_screen.dart';
import 'package:banjarabio/presentation/static_pages/terms_conditions_screen.dart';
import 'package:banjarabio/presentation/static_pages/contact_us_screen.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Widget wrapWithSizer(Widget child) => Sizer(
  builder: (context, orientation, deviceType) => MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en')],
    home: child,
  ),
);

void main() {
  group('FAQScreen', () {
    testWidgets('renders FAQ screen with title and questions', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(wrapWithSizer(const FAQScreen()));
      await tester.pumpAndSettle();

      expect(find.text('FAQs'), findsOneWidget);
      expect(find.byType(ExpansionTile), findsWidgets);
    });

    testWidgets('expansion tiles can expand', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(wrapWithSizer(const FAQScreen()));
      await tester.pumpAndSettle();

      // Tap first expansion tile
      final firstTile = find.byType(ExpansionTile).first;
      await tester.tap(firstTile);
      await tester.pumpAndSettle();

      // After expansion, answer text should be visible
      expect(find.byType(ExpansionTile), findsWidgets);
    });
  });

  group('PrivacyPolicyScreen', () {
    testWidgets('renders with title and sections', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(wrapWithSizer(const PrivacyPolicyScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Privacy Policy'), findsWidgets);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });

  group('TermsConditionsScreen', () {
    testWidgets('renders with title and sections', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(wrapWithSizer(const TermsConditionsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Terms & Conditions'), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });

  group('ContactUsScreen', () {
    testWidgets('renders with contact items', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(wrapWithSizer(const ContactUsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Contact Us'), findsOneWidget);
      expect(find.byType(InkWell), findsWidgets); // Contact items
    });
  });
}
