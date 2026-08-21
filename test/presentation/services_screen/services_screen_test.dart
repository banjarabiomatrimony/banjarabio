import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/presentation/services_screen/services_screen.dart';

void main() {
  testWidgets('ServicesScreen renders dedicated Wedding Services Marketplace', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        child: Sizer(
          builder: (context, orientation, deviceType) {
            return const MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: ServicesScreen(),
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    // 1. Verify App Bar
    expect(find.text('Wedding Services Marketplace'), findsOneWidget);

    // 2. Verify Category Tiles
    expect(find.text('DJ & Sound'), findsOneWidget);
    expect(find.text('Mandap & Decor'), findsOneWidget);
    expect(find.text('Catering'), findsOneWidget);
    expect(find.text('Photography'), findsOneWidget);
    expect(find.text('Register'), findsOneWidget);
  });
}
