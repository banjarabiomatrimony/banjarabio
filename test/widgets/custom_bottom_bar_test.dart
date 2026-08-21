import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/widgets/custom_bottom_bar.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/l10n/app_localizations.dart';

void main() {
  testWidgets('CustomBottomBar renders 5 tabs and handles tapping', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    int tappedIndex = -1;

    await tester.pumpWidget(
      Sizer(
        builder: (context, orientation, deviceType) {
          return MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              bottomNavigationBar: CustomBottomBar(
                currentIndex: 0,
                onTap: (index) {
                  tappedIndex = index;
                },
              ),
            ),
          );
        },
      ),
    );

    await tester.pumpAndSettle();

    // Verify 5 active nav items exist
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Chat'), findsOneWidget); // Localized or fallback Connect/Chat label
    expect(find.text('Biodata'), findsOneWidget);
    expect(find.text('Services'), findsOneWidget);
    expect(find.text('Menu'), findsOneWidget);

    // Tap on Biodata tab (index 2)
    await tester.tap(find.text('Biodata'));
    await tester.pump();
    expect(tappedIndex, 2);

    // Tap on Services tab (index 3)
    await tester.tap(find.text('Services'));
    await tester.pump();
    expect(tappedIndex, 3);

    // Tap on Menu tab (index 4)
    await tester.tap(find.text('Menu'));
    await tester.pump();
    expect(tappedIndex, 4);
  });
}
