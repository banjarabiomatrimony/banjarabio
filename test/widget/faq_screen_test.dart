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
    testWidgets('renders FAQs title in app bar', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildApp());
      await tester.pump();
      await tester.pump();

      expect(find.text('FAQs'), findsOneWidget);
    });

    testWidgets('renders all 5 FAQ questions', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildApp());
      await tester.pump();
      await tester.pump();

      // 5 ExpansionTile items
      expect(find.byType(ExpansionTile), findsNWidgets(5));

      // Check specific questions are visible
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
      await tester.pump();

      // Answer should not be visible initially
      expect(
        find.textContaining('Go to the Profile tab'),
        findsNothing,
      );

      // Tap the first question to expand
      await tester.tap(find.text('How do I create a biodata?'));
      await tester.pumpAndSettle();

      // Answer should now be visible
      expect(
        find.textContaining('Go to the Profile tab'),
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
      await tester.pumpAndSettle();

      expect(find.text('FAQs'), findsOneWidget);

      // Tap back button
      await tester.tap(find.byType(IconButton).first);
      await tester.pumpAndSettle();

      // Should be back on the initial screen
      navigatedBack = find.text('Go').evaluate().isNotEmpty;
      expect(navigatedBack, isTrue);
    });
  });
}
