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

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    // 1. Verify App Bar and Header
    expect(find.text('Services'), findsOneWidget);
    expect(find.text('Banjara Wedding Services Hub'), findsOneWidget);

    // 2. Verify Category Tiles & Actions
    expect(find.text('DJ & Sound System'), findsOneWidget);
    expect(find.text('Mandap & Theme Decor'), findsOneWidget);
    expect(find.text('+ Vendor'), findsOneWidget);
  });
}
