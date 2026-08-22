import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/presentation/static_pages/faq_screen.dart';

void main() {
  Widget buildApp() {
    return Sizer(
      builder: (context, orientation, deviceType) => const MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [Locale('en')],
        home: FAQScreen(),
      ),
    );
  }

  group('FAQScreen', () {
    testWidgets('renders FAQs or Help & FAQs title in app bar', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      expect(
        find.text('FAQs').evaluate().isNotEmpty ||
            find.text('Help & FAQs').evaluate().isNotEmpty,
        isTrue,
      );
    });

    testWidgets('renders all 5 FAQ questions', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      // Check specific questions are visible (using localized titles)
      expect(find.text('How do I create a biodata?'), findsOneWidget);
      expect(find.text('Is my data secure?'), findsOneWidget);
      expect(find.text('How can I filter profiles?'), findsOneWidget);
      expect(find.text('What are the benefits of Premium?'), findsOneWidget);
      expect(find.text('How do I delete my account?'), findsOneWidget);
    });

    testWidgets('expanding a question reveals the answer', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      // First item is expanded by default in new design
      expect(
        find.textContaining('Go to the Profile tab'),
        findsOneWidget,
      );

      // Tap the second question to expand it
      await tester.tap(find.text('Is my data secure?'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Answer 2 should now be visible
      expect(
        find.textContaining('Yes, we take privacy seriously'),
        findsOneWidget,
      );
    });

    testWidgets('back button navigates back', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      bool navigatedBack = false;

      await tester.pumpWidget(Sizer(
        builder: (context, orientation, deviceType) => MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FAQScreen()),
                );
              },
              child: const Text('Go'),
            ),
          ),
        ),
      ));
      await tester.pump();
      await tester.pump();

      // Navigate to FAQ screen
      await tester.tap(find.text('Go'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      expect(
        find.text('FAQs').evaluate().isNotEmpty ||
            find.text('Help & FAQs').evaluate().isNotEmpty,
        isTrue,
      );

      // Tap back button
      final backButton = find.byIcon(Icons.arrow_back_ios_new_rounded);
      expect(backButton, findsOneWidget);
      await tester.tap(backButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      // Should be back on the initial screen
      navigatedBack = find.text('Go').evaluate().isNotEmpty;
      expect(navigatedBack, isTrue);
    });
  });
}
