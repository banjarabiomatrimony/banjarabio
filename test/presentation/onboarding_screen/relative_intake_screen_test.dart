import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/presentation/onboarding_screen/relative_intake_screen.dart';

void main() {
  testWidgets('RelativeIntakeScreen renders all questions and handles interactions', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      Sizer(
        builder: (context, orientation, deviceType) {
          return const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: RelativeIntakeScreen(),
          );
        },
      ),
    );

    // Initial pump for entrance animations
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 600));

    // 1. Verify Question 1 Section
    final brideCard = find.text('Bride (Girl)');
    expect(brideCard, findsOneWidget);
    expect(find.text('Groom (Boy)'), findsOneWidget);

    // 2. Select Bride (Female)
    await tester.tap(brideCard);
    await tester.pump(const Duration(milliseconds: 300));

    // 3. Select Relation (For My Son)
    final sonChip = find.text('For My Son').first;
    expect(find.text('For My Son'), findsWidgets);
    await tester.tap(sonChip);
    await tester.pump(const Duration(milliseconds: 300));

    // Cleanup: unmount to drain infinite ambient animation controllers
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('RelativeIntakeScreen works in embedded mode with onProceed callback', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    bool proceedCalled = false;

    await tester.pumpWidget(
      Sizer(
        builder: (context, orientation, deviceType) {
          return MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: RelativeIntakeScreen(
                embedded: true,
                onProceed: () => proceedCalled = true,
              ),
            ),
          );
        },
      ),
    );

    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Bride (Girl)'), findsOneWidget);
    expect(proceedCalled, isFalse);

    // Cleanup: unmount
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
  });
}
